-- Agrupa filas que tienen mismos valores en filas resumen. Se encarga de buscar algo concreto.
SELECT * FROM nombreTabla GROUP BY nombreColumna; -- Da error. Hay que establecer un criterio.
-- El comando con el que agrupamos es el comando con el que ejecutamos la función:
SELECT MAX(nombreColumna1) FROM nombreTabla GROUP BY nombreColumna1; -- Muestra TODOS los MAX (basicamente todos los valores de la columna sin repetir,
-- incluyendo null).
SELECT COUNT(nombreColumna1) FROM nombreTabla GROUP BY nombreColumna1; -- Muestra la cantidad de veces que aparece cada valor en la columna.
-- IMPORTANTE PARA TODOS ESTOS CASOS: La tabla resultado siempre tiene como título la operación que estamos realizando (por ejemplo COUNT(nombreColumna)
-- o simplemente nombreColumna si no le aplicamos nada), si queremos cambiar el nombre usamos AS.
SELECT COUNT(nombreColumna1), nombreColumna1 FROM nombreTabla GROUP BY nombreColumna1; -- Muestra la cantidad de veces que aparece cada valor en la
-- columna, y en la columna de al lado el valor correspondiente.
SELECT COUNT(nombreColumna1), nombreColumna1 FROM nombreTabla GROUP BY nombreColumna1 ORDER BY nombreColumna1; -- Muestra la cantidad de veces que
-- aparece cada valor en la columna, y en la columna de al lado el valor correspondiente. Los ordena en orden ascendente (por defecto) en base a los
-- valores de nombreColumna1 (los valores del GROUP BY).
SELECT COUNT(nombreColumna1), nombreColumna1 FROM nombreTabla WHERE nombreColumna1 = criterio GROUP BY nombreColumna1 ORDER BY nombreColumna1; --
-- Muestra, para los valores de la columna condicional que cumplan el criterio,  la cantidad de veces que aparece cada valor en la columna, y en la
-- columna de al lado el valor correspondiente. Los ordena en orden ascendente (por defecto) en base a los valores de nombreColumna1 (los valores del
-- GROUP BY).
-- NOTA: Estoy usando siempre columna 1 porque quiero, pero se pueden cambiar depende lo que queramos mostrar, en base a qué queramos ordenar, en
-- base a qué filtrar, etc.