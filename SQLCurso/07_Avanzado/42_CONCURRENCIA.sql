-- Tampoco la usamos, lo guardo para que me quede.
-- Se da cuando varios usuarios o procesos acceden y modifican la misma base de datos al mismo tiempo.
-- La base de datos permite configurar diferentes reglas de concurrencia.

-- Ejemplo:
 Imagina que dos personas intentan comprar el último asiento de un avión simultáneamente:

  -- Usuario A (al mismo tiempo que B)
SELECT asientosDisponibles FROM vuelo WHERE id = 1;  -- Ve: 1 asiento
UPDATE vuelo SET asientosDisponibles = 0 WHERE id = 1;  -- Compra

  -- Usuario B (al mismo tiempo que A)
SELECT asientosDisponibles FROM vuelo WHERE id = 1;  -- Ve: 1 asiento
UPDATE vuelo SET asientosDisponibles = 0 WHERE id = 1;  -- Compra

-- Resultado: Ambos compraron el mismo asiento.

-- Soluciones: Niveles de aislamiento
-- SQL Server ofrece diferentes niveles para controlar cómo las transacciones interactúan:
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  -- Más rápido, menos seguro
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;    -- Por defecto
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- Más seguro
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;      -- Máxima seguridad, más lento

-- Solución con LOCKS (Bloqueos)
BEGIN TRANSACTION;
    -- Bloquear la fila para que nadie más la modifique
    SELECT asientosDisponibles
    FROM vuelo WITH (UPDLOCK, ROWLOCK)
    WHERE id = 1;
    -- Ahora nadie más puede modificar esta fila hasta que termine .
    IF asientosDisponibles > 0
    BEGIN
        UPDATE vuelo SET asientosDisponibles = asientosDisponibles - 1
        WHERE id = 1;
    END
COMMIT;

--Ejemplo práctico: Sistema de reservas
CREATE PROCEDURE p_reservarAsiento
    @vueloId INT,
    @usuarioId INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @disponibles INT;

        -- Bloquear para evitar que otros reserven al mismo tiempo
        SELECT @disponibles = asientosDisponibles
        FROM vuelo WITH (UPDLOCK)
        WHERE id = @vueloId;

        IF @disponibles > 0
        BEGIN
            -- Reducir asientos
            UPDATE vuelo
            SET asientosDisponibles = asientosDisponibles - 1
            WHERE id = @vueloId;

            -- Registrar reserva
            INSERT INTO reservas (vueloId, usuarioId, fecha)
            VALUES (@vueloId, @usuarioId, GETDATE());

            COMMIT;
            PRINT 'Reserva exitosa';
        END
        ELSE
        BEGIN
            ROLLBACK;
            PRINT 'No hay asientos disponibles';
        END

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH;
END;