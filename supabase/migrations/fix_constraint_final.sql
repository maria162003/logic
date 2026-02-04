-- ============================================================
-- SOLUCIÓN FINAL: Actualizar Constraint con Valores Correctos
-- ============================================================
-- Basado en los valores actuales de tu base de datos
-- ============================================================

-- PASO 1: Eliminar constraint actual
ALTER TABLE marketplace_cases DROP CONSTRAINT IF EXISTS marketplace_cases_status_check;

-- PASO 2: Crear constraint con TODOS los valores que existen + 'expired'
ALTER TABLE marketplace_cases
ADD CONSTRAINT marketplace_cases_status_check 
CHECK (status IN (
  'open',       -- Caso abierto (7 casos)
  'active',     -- Activo (4 casos)
  'assigned',   -- Asignado (2 casos)
  'completed',  -- Completado (2 casos)
  'full',       -- Cupo lleno (futuro)
  'accepted',   -- Propuesta aceptada (futuro)
  'rejected',   -- Rechazado (futuro)
  'expired',    -- Expirado - NUEVO
  'closed'      -- Cerrado (futuro)
));

-- PASO 3: Verificar que se creó correctamente
SELECT 
  conname as constraint_name,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'marketplace_cases'::regclass
  AND conname = 'marketplace_cases_status_check';

-- ✅ RESULTADO ESPERADO: 
-- Debe mostrar el constraint con todos los valores listados arriba
