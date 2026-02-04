# Sistema de Expiración Automática de Casos

## 📋 Descripción General

Sistema automático que expira casos del Legalmarket después de 7 días sin que el cliente acepte ninguna propuesta. Aplica tanto para casos de abogados como de estudiantes (Trámites Jurídicos).

## 🎯 Objetivo

- Mantener el marketplace limpio y actualizado
- Evitar casos abandonados que ocupen espacio
- Mejorar la experiencia de abogados/estudiantes mostrando solo casos activos
- No afectar la lógica actual de límites de propuestas ni filtros

## 📐 Reglas de Negocio

### Estados del Caso

```
open → full → accepted ✅ (flujo normal)
open → expired ❌ (7 días sin aceptación)
full → expired ❌ (7 días sin aceptación aunque esté lleno)
```

### Condiciones para Expiración

Un caso expira automáticamente cuando cumple **TODAS** estas condiciones:

1. ✅ Estado actual es `open` o `full`
2. ✅ Han pasado más de 7 días desde `created_at`
3. ✅ NO existe ninguna propuesta con status `accepted`

### Comportamiento

- ⏰ **Verificación**: Diariamente a las 2:00 AM (pg_cron)
- 🔄 **Proceso**: Automático en el backend
- 🚫 **No depende de**: Rechazos de propuestas, cantidad de propuestas enviadas
- ✅ **Depende solo de**: Falta de aceptación después de 7 días

## 🗄️ Implementación Técnica

### 1. Base de Datos (Supabase PostgreSQL)

#### Migración Ejecutada
```bash
supabase/migrations/add_case_expiration_system.sql
```

#### Componentes Creados

1. **Extensión pg_cron**: Permite ejecutar tareas programadas
2. **Función `expire_old_cases()`**: Lógica de expiración
3. **Job programado**: Ejecuta la función diariamente
4. **Función `preview_expirable_cases()`**: Vista previa para testing
5. **Índice optimizado**: Mejora performance de búsqueda

#### Función Principal

```sql
CREATE OR REPLACE FUNCTION expire_old_cases()
RETURNS TABLE(expired_case_id uuid, case_title text, days_old numeric)
```

**Lógica:**
- Actualiza casos con más de 7 días
- Solo si están en estado `open` o `full`
- Solo si NO tienen propuestas aceptadas
- Cambia su estado a `expired`
- Retorna lista de casos expirados para auditoría

#### Job Programado

```sql
SELECT cron.schedule(
  'expire-old-cases-daily',
  '0 2 * * *',  -- Diariamente a las 2:00 AM
  $$SELECT expire_old_cases();$$
);
```

### 2. Backend (Flutter/Dart)

#### Servicio (supabase_service.dart)

**Cambio en filtro del marketplace:**

```dart
// ANTES:
query = query.eq('status', 'open');

// DESPUÉS:
query = query.inFilter('status', ['open', 'full']);
```

**Efecto:**
- ✅ Muestra casos `open` (disponibles)
- ✅ Muestra casos `full` (llenos pero activos)
- ❌ Excluye casos `expired` automáticamente
- ❌ Excluye casos `accepted`/`assigned`

#### Provider (marketplace_provider.dart)

**Enum actualizado:**

```dart
enum CaseAvailabilityStatus {
  open,        // Caso abierto con cupos disponibles
  almostFull,  // Quedan pocos cupos (≤2)
  full,        // Alcanzó el límite de propuestas
  closed,      // Caso cerrado (propuesta aceptada)
  expired,     // Caso expirado (más de 7 días sin aceptación) ← NUEVO
}
```

**Método `getCaseStatus()` actualizado:**

```dart
if (status == 'expired') {
  return CaseAvailabilityStatus.expired;
}
```

**Mensaje descriptivo:**

```dart
case CaseAvailabilityStatus.expired:
  return 'Caso expirado - Sin respuesta del cliente';
```

### 3. Frontend (UI)

#### Pantalla (lawyer_marketplace_proposals_screen_supabase.dart)

**Badge de estado:**
- Color: Gris oscuro (`Colors.grey[700]`)
- Icono: `Icons.schedule` (reloj)
- Texto: "Expirado"

**Botón:**
- Label: "Caso Expirado"
- Estado: Deshabilitado automáticamente

**Borde del card:**
- Color: Gris translúcido (`Colors.grey.withValues(alpha: 0.2)`)

## 🧪 Testing y Verificación

### Comandos Útiles

#### 1. Ver casos que serían expirados (sin modificar)

```sql
SELECT * FROM preview_expirable_cases();
```

Retorna:
- `case_id`: ID del caso
- `title`: Título del caso
- `category`: Categoría (incluyendo "Trámites Jurídicos")
- `status`: Estado actual
- `days_old`: Días desde creación
- `proposals_count`: Total de propuestas
- `accepted_proposals`: Propuestas aceptadas (debe ser 0)

#### 2. Ejecutar expiración manualmente (para testing)

```sql
SELECT * FROM expire_old_cases();
```

Retorna lista de casos que fueron expirados.

#### 3. Verificar job programado

```sql
SELECT * FROM cron.job WHERE jobname = 'expire-old-cases-daily';
```

#### 4. Ver casos expirados recientemente

```sql
SELECT id, title, category, status, created_at, updated_at
FROM marketplace_cases
WHERE status = 'expired'
ORDER BY updated_at DESC
LIMIT 10;
```

### Escenarios de Prueba

| Escenario | Estado Inicial | Días | Propuestas Aceptadas | Resultado |
|-----------|---------------|------|---------------------|-----------|
| Caso nuevo sin propuestas | `open` | 3 | 0 | ✅ Permanece `open` |
| Caso antiguo sin propuestas | `open` | 8 | 0 | ❌ Cambia a `expired` |
| Caso lleno antiguo | `full` | 8 | 0 | ❌ Cambia a `expired` |
| Caso con propuesta aceptada | `accepted` | 10 | 1 | ✅ Ya cerrado, no se toca |
| Caso lleno con aceptación reciente | `full` | 8 | 1 | ✅ Permanece activo |

## 🔍 Monitoreo

### Logs en PostgreSQL

El sistema registra cada ejecución:

```
NOTICE: Iniciando proceso de expiración de casos...
NOTICE: Casos expirados: 3
```

### Auditoría

La función `expire_old_cases()` retorna información detallada de cada caso expirado:

```sql
expired_case_id | case_title              | days_old
----------------|-------------------------|----------
uuid-1          | Proceso penal urgente   | 8
uuid-2          | Trámite de divorcio     | 9
uuid-3          | Consulta laboral        | 10
```

## 📊 Impacto en el Sistema

### ✅ Ventajas

1. **Limpieza automática**: Casos inactivos se remueven sin intervención manual
2. **Mejor UX**: Abogados/estudiantes ven solo casos realmente activos
3. **Optimización**: Reduce carga de queries al filtrar casos obsoletos
4. **Escalabilidad**: Funciona automáticamente sin importar el volumen
5. **Neutralidad**: Aplica igual para todas las categorías

### ⚠️ Consideraciones

1. **Período de gracia**: Los clientes tienen 7 días completos para revisar propuestas
2. **No hay reversión automática**: Un caso `expired` permanece así
3. **No afecta propuestas existentes**: Las propuestas enviadas permanecen registradas
4. **Visible para clientes**: El cliente puede ver que su caso expiró

### 🔧 Mantenimiento

#### Cambiar período de expiración

Si en el futuro se quiere cambiar de 7 a 10 días:

```sql
-- Modificar la función
CREATE OR REPLACE FUNCTION expire_old_cases()
RETURNS TABLE(...)
AS $$
DECLARE
  expiration_days CONSTANT INTEGER := 10; -- Cambiar aquí
BEGIN
  -- resto del código igual
END;
$$;
```

#### Desactivar temporalmente

```sql
-- Desactivar job
SELECT cron.unschedule('expire-old-cases-daily');

-- Reactivar más tarde
SELECT cron.schedule(
  'expire-old-cases-daily',
  '0 2 * * *',
  $$SELECT expire_old_cases();$$
);
```

## 🚀 Próximos Pasos

### Para Ejecutar en Producción

1. **Ejecutar migración**:
```bash
supabase migration up
```

2. **Verificar instalación**:
```sql
SELECT * FROM preview_expirable_cases();
```

3. **Probar manualmente**:
```sql
SELECT * FROM expire_old_cases();
```

4. **Monitorear durante 1 semana** para validar comportamiento

### Funcionalidades Futuras (Opcionales)

- [ ] Notificar al cliente 1 día antes de expirar
- [ ] Permitir extensión del período por solicitud del cliente
- [ ] Dashboard de métricas de expiración
- [ ] Opción de reabrir casos expirados (con nueva fecha)

## 📝 Notas Importantes

- ✅ El sistema respeta la separación entre abogados y estudiantes
- ✅ Los filtros por categoría siguen funcionando normalmente
- ✅ El límite de propuestas por caso no se ve afectado
- ✅ Los casos `full` también pueden expirar si no hay aceptación
- ✅ La expiración es independiente del número de propuestas recibidas

---

**Implementado por**: GitHub Copilot  
**Fecha**: Febrero 3, 2026  
**Versión**: 1.0  
