-- Una función es un objeto de base de datos que ejecuta código y devuelve un valor. Similar a SP, pero con diferencias importantes.
-- Es SOLO DE LECTURA, no modifica datos. PROCEDURE SÍ PUEDE MODIFICAR.

-- SI SOLO LEES: FUNCTION
-- SI MODIFICAS: STORED PROCEDURE
-- SI DUDAS: STORED PROCEDURE (más flexible).


-- Pueden ser:

-- 1) Scalar = Devuelven un sólo valor (número, texto, fecha, etc.).
--Sintaxis
CREATE FUNCTION nombreFuncion (@parametros)
RETURNS tipoDato
AS
BEGIN
    -- Código
    RETURN valor;
END;
GO
-- Usar la función
SELECT nombreFuncion(@parametro) AS RESULTADO;

-- 2) Table-Valued = Devuelven una tabla.
-- Ejemplo: Función que devuelve usuarios por país:
CREATE FUNCTION f_usuariosPorPais (@pais VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT id, nombre, email, edad
    FROM usuario
    WHERE nacionalidad = @pais
);
GO

-- 3) Funciones del sistema = Ya incluidas en SQL Server. Hay muchas, les saqué captura si las quieren me las piden.
-- Usamos algunas como CAST, CONCAT y GETDATE.
