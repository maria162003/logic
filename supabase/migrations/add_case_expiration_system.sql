-- ============================================================
-- SISTEMA DE EXPIRACIÓN AUTOMÁTICA DE CASOS
-- ============================================================
-- Objetivo: Expirar casos que no reciban propuestas aceptadas en 7 días
-- Aplica tanto para abogados como para estudiantes
-- No afecta la lógica actual de límites de propuestas ni filtros
-- ============================================================

-- Paso 1: Habilitar la extensión pg_cron para jobs programados
-- Esta extensión permite ejecutar tareas programadas en PostgreSQL
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ============================================================
-- Paso 1.5: Actualizar constraint de status para incluir 'expired'
-- ============================================================
-- Primero eliminar el constraint existente si existe
ALTER TABLE marketplace_cases 
DROP CONSTRAINT IF EXISTS marketplace_cases_status_check;

-- Crear el constraint actualizado que incluye 'expired' + valores existentes
ALTER TABLE marketplace_cases
ADD CONSTRAINT marketplace_cases_status_check 
CHECK (status IN (
  'open',       -- Caso abierto
  'active',     -- Activo (existente en BD)
  'assigned',   -- Asignado
  'completed',  -- Completado (existente en BD)
  'full',       -- Cupo lleno
  'accepted',   -- Propuesta aceptada
  'rejected',   -- Rechazado
  'expired',    -- Expirado - NUEVO
  'closed'      -- Cerrado
));

COMMENT ON CONSTRAINT marketplace_cases_status_check ON marketplace_cases IS 
'Estados permitidos: open, active, assigned, completed, full, accepted, rejected, expired, closed';

-- ============================================================
-- Paso 2: Crear función que expira casos automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION expire_old_cases()
RETURNS TABLE(
  expired_case_id uuid,
  case_title text,
  days_old numeric
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  expiration_days CONSTANT INTEGER := 7;
  cases_updated INTEGER := 0;
BEGIN
  -- Registrar inicio de ejecución
  RAISE NOTICE 'Iniciando proceso de expiración de casos...';
  
  -- Actualizar casos que cumplan las condiciones:
  -- 1. Estado actual es 'open' o 'full' (no accepted, assigned, rejected, expired)
  -- 2. Creados hace más de 7 días
  -- 3. NO tienen ninguna propuesta aceptada
  UPDATE marketplace_cases
  SET 
    status = 'expired',
    updated_at = NOW()
  WHERE 
    -- Condición 1: Solo casos abiertos o llenos
    status IN ('open', 'full')
    
    -- Condición 2: Más de 7 días desde creación
    AND created_at < NOW() - INTERVAL '7 days'
    
    -- Condición 3: Sin propuestas aceptadas
    AND NOT EXISTS (
      SELECT 1 
      FROM proposals 
      WHERE proposals.case_id = marketplace_cases.id 
        AND proposals.status = 'accepted'
    );
  
  -- Obtener cantidad de casos actualizados
  GET DIAGNOSTICS cases_updated = ROW_COUNT;
  
  RAISE NOTICE 'Casos expirados: %', cases_updated;
  
  -- Retornar detalles de los casos expirados para auditoría
  RETURN QUERY
  SELECT 
    id::uuid AS expired_case_id,
    title::text AS case_title,
    EXTRACT(DAY FROM (NOW() - created_at))::numeric AS days_old
  FROM marketplace_cases
  WHERE status = 'expired'
    AND updated_at >= NOW() - INTERVAL '1 minute'
  ORDER BY updated_at DESC;
  
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION expire_old_cases() IS 
'Expira automáticamente casos que tienen más de 7 días sin propuestas aceptadas. Aplica tanto para casos de abogados como de estudiantes (Trámites Jurídicos).';

-- ============================================================
-- Paso 3: Configurar job programado con pg_cron
-- ============================================================
-- Ejecutar la función diariamente a las 2:00 AM
-- Esto evita impacto en horas pico del sistema
SELECT cron.schedule(
  'expire-old-cases-daily',           -- Nombre del job
  '0 2 * * *',                        -- Cron expression: 2:00 AM diariamente
  $$SELECT expire_old_cases();$$      -- Comando a ejecutar
);

-- ============================================================
-- Paso 4: Crear función auxiliar para verificación manual
-- ============================================================
-- Esta función permite ver qué casos serían expirados SIN modificarlos
-- Útil para pruebas y monitoreo
CREATE OR REPLACE FUNCTION preview_expirable_cases()
RETURNS TABLE(
  case_id uuid,
  title text,
  category text,
  status text,
  days_old numeric,
  proposals_count bigint,
  accepted_proposals bigint
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mc.id AS case_id,
    mc.title,
    mc.category,
    mc.status,
    EXTRACT(DAY FROM (NOW() - mc.created_at))::numeric AS days_old,
    COUNT(DISTINCT p.id) AS proposals_count,
    COUNT(DISTINCT p.id) FILTER (WHERE p.status = 'accepted') AS accepted_proposals
  FROM marketplace_cases mc
  LEFT JOIN proposals p ON p.case_id = mc.id
  WHERE 
    mc.status IN ('open', 'full')
    AND mc.created_at < NOW() - INTERVAL '7 days'
  GROUP BY mc.id, mc.title, mc.category, mc.status, mc.created_at
  HAVING COUNT(DISTINCT p.id) FILTER (WHERE p.status = 'accepted') = 0
  ORDER BY mc.created_at ASC;
END;
$$;

COMMENT ON FUNCTION preview_expirable_cases() IS 
'Muestra una vista previa de los casos que serían expirados sin modificarlos. Útil para auditoría y testing.';

-- ============================================================
-- Paso 5: Crear índice para optimizar la consulta de expiración
-- ============================================================
-- Índice compuesto para mejorar performance del job
CREATE INDEX IF NOT EXISTS idx_marketplace_cases_expiration 
ON marketplace_cases(status, created_at)
WHERE status IN ('open', 'full');

COMMENT ON INDEX idx_marketplace_cases_expiration IS 
'Optimiza la búsqueda de casos candidatos para expiración basándose en estado y fecha de creación.';

-- ============================================================
-- Paso 6: Registrar cambio en el esquema
-- ============================================================
-- Agregar registro de auditoría (si existe tabla de migrations)
DO $$
BEGIN
  RAISE NOTICE '✅ Sistema de expiración automática instalado correctamente';
  RAISE NOTICE '📅 Job programado: Diariamente a las 2:00 AM';
  RAISE NOTICE '⏱️  Período de expiración: 7 días sin propuestas aceptadas';
  RAISE NOTICE '🔍 Verificar casos expirables: SELECT * FROM preview_expirable_cases();';
  RAISE NOTICE '▶️  Ejecutar expiración manual: SELECT * FROM expire_old_cases();';
END $$;
