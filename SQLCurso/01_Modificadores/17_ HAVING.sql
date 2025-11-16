-- Cuando la clave no se puede usar en funciones agregadas (WHERE no puede). En SQL Server se usa si o sí con GROUP BY.
-- Se trata de un filtro, pero a diferencia de WHERE, que se filtra antes de agrupar, HAVING filtra después de agrupar.
-- Se usa con COUNT, SUM, AVG.

-- NOTA: en todos los casos de condicionales donde pongo =, me refiero a cualquier operador de comparación.
SELECT nombreColumna, COUNT(*) as nuevoNombre FROM nombreTabla GROUP BY nombreColumna HAVING COUNT(*) =  criterio; -- Muestra las filas de
-- nombreColumna que cumplen el criterio, con el nombre elegido.

-- Por ejemplo: Mostrar categorías que tienen más de 5 productos
SELECT categoria, COUNT(*) as total FROM productos GROUP BY categoria HAVING COUNT(*) > 5;
-- IMPORTANTE - ORDEN DE EJECUCIÓN (lo adiviné bien wow):
-- Acá podemos ver que primero GROUP BY agrupa por categoría, COUNT(*) cuenta la cantidad de productos por categoría, y luego HAVING filtra los
-- resultados que cumplan la condición. La tabla que se va a imprimir va a tener el nombre total, gracias a AS. Si no hubieramos puesto AS se llamaría
-- COUNT(*).

-- Consejo: siempre usar AS para aclarar.

SELECT nombreColumna, COUNT(*) as nuevoNombre FROM nombreTabla GROUP BY nombreColumna HAVING COUNT(*) =  criterio AND AVG(nombreColumna) = criterio;
-- Muestra las filas de nombreColumna que cumplen ambos criterios, con el nombre elegido.

-- Combinando WHERE y HAVING:
SELECT nombreColumna1, COUNT(*) as nuevoNombre FROM nombreTabla WHERE nombreColumnaCondicional = criterio  GROUP BY nombreColumna1
HAVING COUNT(*) = criterio;
-- Primero se filtran las filas de la columna condiconal que cumplan con la condición WHERE. Luego GROUP BY agrupa en base a los diferentes valores de
-- Columna 1, COUNT(*) cuenta la cantidad de veces que aparece cada uno, y por último se filtran los que cumplan con la condición HAVING.

-- Ejemplo: Productos activos (WHERE) agrupados por categoría, mostrando sólo categorías con más de tres productos.
SELECT categoria, COUNT(*) as total FROM productos WHERE estado = 'activo'  GROUP BY categoria HAVING COUNT(*) > 3;