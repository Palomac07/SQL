-- AND = Concatenación. Ambas deben cumplirse.
SELECT * FROM nombreTabla WHERE nombreColumna1 = criterio1 AND nombreColumna2 = criterio2; -- Muestra todas las filas de la tabla donde las columnas
-- condiconales cumplan con los criterios.
-- OR = Opción. Se cumple una o la otra (o ambas).
SELECT * FROM nombreTabla WHERE nombreColumna1 = criterio1 OR nombreColumna2 = criterio2; -- Muestra todas las filas de la tabla donde una o ambas
-- columnas condicionales cumplan con su criterio correspondiente.
-- NOT = Negación.
SELECT * FROM nombreTabla WHERE NOT nombreColumna = criterio; -- Devuelve todas las filas de la tabla donde el valor de la columna condicional no
-- coincida con el criterio.


