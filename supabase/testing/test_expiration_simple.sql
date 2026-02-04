-- ============================================================
-- SCRIPT SIMPLIFICADO: Testing Rápido del Sistema de Expiración
-- ============================================================
-- Copia y pega CADA SECCIÓN por separado en Supabase SQL Editor
-- ============================================================

-- ============================================================
-- SECCIÓN 1: OBTENER IDS NECESARIOS
-- ============================================================
-- Ejecuta esto primero y GUARDA los resultados

-- 1.1 Obtener ID de un cliente
SELECT id as client_id, full_name, email 
FROM user_profiles 
WHERE user_type = 'client' 
LIMIT 1;

-- 1.2 Obtener ID de un abogado (para pruebas posteriores)
SELECT id as lawyer_id, full_name 
FROM user_profiles 
WHERE user_type = 'lawyer' OR user_type = 'student'
LIMIT 1;

-- ============================================================
-- SECCIÓN 2: CREAR CASO DE PRUEBA (Usa ID del paso 1.1)
-- ============================================================
-- Copia la siguiente query COMPLETA
-- Reemplaza SOLO la línea marcada con el client_id del paso 1.1

WITH client_data AS (
  SELECT id FROM user_profiles WHERE user_type = 'client' LIMIT 1
)
INSERT INTO marketplace_cases (
  client_id,
  title,
  description,
  category,
  location,
  status,
  budget,
  created_at,
  max_proposals,
  current_proposals_count
)
SELECT 
  id,  -- Toma el ID del cliente automáticamente
  'Caso de Prueba - Expiración',
  'Este es un caso de prueba para verificar el sistema de expiración automática',
  'Civil',
  'Bogotá',
  'open',
  800000,
  NOW() - INTERVAL '8 days',  -- Creado hace 8 días
  5,
  0
FROM client_data
RETURNING id, title, created_at, status, budget;

-- GUARDA EL ID QUE TE RETORNE - lo usarás en los próximos pasos

-- ============================================================
-- SECCIÓN 3: VERIFICAR CASO CREADO
-- ============================================================
-- Ejecuta esto para ver el caso recién creado

SELECT 
  id,
  title,
  status,
  created_at,
  EXTRACT(DAY FROM (NOW() - created_at)) AS days_old
FROM marketplace_cases
WHERE title = 'Caso de Prueba - Expiración';

-- Debe mostrar: status = 'open' y days_old = 8

-- ============================================================
-- SECCIÓN 4: EJECUTAR EXPIRACIÓN MANUAL
-- ============================================================
SELECT * FROM expire_old_cases();

-- Debe retornar el caso "Caso de Prueba - Expiración"

-- ============================================================
-- SECCIÓN 5: VERIFICAR QUE EXPIRÓ
-- ============================================================
SELECT 
  id,
  title,
  status,
  created_at,
  updated_at
FROM marketplace_cases
WHERE title = 'Caso de Prueba - Expiración';

-- Ahora debe mostrar: status = 'expired'

-- ============================================================
-- SECCIÓN 6: VERIFICAR QUE NO APARECE EN MARKETPLACE
-- ============================================================
SELECT 
  id,
  title,
  status,
  category
FROM marketplace_cases
WHERE status IN ('open', 'full')  -- Filtro del frontend
ORDER BY created_at DESC
LIMIT 10;

-- El caso de prueba NO debe aparecer aquí

-- ============================================================
-- SECCIÓN 7: LIMPIAR CASO DE PRUEBA
-- ============================================================
DELETE FROM marketplace_cases
WHERE title = 'Caso de Prueba - Expiración';

-- Retorna: DELETE 1 (si se eliminó correctamente)

-- ============================================================
-- SECCIÓN 8: PRUEBA CON PROPUESTA ACEPTADA (NO DEBE EXPIRAR)
-- ============================================================

-- 8.1 Crear caso antiguo con propuesta aceptada
WITH client_data AS (
  SELECT id FROM user_profiles WHERE user_type = 'client' LIMIT 1
),
lawyer_data AS (
  SELECT id FROM user_profiles WHERE user_type IN ('lawyer', 'student') LIMIT 1
),
new_case AS (
  INSERT INTO marketplace_cases (
    client_id,
    title,
    description,
    category,
    status,
    created_at,
    max_proposals,
    current_proposals_count
  )
  SELECT 
    c.id,
    'Caso con Propuesta Aceptada',
    'Este caso NO debe expirar',
    'Laboral',
    'full',
    NOW() - INTERVAL '10 days',
    5,
    3
  FROM client_data c
  RETURNING id, client_id
)
INSERT INTO proposals (
  case_id,
  lawyer_id,
  client_id,
  message,
  proposed_fee,
  estimated_days,
  status
)
SELECT 
  nc.id,
  ld.id,
  nc.client_id,
  'Propuesta de prueba aceptada',
  800000,
  30,
  'accepted'
FROM new_case nc, lawyer_data ld
RETURNING case_id, status;

-- 8.2 Ejecutar expiración
SELECT * FROM expire_old_cases();
-- Este caso NO debe aparecer en los resultados

-- 8.3 Verificar que sigue activo
SELECT id, title, status, created_at
FROM marketplace_cases
WHERE title = 'Caso con Propuesta Aceptada';
-- Debe seguir con status = 'full' (NO cambió a expired)

-- 8.4 Limpiar
DELETE FROM proposals 
WHERE case_id IN (
  SELECT id FROM marketplace_cases 
  WHERE title = 'Caso con Propuesta Aceptada'
);

DELETE FROM marketplace_cases
WHERE title = 'Caso con Propuesta Aceptada';

-- ============================================================
-- FIN DEL TESTING
-- ============================================================
