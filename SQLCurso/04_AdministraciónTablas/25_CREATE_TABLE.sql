CREATE TABLE nombreTablaNueva (
    nombreColumna1 tipoDato1 (constraints1),
    nombreColumna2 tipoDato2 (constraints2),
    nombreColumna3 tipoDato3 (constraints3),
    (...)                                    -- en la última no va ,
);
-- Tipos de datos comunes:
-- INT (entero de tamaño estándar).
-- DECIMAL(p,s) (número de preción y escala fijas).
-- FLOAT o REAL (para cáculos donde la precisión no es necesaria).
-- VARCHAR(long max) (cadena de caracteres de tamaño variable).
-- CHAR() (cadena de caracteres de longitud fija).
-- DATE (fecha formato AAAA-MM-DD).
-- TIME (hora formato HH:MM:SS).
-- DATETIME (fecha y hora).

-- RESTRICCIONES:
-- NOT NULL (el valor no puede ser nulo).
-- UNIQUE (el valor no se puede repetir, se usa para IDs).
-- PK (clave primaria, identificador principal de la tabla, suele ser el ID. Se usa para establecer relaciones con otras tablas).
-- CHECK(nombreColumna = criterio) (se usa como verificación de que se cumpla algo. No afecta la creación de la tabla pero si futuras insersiones
-- o modificaciones).
-- DEFAULT (si no se agrega ningún valor, tiene uno por defecto). Por ejemplo hora TIME DEFAULT CURRENT_TIME().
-- AUTO_INCREMENT (cada vez que se crea una nueva fila y no se completa el dato, por ejemplo ID, se usa el último dato de la columna +1).