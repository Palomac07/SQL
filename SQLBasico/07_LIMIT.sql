-- Muestra las (limite) primeras filas del resultado.
SELECT * FROM nombreTabla LIMIT limite(numero); -- Muestra las primeras (limite) filas de la tabla.
SELECT * FROM nombreTabla WHERE NOT nombreColumna1 = criterio1 OR nombreColumna2= criterio2 LIMIT limite; -- Muestra las (limite) primeras filas de la
-- tabla donde la columna 1 no cumpla el criterio 1, o la columna 2 cumpla el criterio 2, o pasen ambas cosas.
