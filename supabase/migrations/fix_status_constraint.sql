-- ============================================================
-- FIX: Actualizar Constraint de Status
-- ============================================================
-- Ejecuta este archivo ANTES de la migración principal
-- ============================================================

-- PASO 1: Ver qué valores de status existen actualmente
SELECT DISTINCT status, COUNT(*) as count
FROM marketplace_cases
GROUP BY status
ORDER BY count DESC;

-- PASO 2: Ver el constraint actual
SELECT 
  conname as constraint_name,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'marketplace_cases'::regclass
  AND conname LIKE '%status%';

-- PASO 3: Eliminar constraint anterior (si existe)
DO $$ 
BEGIN
  ALTER TABLE marketplace_cases DROP CONSTRAINT IF EXISTS marketplace_cases_status_check;
  RAISE NOTICE 'Constraint anterior eliminado (si existía)';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'No se pudo eliminar constraint: %', SQLERRM;
END $$;

-- PASO 4: Crear nuevo constraint que incluye 'expired'
ALTER TABLE marketplace_cases
ADD CONSTRAINT marketplace_cases_status_check 
CHECK (status IN ('open', 'full', 'accepted', 'assigned', 'rejected', 'expired', 'closed'));

-- PASO 5: Verificar que se creó correctamente
SELECT 
  conname as constraint_name,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'marketplace_cases'::regclass
  AND conname = 'marketplace_cases_status_check';

-- ============================================================
-- Si el PASO 4 falla, ejecuta esto para ver qué filas tienen
-- valores no válidos:
-- ============================================================
/*
SELECT id, title, status, created_at
FROM marketplace_cases
WHERE status NOT IN ('open', 'full', 'accepted', 'assigned', 'rejected', 'expired', 'closed')
LIMIT 10;
*/

-- ============================================================
-- RESULTADO ESPERADO:
-- ============================================================
-- El constraint debe permitir estos valores:
-- 'open', 'full', 'accepted', 'assigned', 'rejected', 'expired', 'closed'
