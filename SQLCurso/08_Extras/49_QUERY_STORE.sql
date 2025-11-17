-- Es una característica que graba el historial de consultas, planes de ejecución y estadísticas de rendimiento de la DB. Es como una "caja negra".
-- Sirve para:
-- Ver qué consultas son lentas.
-- Indentificar regresiones de rendimiento (consultas que antes eran rápidas y ahora son lentas).
-- Comparar planes de ejecución en el tiempo.
-- Forzar un plan de ejecución específico.
-- Analizar el rendimiento histórico.

-- Activar:
ALTER DATABASE MiBaseDatos
SET QUERY_STORE = ON;

-- En SQL Server Management Studio:
-- 1. Expande la base de datos
-- 2. Busca la carpeta "Query Store"
-- 3. Verás reportes como:
--    - Top Resource Consuming Queries
--    - Queries With High Variation
--    - Regressed Queries
--    - Tracked Queries