-- Es una opción que controla si las estadísticas de las tablas se actualizan automáticamente cuando los datos cambian significativamente.

-- Las estadísticas son información que SQL Server recopila sobre la distribución de datos en columnas e índices. El optimizador de consultas
-- las usa para elegir el mejor plan de ejecución.
-- Por ejemplo:
-- ¿Cuántas filas tiene la tabla?.
-- ¿Cuántos valores únicos hay en una columna?.
-- ¿Cómo están distribuidos los datos?.

-- ACTIVADO (ON) - Por defecto y recomendado.
ALTER DATABASE MiBaseDatos
SET AUTO_UPDATE_STATISTICS ON;
-- Actualiza estadísticas automáticamente cuando hay cambios significativos.

-- DESACTIVADO (OFF)
ALTER DATABASE MiBaseDatos
SET AUTO_UPDATE_STATISTICS ON;
-- útil en escenarios muy específicos de data warehouse (almacén de datos).

-- En una tabla de < 500 filas, las estadísticas se actualizan cuando se llega a 500 cambios.
-- En una tabla de > 500 filas, se atualizan cuando hay (500 + 20% del total de filas) cambios.