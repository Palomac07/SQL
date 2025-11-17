-- El @ se usa para declarar variables y parámetros en SQL Server.
-- DECLARE se usa para declarar variables, es decir, crear espacios en memoria para almacenar datos temporales.

-- 1) Variables locales:
-- Son variables que se usan dentro de un procedimiento o script.
-- Declarar variables
DECLARE @nombre VARCHAR(50);
DECLARE @edad INT;
DECLARE @saldo DECIMAL(10,2);

-- Asignar valores
SET @nombre = 'María';
SET @edad = 25;
SET @saldo = 1500.50;

-- Usar en consultas
SELECT * FROM usuario WHERE nombreUsuario = @nombre;
SELECT @edad AS EdadUsuario;

-- 2) Parámetros de procedimientos:
-- Variables que se reciben desde fuera del procedimiento.
CREATE PROCEDURE p_buscarPorNacionalidad
@nacionalidad VARCHAR(50),  -- Parámetro de entrada.
@edadMinima INT = 18        -- Parámetro con valor por defecto.
AS
BEGIN
    SELECT * FROM usuario
    WHERE nacionalidadUsuario = @nacionalidad
    AND edadUsuario >= @edadMinima;
END;

-- Ejecutar pasando valores
EXEC p_buscarPorNacionalidad @nacionalidad = 'Argentina', @edadMinima = 21;

-- 3) Parámetros output:
-- Variables que devuelven valores desde el procedimiento.
Variables que devuelven valores desde el procedimiento:

CREATE PROCEDURE p_contarUsuarios
@nacionalidad VARCHAR(50),
@total INT OUTPUT  -- Este parámetro devuelve un valor.
AS
BEGIN
    SELECT @total = COUNT(*)
    FROM usuario
    WHERE nacionalidadUsuario = @nacionalidad;
END;

-- Usar el parámetro OUTPUT
DECLARE @cantidad INT;
EXEC p_contarUsuarios @nacionalidad = 'Chile', @total = @cantidad
OUTPUT;
SELECT @cantidad AS TotalChilenos;  -- Muestra el resultado.

-- 4) Variables en scripts:
-- Un script es un archivo o conjunto de instrucciones SQL que se ejecutan en secuencia.

-- Calcular algo y guardarlo en una variable.
DECLARE @promedio DECIMAL(5,2);
SELECT @promedio = AVG(edadUsuario)
FROM usuario;
PRINT 'El promedio de edad es: ' + CAST(@promedio AS VARCHAR);

-- Usar en condicionales.
IF @promedio > 25
    PRINT 'Usuarios mayores en promedio';
ELSE
    PRINT 'Usuarios jóvenes en promedio';

-- 5) Múltiples declaraciones:
-- Declarar varias a la vez.
DECLARE
    @id INT,
    @nombre VARCHAR(50),
    @fecha DATETIME = GETDATE();  -- Con valor inicial.

-- Asignar desde una consulta.
SELECT
    @id = id,
    @nombre = nombreUsuario
FROM usuario
WHERE id = 1;

SELECT @id AS ID, @nombre AS Nombre, @fecha AS Fecha;


-- DIFERENCIA = @variable vs columnas:

-- @nombre es una VARIABLE.
DECLARE @nombre VARCHAR(50) = 'Juan';

-- nombre es una COLUMNA de la tabla.
SELECT nombre FROM tabla;

-- Comparar variable con columna
SELECT * FROM usuario WHERE nombreUsuario = @nombre;