# 🎨 Guía Visual del Sistema de Límites de Propuestas

## 📱 Estados Visuales del Panel de Abogados

### 1. Caso ABIERTO con Cupos Disponibles (5/5 disponibles)

```
╔═══════════════════════════════════════════════════╗
║ Asesoría Legal para Contrato Laboral    [5/5] 🟢 ║ 
╠═══════════════════════════════════════════════════╣
║ 📂 Laboral  |  📍 Bogotá                         ║
║                                                    ║
║ Necesito revisión de contrato de trabajo...      ║
║                                                    ║
║ 👤 María González                                 ║
║    Bogotá, Colombia                               ║
║                                                    ║
║ Presupuesto: $300,000 COP                         ║
║                                      ╔═══════════╗ ║
║                                      ║  📤 Enviar ║ ║
║                                      ║  Propuesta║ ║
║                                      ╚═══════════╝ ║
║ Publicado hace 2 horas                            ║
╚═══════════════════════════════════════════════════╝
Estado: ✅ ACTIVO - Botón HABILITADO
Color de borde: 🟢 Verde tenue
```

### 2. Caso CASI LLENO (2/5 disponibles)

```
╔═══════════════════════════════════════════════════╗
║ Divorcio de Mutuo Acuerdo               [2/5] 🟠 ║ 
╠═══════════════════════════════════════════════════╣
║ 📂 Familiar  |  📍 Medellín                      ║
║                                                    ║
║ Buscamos abogado para proceso de divorcio...     ║
║                                                    ║
║ 👤 Carlos Ramírez                                 ║
║    Medellín, Antioquia                            ║
║                                                    ║
║ Presupuesto: $1,500,000 COP                       ║
║                                      ╔═══════════╗ ║
║                                      ║  📤 Enviar ║ ║
║                                      ║  Propuesta║ ║
║                                      ╚═══════════╝ ║
║ Publicado hace 5 horas                            ║
╚═══════════════════════════════════════════════════╝
Estado: ⚠️ ÚLTIMOS CUPOS - Botón HABILITADO con urgencia
Color de borde: 🟠 Naranja tenue
Mensaje: "¡Últimos 2 cupos disponibles!"
```

### 3. Caso LLENO (0/5 disponibles)

```
╔═══════════════════════════════════════════════════╗
║ Demanda por Accidente de Tránsito     [Lleno] 🔴 ║ 
╠═══════════════════════════════════════════════════╣
║ 📂 Civil  |  📍 Cali                             ║
║                                                    ║
║ Necesito representación legal para demanda...    ║
║                                                    ║
║ 👤 Laura Fernández                                ║
║    Cali, Valle                                    ║
║                                                    ║
║ Presupuesto: $2,000,000 COP                       ║
║                                      ╔═══════════╗ ║
║                                      ║ 🚫 Cupo   ║ ║
║                                      ║   Lleno   ║ ║
║                                      ╚═══════════╝ ║
║ Publicado hace 1 día                              ║
╚═══════════════════════════════════════════════════╝
Estado: 🚫 COMPLETO - Botón DESHABILITADO
Color de borde: 🔴 Rojo tenue
Tooltip: "Este caso alcanzó el límite de propuestas"
```

### 4. PROPUESTA YA ENVIADA

```
╔═══════════════════════════════════════════════════╗
║ Constitución de Empresa                [3/5] 🟢 ║ 
╠═══════════════════════════════════════════════════╣
║ 📂 Comercial  |  📍 Barranquilla                 ║
║                                                    ║
║ Asesoría para constituir SAS...                  ║
║                                                    ║
║ 👤 Jorge Martínez                                 ║
║    Barranquilla, Atlántico                        ║
║                                                    ║
║ Presupuesto: $800,000 COP                         ║
║                                      ╔═══════════╗ ║
║                                      ║ ✓ Propuesta║ ║
║                                      ║   Enviada ║ ║
║                                      ╚═══════════╝ ║
║ Publicado hace 3 horas                            ║
╚═══════════════════════════════════════════════════╝
Estado: ✅ ENVIADO - Badge verde con checkmark
No se puede enviar otra propuesta
```

### 5. Caso CERRADO (propuesta aceptada)

```
╔═══════════════════════════════════════════════════╗
║ Defensa en Caso Penal              [Cerrado] ⚫ ║ 
╠═══════════════════════════════════════════════════╣
║ 📂 Penal  |  📍 Bogotá                           ║
║                                                    ║
║ Necesito defensor para audiencia...              ║
║                                                    ║
║ 👤 Ana Rodríguez                                  ║
║    Bogotá, Cundinamarca                           ║
║                                                    ║
║ Presupuesto: $3,000,000 COP                       ║
║                                      ╔═══════════╗ ║
║                                      ║ 🔒 Caso   ║ ║
║                                      ║  Cerrado  ║ ║
║                                      ╚═══════════╝ ║
║ Publicado hace 2 días                             ║
╚═══════════════════════════════════════════════════╝
Estado: 🔒 CERRADO - Ya tiene abogado asignado
Color de borde: ⚫ Gris
```

## 🔄 Flujo de Interacción Completo

### Escenario: Caso Popular que se Llena Rápidamente

```
TIEMPO    ESTADO              CUPOS    VISUAL    ACCIÓN

T+0min    Caso publicado      5/5      🟢       ← Abogado 1 ve caso abierto
T+2min    Primera propuesta   4/5      🟢       ← Abogado 1 envía
T+5min    Segunda propuesta   3/5      🟢       ← Abogado 2 envía
T+10min   Tercera propuesta   2/5      🟠       ← Abogado 3 envía → ⚠️ ALERTA
T+12min   Cuarta propuesta    1/5      🟠       ← Abogado 4 envía → ⚠️ ÚLTIMA
T+15min   Quinta propuesta    0/5      🔴       ← Abogado 5 envía → 🚫 LLENO
T+20min   Intento fallido     0/5      🔴       ← Abogado 6 NO PUEDE enviar

         ❌ ERROR: "Este caso ya alcanzó el límite de propuestas (5)"
```

### Escenario: Cliente Rechaza y Reabre Cupo

```
TIEMPO    EVENTO                   CUPOS    ESTADO    VISUAL

T+0       Caso lleno               0/5      full      🔴
T+5       Cliente rechaza prop #3  1/5      open      🟠
          └─ Se libera 1 cupo!
T+10      Abogado 6 ve caso        1/5      open      🟠
T+12      Abogado 6 envía          0/5      full      🔴
          └─ Caso vuelve a llenarse
```

## 💬 Mensajes al Usuario

### Mensajes de Éxito:

```
✅ "Propuesta enviada exitosamente"
   └─ Se muestra cuando se envía correctamente
   └─ SnackBar verde por 3 segundos
```

### Mensajes de Error:

```
❌ "Ya enviaste una propuesta para este caso"
   └─ Intento de enviar segunda propuesta
   └─ SnackBar rojo con explicación

❌ "Este caso ya no está disponible para propuestas"
   └─ Caso cambió a 'full' o 'closed' durante el envío
   └─ SnackBar rojo con sugerencia de ver otros casos

❌ "Este caso ya alcanzó el límite de propuestas (5)"
   └─ Se alcanzó el máximo mientras preparaba la propuesta
   └─ SnackBar rojo con contador
```

### Mensajes Informativos:

```
ℹ️ "3 cupos disponibles"
   └─ Se muestra en el badge del caso
   
ℹ️ "¡Últimos 2 cupos disponibles!"
   └─ Alerta cuando quedan ≤2 cupos
   └─ Color naranja para urgencia

ℹ️ "Cupo lleno - No se aceptan más propuestas"
   └─ Tooltip en botón deshabilitado
```

## 🎯 Diálogo de Envío de Propuesta

### Vista del Formulario:

```
┌────────────────────────────────────────┐
│  Enviar Propuesta                      │
├────────────────────────────────────────┤
│                                         │
│  Mensaje de propuesta                  │
│  ┌──────────────────────────────────┐ │
│  │ Describe tu experiencia...        │ │
│  │                                   │ │
│  │                                   │ │
│  └──────────────────────────────────┘ │
│                                         │
│  Honorarios (COP)                      │
│  ┌──────────────────────────────────┐ │
│  │ $ 500.000                         │ │
│  └──────────────────────────────────┘ │
│                                         │
│  Días estimados                        │
│  ┌──────────────────────────────────┐ │
│  │ 30 días                           │ │
│  └──────────────────────────────────┘ │
│                                         │
│  Método de pago                        │
│  ○ Pago único al inicio                │
│  ● Dos pagos (inicio y fin)            │
│  ○ Pago por resultado                  │
│  ○ Pagos divididos durante proceso     │
│                                         │
│              ┌──────────┐ ┌──────────┐ │
│              │ Cancelar │ │  Enviar  │ │
│              └──────────┘ └──────────┘ │
└────────────────────────────────────────┘

Validaciones:
✓ Todos los campos requeridos
✓ Honorarios > 0
✓ Días > 0
✓ Método de pago seleccionado
```

## 📊 Dashboard de Estado (Para Futuro)

Métricas que se pueden agregar:

```
╔════════════════════════════════════════════════╗
║           ESTADÍSTICAS DEL CASO                ║
╠════════════════════════════════════════════════╣
║  Propuestas recibidas:        5 / 5            ║
║  Tiempo hasta llenarse:       15 minutos       ║
║  Promedio honorarios:         $450,000         ║
║  Días promedio estimados:     25 días          ║
║                                                 ║
║  Distribución de honorarios:                   ║
║  ▓▓▓▓▓▓▓▓░░ $300K-$500K (60%)                 ║
║  ▓▓▓▓░░░░░░ $500K-$700K (30%)                 ║
║  ▓░░░░░░░░░ $700K+      (10%)                 ║
╚════════════════════════════════════════════════╝
```

## 🔔 Notificaciones (Preparadas para Futuro)

### Para el Cliente:

```
📧 "Nueva propuesta recibida (3/5)"
   └─ Cada vez que llega una propuesta

📧 "Tu caso está por llenarse (4/5)"
   └─ Cuando llega la cuarta propuesta

📧 "Tu caso alcanzó el límite de propuestas (5/5)"
   └─ Cuando se completa
```

### Para el Abogado:

```
📧 "Tu propuesta fue enviada"
   └─ Confirmación de envío

📧 "Tu propuesta fue aceptada ✓"
   └─ Cliente aceptó la propuesta

📧 "Tu propuesta fue rechazada"
   └─ Cliente rechazó la propuesta
```

## 🎨 Paleta de Colores del Sistema

```
Estado        Color Principal    Borde          Background
─────────────────────────────────────────────────────────
Open          🟢 #4CAF50        #4CAF5033      #4CAF501A
Almost Full   🟠 #FF9800        #FF980033      #FF98001A
Full          🔴 #F44336        #F4433633      #F443361A
Closed        ⚫ #757575        #75757533      #7575751A
Success       🟢 #4CAF50        #4CAF50        #4CAF501A
Error         🔴 #F44336        #F44336        #F443361A
```

## 🧪 Casos de Prueba

### Test 1: Envío Normal
- ✅ Caso con 5/5 cupos
- ✅ Abogado sin propuesta previa
- ✅ Debe permitir enviar
- ✅ Contador: 5/5 → 4/5

### Test 2: Propuesta Duplicada
- ✅ Caso con 3/5 cupos
- ❌ Abogado YA envió propuesta
- ❌ Debe rechazar con mensaje
- ✅ Contador sin cambios

### Test 3: Caso Lleno
- ✅ Caso con 0/5 cupos
- ❌ Cualquier abogado
- ❌ Botón deshabilitado
- ❌ No permite enviar

### Test 4: Race Condition
- ✅ Caso con 1/5 cupo
- ✅ 2 abogados envían simultáneamente
- ✅ Solo 1 debe tener éxito
- ✅ El otro recibe error de límite

### Test 5: Rechazo y Reapertura
- ✅ Caso lleno (0/5)
- ✅ Cliente rechaza 1 propuesta
- ✅ Cupo liberado (1/5)
- ✅ Estado cambia full → open
- ✅ Badge cambia 🔴 → 🟠

---

**Última actualización**: Febrero 3, 2026
**Para soporte**: Revisar PROPOSALS_LIMIT_SYSTEM.md
