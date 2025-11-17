-- Función que devuelve el ID numérico único de un objeto de la DB (tabla, vista, procedimiento, función, etc.)
OBJECT_ID('nombre_objeto')

-- USOS

--  1. Verificar si un objeto existe:

-- Verificar si existe una tabla.
IF OBJECT_ID('usuario') IS NOT NULL
    PRINT 'La tabla usuario existe';
ELSE
    PRINT 'La tabla usuario NO existe';

-- Verificar antes de eliminar.
IF OBJECT_ID('p_menoresArgentinos') IS NOT NULL
     DROP PROCEDURE p_menoresArgentinos;

-- Se puede especificar el tipo de objeto (opcional):
OBJECT_ID('nombre_objeto', 'tipo')
-- Tabla = U.
-- Procedimiento = P.
-- Vista = V.
-- Función = FN.
-- Trigger = TR.
-- Clave primaria = PK.
-- Clave foránea = F.
-- Default = D.
-- Check = C.

-- 2. Obtener el ID de un objeto:

-- Obtener ID con esquema
SELECT OBJECT_ID('dbo.usuario');

-- Guardar en variable
DECLARE @tablaID INT;
SET @tablaID = OBJECT_ID('usuario');
SELECT @tablaID;