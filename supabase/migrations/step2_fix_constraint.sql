-- ============================================================
-- PASO 2: Actualizar Constraint (Ejecutar DESPUÉS del diagnóstico)
-- ============================================================
-- Primero elimina el constraint sin validar datos existentes
-- ============================================================

-- Eliminar constraint sin validar
ALTER TABLE marketplace_cases DROP CONSTRAINT IF EXISTS marketplace_cases_status_check;

-- ============================================================
-- IMPORTANTE: Reemplaza la siguiente línea según los resultados del diagnóstico
-- ============================================================
-- Si en el diagnóstico viste estos valores: 'open', 'accepted', etc.
-- Asegúrate de incluirlos TODOS en la lista, más 'expired'

-- Crear nuevo constraint con todos los valores necesarios
ALTER TABLE marketplace_cases
ADD CONSTRAINT marketplace_cases_status_check 
CHECK (status IN (
  'open',      -- Caso abierto
  'full',      -- Cupo lleno
  'accepted',  -- Propuesta aceptada
  'assigned',  -- Caso asignado
  'rejected',  -- Rechazado
  'expired',   -- Expirado (NUEVO)
  'closed',    -- Cerrado
  'pending',   -- Pendiente (si existe)
  'active'     -- Activo (si existe)
));

-- Nota: Agrega o quita valores según lo que viste en el diagnóstico

-- ============================================================
-- Verificar que se creó correctamente
-- ============================================================
SELECT 
  conname as constraint_name,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'marketplace_cases'::regclass
  AND conname = 'marketplace_cases_status_check';
