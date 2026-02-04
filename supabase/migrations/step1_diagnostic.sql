-- ============================================================
-- DIAGNÓSTICO: Ver valores actuales de status
-- ============================================================
-- Ejecuta SOLO esta query primero
-- ============================================================

SELECT DISTINCT status, COUNT(*) as count
FROM marketplace_cases
GROUP BY status
ORDER BY count DESC;

-- ============================================================
-- COPIA LOS RESULTADOS AQUÍ Y COMPÁRTELOS
-- ============================================================
