-- Script SQL para asignar manualmente un abogado a un caso de prueba
-- Este script debe ejecutarse en el editor SQL de Supabase

-- 1. Ver abogados disponibles
SELECT id, full_name, email, location 
FROM user_profiles 
WHERE user_type = 'lawyer' 
LIMIT 10;

-- 2. Ver casos del cliente actual (37f86726-e6c2-4c31-a1ac-7380fdc490c5)
SELECT id, title, status, assigned_lawyer_id, created_at
FROM marketplace_cases
WHERE client_id = '37f86726-e6c2-4c31-a1ac-7380fdc490c5'
ORDER BY created_at DESC;

-- 3. Asignar un abogado al caso "monica"
-- IMPORTANTE: Reemplaza 'LAWYER_ID_AQUI' con un ID real de abogado del paso 1
UPDATE marketplace_cases
SET 
  assigned_lawyer_id = 'LAWYER_ID_AQUI',
  status = 'assigned',
  updated_at = NOW()
WHERE id = '2e801c3b-9cb3-4a93-82c0-af12aa60a0ca';

-- 4. Verificar la asignación
SELECT 
  c.id,
  c.title,
  c.status,
  c.assigned_lawyer_id,
  u.full_name as lawyer_name,
  u.location as lawyer_location
FROM marketplace_cases c
LEFT JOIN user_profiles u ON c.assigned_lawyer_id = u.id
WHERE c.id = '2e801c3b-9cb3-4a93-82c0-af12aa60a0ca';
