-- ============================================================
-- SCRIPT DE TESTING: Sistema de Expiración de Casos
-- ============================================================
-- Ejecuta estas queries en Supabase SQL Editor para verificar
-- que el sistema funciona correctamente
-- ============================================================

-- ============================================================
-- PASO 0: Ver estructura de la tabla marketplace_cases
-- ============================================================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'marketplace_cases'
ORDER BY ordinal_position;
-- Muestra todas las columnas disponibles en la tabla

-- ============================================================
-- PASO 1: Verificar que pg_cron está instalado
-- ============================================================
SELECT * FROM pg_extension WHERE extname = 'pg_cron';
-- Debe retornar 1 fila con extname = 'pg_cron'

-- ============================================================
-- PASO 2: Verificar que el job está programado
-- ============================================================
SELECT 
  jobid,
  jobname,
  schedule,
  command,
  active
FROM cron.job 
WHERE jobname = 'expire-old-cases-daily';
-- Debe mostrar el job con schedule '0 2 * * *' y active = true

-- ============================================================
-- PASO 3: Ver qué casos serían expirados (SIN modificarlos)
-- ============================================================
SELECT * FROM preview_expirable_cases();
-- Muestra casos con más de 7 días sin aceptación
-- Si no hay resultados, no hay casos para expirar (normal en desarrollo)

-- ============================================================
-- PASO 4: Crear un caso de prueba para testing
-- ============================================================
-- IMPORTANTE: Reemplaza 'TU_CLIENT_ID' con un ID de cliente válido
-- Puedes obtener uno con: SELECT id FROM user_profiles WHERE user_type = 'client' LIMIT 1;

INSERT INTO marketplace_cases (
  client_id,
  title,
  description,
  category,
  location,
  status,
  budget,
  created_at,  -- Fecha hace 8 días para que expire inmediatamente
  max_proposals,
  current_proposals_count
) VALUES (
  'TU_CLIENT_ID',  -- ⚠️ REEMPLAZAR CON ID REAL
  'Caso de Prueba - Expiración',
  'Este es un caso de prueba para verificar el sistema de expiración automática',
  'Civil',
  'Bogotá',
  'open',
  800000,
  NOW() - INTERVAL '8 days',  -- Creado hace 8 días
  5,
  0
)
RETURNING id, title, created_at, status, budget;

-- Guarda el ID retornado para usarlo en las siguientes queries

-- ============================================================
-- PASO 5: Verificar que el caso fue creado correctamente
-- ============================================================
-- Reemplaza 'CASE_ID_DE_PRUEBA' con el ID del paso anterior
SELECT 
  id,
  title,
  status,
  budget,
  created_at,
  EXTRACT(DAY FROM (NOW() - created_at)) AS days_old
FROM marketplace_cases
WHERE id = 'CASE_ID_DE_PRUEBA';
-- Debe mostrar status = 'open' y days_old > 7

-- ============================================================
-- PASO 6: Ejecutar expiración manualmente
-- ============================================================
SELECT * FROM expire_old_cases();
-- Debe retornar el caso de prueba que acabamos de crear

-- ============================================================
-- PASO 7: Verificar que el caso cambió a 'expired'
-- ============================================================
SELECT 
  id,
  title,
  status,
  created_at,
  updated_at
FROM marketplace_cases
WHERE id = 'CASE_ID_DE_PRUEBA';
-- Ahora debe mostrar status = 'expired'

-- ============================================================
-- PASO 8: Verificar que casos 'expired' NO aparecen en marketplace
-- ============================================================
SELECT 
  id,
  title,
  status,
  category
FROM marketplace_cases
WHERE status IN ('open', 'full')  -- Filtro usado por el frontend
ORDER BY created_at DESC;
-- El caso de prueba NO debe aparecer aquí

-- ============================================================
-- PASO 9: Crear caso con propuesta aceptada (NO debe expirar)
-- ============================================================
-- Este caso NO debe expirar porque tiene una propuesta aceptada

-- 9.1 Crear caso antiguo
INSERT INTO marketplace_cases (
  client_id,
  title,
  description,
  category,
  status,
  created_at,
  max_proposals,
  current_proposals_count
) VALUES (
  'TU_CLIENT_ID',  -- ⚠️ REEMPLAZAR
  'Caso con Propuesta Aceptada',
  'Este caso NO debe expirar',
  'Laboral',
  'full',
  NOW() - INTERVAL '10 days',
  5,
  3
)
RETURNING id;

-- Guarda el ID como CASE_ID_ACCEPTED

-- 9.2 Crear propuesta aceptada para ese caso
-- Reemplaza TU_LAWYER_ID con un ID de abogado válido
INSERT INTO proposals (
  case_id,
  lawyer_id,
  client_id,
  message,
  proposed_fee,
  estimated_days,
  status
) VALUES (
  'CASE_ID_ACCEPTED',  -- ⚠️ REEMPLAZAR
  'TU_LAWYER_ID',      -- ⚠️ REEMPLAZAR
  'TU_CLIENT_ID',      -- ⚠️ REEMPLAZAR
  'Propuesta de prueba',
  800000,
  30,
  'accepted'
);

-- 9.3 Ejecutar expiración nuevamente
SELECT * FROM expire_old_cases();
-- Este caso NO debe aparecer en los resultados

-- 9.4 Verificar que sigue activo
SELECT id, title, status
FROM marketplace_cases
WHERE id = 'CASE_ID_ACCEPTED';
-- Debe seguir con status = 'full' (NO cambió a expired)

-- ============================================================
-- PASO 10: Limpiar casos de prueba
-- ============================================================
-- Eliminar casos de prueba después de verificar

-- Primero eliminar propuestas relacionadas
DELETE FROM proposals 
WHERE case_id IN (
  SELECT id FROM marketplace_cases 
  WHERE title LIKE 'Caso%Prueba%' OR title LIKE 'Caso con Propuesta%'
);

-- Luego eliminar los casos
DELETE FROM marketplace_cases
WHERE title LIKE 'Caso%Prueba%' OR title LIKE 'Caso con Propuesta%';

-- ============================================================
-- QUERIES ÚTILES PARA MONITOREO
-- ============================================================

-- Ver todos los casos expirados
SELECT 
  id,
  title,
  category,
  created_at,
  updated_at,
  EXTRACT(DAY FROM (updated_at - created_at)) AS days_to_expire
FROM marketplace_cases
WHERE status = 'expired'
ORDER BY updated_at DESC;

-- Contar casos por estado
SELECT 
  status,
  COUNT(*) as count
FROM marketplace_cases
GROUP BY status
ORDER BY count DESC;

-- Ver casos próximos a expirar (entre 5 y 7 días)
SELECT 
  id,
  title,
  category,
  status,
  created_at,
  EXTRACT(DAY FROM (NOW() - created_at)) AS days_old,
  7 - EXTRACT(DAY FROM (NOW() - created_at)) AS days_remaining
FROM marketplace_cases
WHERE 
  status IN ('open', 'full')
  AND created_at < NOW() - INTERVAL '5 days'
  AND created_at > NOW() - INTERVAL '7 days'
  AND NOT EXISTS (
    SELECT 1 FROM proposals 
    WHERE proposals.case_id = marketplace_cases.id 
      AND proposals.status = 'accepted'
  )
ORDER BY created_at ASC;

-- Ver historial de ejecuciones del job (si está disponible)
SELECT 
  jobid,
  runid,
  job_pid,
  database,
  username,
  command,
  status,
  return_message,
  start_time,
  end_time
FROM cron.job_run_details
WHERE jobid = (
  SELECT jobid FROM cron.job WHERE jobname = 'expire-old-cases-daily'
)
ORDER BY start_time DESC
LIMIT 10;

-- ============================================================
-- COMANDOS DE MANTENIMIENTO
-- ============================================================

-- Desactivar job temporalmente
-- SELECT cron.unschedule('expire-old-cases-daily');

-- Reactivar job
-- SELECT cron.schedule(
--   'expire-old-cases-daily',
--   '0 2 * * *',
--   $$SELECT expire_old_cases();$$
-- );

-- Cambiar horario del job (ejemplo: 3:30 AM)
-- SELECT cron.unschedule('expire-old-cases-daily');
-- SELECT cron.schedule(
--   'expire-old-cases-daily',
--   '30 3 * * *',
--   $$SELECT expire_old_cases();$$
-- );

-- ============================================================
-- FIN DEL SCRIPT DE TESTING
-- ============================================================
