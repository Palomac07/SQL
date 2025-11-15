-- Ordena el resultado
SELECT * FROM nombreTabla ORDER BY nombreColumna; -- Devuelve toda la tabla ordenada de menor a mayor (orden predefinido) en base a la columna dada.
SELECT * FROM nombreTabla ORDER BY nombreColumna DESC; -- Devuelve toda la tabla odemada de mayor a menor en base a la columna dada.
SELECT * FROM nombreTabla ORDER BY nombreColumanASC; -- Devuelve toda la tabla odemada de menor a mayor en base a la columna dada.
SELECT nombreColumnaIndicada FROM nombreTabla ORDER BY nombreColumnaOrdenar; -- Devuelve la columna indicada ordenada de menor a mayor en base a la
-- columna a ordenar.
SELECT DISTINCT nombreColumnaIndicada FROM nombreTabla ORDER BY nombreColumnaOrdenar; -- Devuelve la columna indicada ordenada de menor a mayor en base
-- a la columna a ordenar, y sin repetir valores.
SELECT DISTINCT nombreColumnaIndicada FROM nombreTabla WHERE nombreColumnaCondicional = criterio ORDER BY nombreColumnaOrdenar; -- Devuelve los valores
-- de la columna indicada (ordenada de menor a mayor en base a la columna a ordenar) donde la columna condicional cumpla con el criterio, sin repetir
-- valores.
