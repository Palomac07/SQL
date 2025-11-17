-- Representación virtual de una o más tablas. Es el resultado de una consulta representado en formato tabla.
-- Se usa para cosas que se consultan mucho en la aplicación.
-- NO ejecuta código, sólo almacena SELECT. Solo puede tener UN SELECT. No acepta parámetros. No puede tener lógica (IF, WHILE).

-- Ejemplo: mostrar una lista de los usuarios menores de edad, y su edad.
CREATE VIEW v_usuariosMenores
SELECT idUsuario, nombreUsuario, edadUsuario
FROM usuario
WHERE edadUsuario < 18
ORDER BY edadUsuario DESC;         -- Los va a mostrar de mayor a menor.

-- Para consultarla:
SELECT * FROM v_usuariosMenores;

-- Básicamente, está reemplazando esto:
SELECT idUsuario, nombreUsuario, edadUsuario
FROM usuario
WHERE edadUsuario < 18
ORDER BY edadUsuario DESC;
-- Por eso es muy conveniente para consultas que se hacen muy seguido, para no tener que escribir eso siempre.
-- Obviamente se suele usar para consultas un poco más complejas, esto es un ejemplo

-- Si se actualiza una tabla, la vista se actualiza automáticamente.

-- Si la queremos eliminar:
DROP VIEW v_usuariosMenores;