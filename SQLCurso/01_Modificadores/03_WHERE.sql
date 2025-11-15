-- Acota los resultados en base a un criterio.
SELECT * FROM nombreTabla WHERE nombreColumna = criterio; -- Muestra todas las filas de la tabla donde la columna condicional cumple con el criterio.
SELECT nombreColumnaIndicada FROM nombreTabla WHERE nombreColumnaCondicional = criterio; -- Muestra todas las filas de la columna indicada donde la
-- columna condicional cumple con el criterio.
-- La columna indicada y la condicional pueden o no ser la misma.
SELECT DISTINCT nombreColumnaIndicada FROM nombreTabla WHERE nombreColumnaCondicional = criterio; -- Muestra los valores sin repetir de la columna
-- indicada donde la columna condicional cumple con el criterio.
