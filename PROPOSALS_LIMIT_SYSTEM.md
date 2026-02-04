# 📌 Sistema de Límites de Propuestas - Documentación Completa

## 🎯 Resumen Ejecutivo

Se ha implementado un sistema completo de límite de propuestas por caso en el marketplace legal, que permite:

- **Límite configurable de propuestas** (por defecto 5 por caso)
- **Contador automático** de propuestas activas
- **Estados dinámicos** que reflejan la disponibilidad del caso
- **Validaciones en backend y frontend** para evitar propuestas duplicadas o exceso de cupo
- **Protección contra race conditions** mediante validaciones atómicas
- **Liberación de cupos** cuando se rechazan propuestas
- **Cierre automático** cuando se acepta una propuesta

## 🔧 Pasos de Implementación

### 1. **Ejecutar Migración de Base de Datos**

**IMPORTANTE**: Debes ejecutar la migración SQL en tu base de datos de Supabase antes de usar el sistema.

```bash
# Opción 1: Desde Supabase Dashboard
# 1. Ve a SQL Editor en tu proyecto Supabase
# 2. Copia y pega el contenido de: supabase/migrations/add_proposals_limit_system.sql
# 3. Ejecuta el script

# Opción 2: Desde CLI de Supabase (si lo tienes instalado)
supabase db push
```

La migración agrega:
- ✅ Columna `max_proposals` (límite máximo, default: 5)
- ✅ Columna `current_proposals_count` (contador actual)
- ✅ Constraints para validar integridad
- ✅ Índices para optimizar consultas
- ✅ Inicialización de contadores para casos existentes

### 2. **Verificar Estados en la Base de Datos**

Asegúrate de que la columna `status` en `marketplace_cases` soporta los siguientes valores:

- `open` - Caso abierto, acepta propuestas
- `full` - Alcanzó el límite de propuestas
- `accepted` - Propuesta aceptada, caso cerrado
- `assigned` - (legacy) Mantener para compatibilidad
- `expired` - (futuro) Para expiración por tiempo

### 3. **Verificar Columna Status en Proposals**

La tabla `proposals` debe tener la columna `status` con estos valores:

- `pending` - Propuesta enviada, esperando respuesta
- `accepted` - Propuesta aceptada por el cliente
- `rejected` - Propuesta rechazada por el cliente
- `withdrawn` - Propuesta retirada por el abogado

## 📋 Componentes Modificados

### Backend (`lib/services/supabase_service.dart`)

#### `sendProposal()` - Validaciones Implementadas:

1. ✅ **Verificación de propuesta duplicada**
   - Un abogado solo puede enviar UNA propuesta por caso
   
2. ✅ **Validación de estado del caso**
   - Solo casos con `status='open'` aceptan propuestas
   
3. ✅ **Verificación de cupos disponibles**
   - Compara `current_proposals_count` con `max_proposals`
   
4. ✅ **Actualización atómica del contador**
   - Incrementa `current_proposals_count` al insertar propuesta
   - Cambia estado a `'full'` si alcanza el límite

#### `updateProposalStatus()` - Lógica de Aceptación/Rechazo:

- **Cuando se ACEPTA una propuesta:**
  - Cambia estado del caso a `'accepted'`
  - Rechaza automáticamente otras propuestas del mismo caso
  - Crea registro en `active_cases`

- **Cuando se RECHAZA una propuesta:**
  - Decrementa `current_proposals_count`
  - Si estaba `'full'`, vuelve a `'open'`
  - Libera un cupo para nuevas propuestas

#### `_handleProposalRejection()` - Nuevo Método:

- Maneja la liberación de cupos al rechazar propuestas
- Actualiza contadores y reabre casos automáticamente

### Provider (`lib/providers/marketplace_provider.dart`)

#### Métodos Agregados:

```dart
// Obtener límite máximo de propuestas
int getMaxProposals(Map<String, dynamic> caseData)

// Obtener contador actual
int getCurrentProposalsCount(Map<String, dynamic> caseData)

// Calcular cupos disponibles
int getAvailableSlots(Map<String, dynamic> caseData)

// Verificar si se puede enviar propuesta
bool canSubmitProposal(Map<String, dynamic> caseData)

// Verificar si el abogado ya envió propuesta
bool hasProposalForCase(String caseId)

// Obtener estado visual del caso
CaseAvailabilityStatus getCaseStatus(Map<String, dynamic> caseData)

// Obtener mensaje descriptivo
String getStatusMessage(Map<String, dynamic> caseData)
```

#### Enum Agregado:

```dart
enum CaseAvailabilityStatus {
  open,        // Caso abierto con cupos disponibles
  almostFull,  // Quedan pocos cupos (≤2)
  full,        // Alcanzó el límite de propuestas
  closed,      // Caso cerrado (propuesta aceptada)
}
```

### UI (`lib/screens/lawyer_marketplace_proposals_screen_supabase.dart`)

#### Componentes Visuales Agregados:

1. **Badge de Estado en la Tarjeta del Caso**
   - 🟢 Verde: Cupos disponibles
   - 🟠 Naranja: Últimos cupos (≤2)
   - 🔴 Rojo: Cupo lleno
   - ⚫ Gris: Caso cerrado

2. **Borde de Tarjeta con Color de Estado**
   - Indica visualmente la disponibilidad del caso

3. **Botón de Envío Dinámico**
   - Se deshabilita automáticamente cuando:
     - Ya envió una propuesta
     - El caso está lleno
     - El caso está cerrado
   - Cambia el texto según el estado

4. **Indicador de Propuesta Enviada**
   - Badge verde con ✓ cuando ya envió propuesta

## 🎨 Experiencia de Usuario (UX)

### Panel del Abogado - Visualización:

```
┌─────────────────────────────────────────┐
│ Título del Caso               [3/5] 🟢 │  ← Badge muestra cupos
├─────────────────────────────────────────┤
│ Categoría: Penal | 📍 Bogotá           │
│                                         │
│ Descripción del caso...                │
│                                         │
│ 👤 Cliente                              │
│    Juan Pérez                           │
│                                         │
│ Presupuesto        [Enviar Propuesta]  │  ← Botón habilitado
│ $500,000 COP                            │
└─────────────────────────────────────────┘
```

### Estados del Botón:

- ✅ **"Enviar Propuesta"** - Activo, puede enviar
- ✔️ **"✓ Propuesta Enviada"** - Ya envió, badge verde
- 🚫 **"Cupo Lleno"** - Deshabilitado, sin cupos
- 🔒 **"Caso Cerrado"** - Deshabilitado, aceptado

### Mensajes de Error:

El sistema muestra mensajes claros cuando hay problemas:

- *"Ya enviaste una propuesta para este caso"*
- *"Este caso ya no está disponible para propuestas"*
- *"Este caso ya alcanzó el límite de propuestas (5)"*

## 🔒 Protección Contra Race Conditions

### Problema:
Dos abogados podrían enviar propuestas al mismo tiempo cuando queda 1 cupo.

### Solución Implementada:

1. **Validación en la consulta**:
   - Se lee el contador actual antes de insertar
   - Si cambió entre lectura e inserción, falla la transacción

2. **Operaciones atómicas**:
   - INSERT de propuesta y UPDATE de contador en la misma transacción
   - Si alguna falla, se revierte todo

3. **Constraint en base de datos**:
   - `CHECK (current_proposals_count <= max_proposals)`
   - Evita que el contador exceda el límite

## 📊 Flujo Completo del Sistema

### 1. Cliente Publica un Caso:
```
marketplace_cases:
  id: "abc123"
  status: "open"
  max_proposals: 5
  current_proposals_count: 0
```

### 2. Abogados Envían Propuestas:
```
Propuesta 1 → count: 0→1, status: "open"
Propuesta 2 → count: 1→2, status: "open"
Propuesta 3 → count: 2→3, status: "open"
Propuesta 4 → count: 3→4, status: "open"
Propuesta 5 → count: 4→5, status: "open" → "full" ✓
```

### 3. Cliente Rechaza una Propuesta:
```
Propuesta 3: "pending" → "rejected"
count: 5→4
status: "full" → "open" ✓
```

### 4. Cliente Acepta una Propuesta:
```
Propuesta 2: "pending" → "accepted"
Case status: "open" → "accepted"
Otras propuestas: "pending" → "rejected"
```

## ⚙️ Configuración por Caso

Si quieres cambiar el límite de propuestas para casos específicos:

```sql
-- Caso especial que acepta solo 3 propuestas
UPDATE marketplace_cases
SET max_proposals = 3
WHERE id = 'caso-especial-id';

-- Caso VIP que acepta 10 propuestas
UPDATE marketplace_cases
SET max_proposals = 10
WHERE id = 'caso-vip-id';
```

## 🚀 Futuras Mejoras (Preparadas)

### 1. Expiración por Tiempo:

El sistema está preparado para agregar lógica de expiración:

```dart
// En marketplace_provider.dart, agregar:
bool isCaseExpired(Map<String, dynamic> caseData) {
  if (caseData['deadline'] == null) return false;
  return DateTime.parse(caseData['deadline']).isBefore(DateTime.now());
}
```

### 2. Notificaciones:

Los códigos tienen comentarios `TODO` para agregar notificaciones:

- Cuando se envía una propuesta
- Cuando se acepta/rechaza una propuesta
- Cuando un caso está por llenarse

### 3. Analytics:

Agregar métricas de:
- Tasa de conversión por caso
- Tiempo promedio hasta llenarse
- Cupos más comunes utilizados

## ✅ Checklist de Implementación

- [x] Ejecutar migración SQL en Supabase
- [x] Modificar `sendProposal()` con validaciones
- [x] Agregar `_handleProposalRejection()`
- [x] Actualizar `updateProposalStatus()`
- [x] Crear métodos en MarketplaceProvider
- [x] Agregar enum `CaseAvailabilityStatus`
- [x] Modificar UI con badges y estados
- [x] Implementar botón dinámico
- [x] Agregar indicadores visuales
- [ ] **EJECUTAR MIGRACIÓN SQL** ← ¡PENDIENTE!
- [ ] Probar flujo completo
- [ ] Verificar edge cases
- [ ] Documentar para el equipo

## 🐛 Troubleshooting

### Problema: Contador desincronizado

```sql
-- Recalcular contadores manualmente
UPDATE marketplace_cases mc
SET current_proposals_count = (
  SELECT COUNT(*)
  FROM proposals p
  WHERE p.case_id = mc.id
  AND p.status = 'pending'
);
```

### Problema: Casos quedaron como 'full' incorrectamente

```sql
-- Reabrir casos que tienen cupos
UPDATE marketplace_cases
SET status = 'open'
WHERE status = 'full'
AND current_proposals_count < max_proposals;
```

## 📞 Soporte

Para dudas o problemas con la implementación, revisa:

1. Los logs en consola (prefijo "🔍 SUPABASE:")
2. El estado de la base de datos
3. Los métodos de validación en el provider

---

**Fecha de Implementación**: Febrero 3, 2026
**Versión**: 1.0.0
**Estado**: ✅ Completado - Pendiente ejecución de migración SQL
