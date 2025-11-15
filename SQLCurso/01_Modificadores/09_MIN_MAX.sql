-- Seleccionar mínimos o máximos.
SELECT MAX(nombreColumna) FROM nombreTabla; -- Muestra el máximo valor de la columna.
SELECT MIN(nombreColumna) FROM nombreTabla; -- Muestra el mínimo valor de la columna.

-- IMPORTANTE: No se puede usar asterisco para mostrar todas las columnas, solo se obtiene ese campo.
-- Si quisiera buscar, por ejemplo, la edad máxima y además saber el nombre del usuario que corresponde a ese valor, haría:
SELECT nombreUsuario, edadUsuario  FROM usuarios WHERE edadUsuario = (SELECT MAX(edadUsuario) FROM usuarios);

-- EXTRA: Otra forma usando LIMIT, para entender que hay varias formas de llagar al mismo resultado:
SELECT nombreUsuario, edadUsuario FROM usuarios ORDER BY edadUsuario DESC LIMIT 1; -- Esta opción no es la más intuitiva pero sirve.

-- En SQL Server (la forma que yo me había imaginado, la más intuitiva):
DECLARE @edadMaxima INT;
SET @edadMaxima = (SELECT MAX(edadUsuario) FROM usuarios);
SELECT nombreUsuario FROM usuarios WHERE edadUsuario = @edadMaxima;
