-- AS sirve para establecer (cuando estamos recuperando un dato) un nombre distinto al que ya tiene.
SELECT nombreColumna1,nombreColumna2 AS nuevoNombre FROM nombreTabla WHERE nombreColumnaCondicional BETWEEN minimo AND maximo; -- Muestra las filas de
-- las columnas indicadas de la tabla, donde el valor de la columna condicional está entre minimo y maximo. Lo que cambia es que en la tabla resultado
-- va a mostrar la columna 2 con un nuevo nombre.
-- Por ejemplo nombreColumna2 = initDate, y yo lo quiero mostrar de una forma más legible, entonces nuevoNombre = 'fecha de inicio'. (Importante no olvidar comillas)
-- También sirve si estoy trabajando con otras tablas y quiero cambiar el nombre de una de las columnas para que coincidan y sea más sencillo.

SELECT nombreColumna AS nuevoNombre FROM nombreTabla WHERE nombreColumnaCondicional = 'criterio';

-- Para concatenar columnas: CONCAT
SELECT CONCAT(nombreColuma1, nombreColumna2) FROM nombreTabla; -- Muestra ambas columnas juntas (sin espacios) bajo el nombre CONCAT(nombreColumna1, nombreColumna2).
SELECT CONCAT(nombreColuma1, ' ', nombreColumna2) FROM nombreTabla; -- Agrega un espacio.
SELECT CONCAT('Columna 1: ', nombreColumna1, ' Columna 2: ', nombreColumna2) FROM nombreTabla; -- Agrega títulos dentro de cada celda.
SELECT CONCAT(nombreColuma1, nombreColumna2) AS nuevoNombre FROM nombreTabla; -- Para elegir el título de la tabla generada.
