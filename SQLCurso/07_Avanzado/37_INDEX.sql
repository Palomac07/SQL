-- Estructura de datos que permite indexar la tabla para consultar datos y realizar operaciones más rápido. Mejora el rendimiento.
-- Hay diferentes tipos:
-- Primary = Vinculados con la PK
-- Unique == Aseguran que dos filas de la tabla no tengan valores duplicados.
-- Compuestos = Permiten que se utilizen dos o más columnas.

-- Hacen que la tabla pese más (ocupe más espacio), puede ser más ineficiente en la escritura.

-- Usualmente se crean automáticamente índices asociados a las claves primarias.

-- PASOS PARA CREAR UN ÍNDICE

-- 1) Ver la tabla para saber cómo operamos sobre ella:
SELECT * FROM nombreTabla;
-- Cosas a mirar: en base a qué columna se hace la búsqueda (por ejemplo curso se puede buscar por nombre).

-- 2) Crear el índice:
-- Opción a)
CREATE INDEX idx_nombreColumna ON nombreTabla(nombreColumna);

-- Opción b)
CREATE UNIQUE INDEX idx_nombreColumna ON nombreTabla(nombreColumna); -- Este por ejemplo tendría sentido para el nombre de un curso, pero no para el
-- nombre de una persona.

-- Opción c) Si queremos que tenga más campos, se pueden concatenar con comas:
CREATE INDEX idx_nombreColumna1_nombreColumna2 ON nombreTabla(nombreColumna1, nombreColumna2);
-- Por ejemplo para buscar una persona por nombre y apellido.

-- 3) Utilizarlo:
SELECT * FROM nombreTabla WHERE nombreColumna = 'texto';
-- Como se ve, no cambia nada en la forma de búsqueda, pero lo que va a hacer el índice es encontrar el dato mucho más rápido (se puede apreciar en
-- tablas muy grandes).

-- 4) Si queremos borrarlo:
DROP INDEX idx_nombreColumna ON nombreTabla;

-- Un índice puede ser:

-- 1) CLUSTERED =
-- Sólo puede haber uno por tabla, la PK lo crea automáticamente.
-- Almacena los datos en orden según el índice.
CREATE TABLE usuario (
    id INT PRIMARY KEY,  -- ← Crea índice CLUSTERED automáticamente
    nombre VARCHAR(50),
    email VARCHAR(100)
);

-- 2) NONCLUSTERED =
-- No reorganiza los datos físicamente. Crea una estructura separada que apunta a las filas.
-- Puede haber hasta 99 por tabla.
CREATE NONCLUSTERED INDEX idx_email
ON usuario(email);
-- Por defecto es NONCLUSTERED, porque el otro se usa para la PK.
