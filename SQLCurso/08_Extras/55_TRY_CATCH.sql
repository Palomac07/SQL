-- TRY/CATCH es un mecanismo para capturar errores.
--Sintaxis básica:
BEGIN TRY           -- Código que puede fallar
    ...
END TRY
BEGIN CATCH          -- Código que se ejecuta si hay error
    ...
END CATCH
-- Sin TRY/CATCH, un error detendría tod el script.

-- Es muy ÚTIL EN TRANSACCIONES, para deshacer cambios si algo falla.
BEGIN TRY
    BEGIN TRANSACTION;

    -- Operación 1
    UPDATE cuenta SET saldo = saldo - 100 WHERE id = 1;

    -- Operación 2 (puede fallar)
    UPDATE cuenta SET saldo = saldo + 100 WHERE id = 2;

    -- Si llegamos acá, tod salió bien.
    COMMIT;
    PRINT 'Transacción completada';

END TRY
BEGIN CATCH
    -- Si algo falló, deshacer TOD.
    ROLLBACK;
    PRINT 'Error: ' + ERROR_MESSAGE();
    PRINT 'Transacción revertida';
END CATCH

-- Para generar errores personalizados (va dentro del TRY):
RAISERROR('mensaje', severidad, estado);
-- mensaje: Texto del error
-- severidad: 0-25 (11-19 son errores capturables por TRY/CATCH) SE USA 16 EN GENERAL.
-- estado: 1-255 (para diferenciar errores similares)

-- Para devolver el estado actual de la transacción en la sesión:
XACT_STATE();
-- Se usa dentro del CATCH.
-- Sirve para saber si podes hacer COMMIT o solo ROLLBACK en un bloque CATCH.
-- Devuelve:
-- 1 = Hay una transacción activa y confirmable (puede hacer COMMIT).
-- O = No hay transacción activa.
-- -1 = Hay una transacción no confirmable (sólo puede hacer ROLLBACK).


