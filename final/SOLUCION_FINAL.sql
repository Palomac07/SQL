/*
===============================================================
 EXAMEN FINAL ADELANTADO - PARTE PRÁCTICA (TEMA 3)
 Ingeniero de Datos Jr. - Soluciones Informáticas SRL
 Base de Datos: DF_Eval_Junior

 SOLUCIÓN COMPLETA
===============================================================
*/

USE DF_Eval_Junior;
GO

/*
===============================================================
 TABLA DE ALERTAS
===============================================================
*/
-- Crear tabla AlertaEjecucion si no existe
IF OBJECT_ID('AlertaEjecucion', 'U') IS NULL
BEGIN
    CREATE TABLE AlertaEjecucion (
        idAlerta      INT IDENTITY PRIMARY KEY,
        idEjecucion   INT,
        mensaje       VARCHAR(200),
        fechaHora     DATETIME
    );
    PRINT 'Tabla AlertaEjecucion creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Tabla AlertaEjecucion ya existe.';
END
GO

/*
===============================================================
 EJERCICIO 1 - Procedimiento almacenado sp_AltaEjecucionPipeline
===============================================================
Crear un procedimiento almacenado que:
a. Verifique que el idPipeline exista.
b. Inserte una ejecución en EjecucionPipeline (idEjecucion = IDENTITY).
c. Devuelva el ID generado mediante SCOPE_IDENTITY() vía parámetro OUTPUT.
d. Maneje errores con TRY-CATCH y relance con THROW.
*/

CREATE OR ALTER PROCEDURE sp_AltaEjecucionPipeline
    @idPipeline INT,
    @fechaInicio DATETIME,
    @fechaFin DATETIME,
    @filasLeidas INT,
    @filasCargadas INT,
    @estado VARCHAR(10),
    @idEjecucionGenerado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- a. Verificar que el idPipeline exista
        IF NOT EXISTS (SELECT 1 FROM Pipeline WHERE idPipeline = @idPipeline)
        BEGIN
            THROW 50001, 'El pipeline especificado no existe en la base de datos.', 1;
        END

        -- b. Insertar una ejecución en EjecucionPipeline
        INSERT INTO EjecucionPipeline (idPipeline, fechaInicio, fechaFin, filasLeidas, filasCargadas, estado)
        VALUES (@idPipeline, @fechaInicio, @fechaFin, @filasLeidas, @filasCargadas, @estado);

        -- c. Devolver el ID generado mediante SCOPE_IDENTITY() vía parámetro OUTPUT
        SET @idEjecucionGenerado = SCOPE_IDENTITY();

        PRINT 'Ejecución registrada correctamente con ID: ' + CAST(@idEjecucionGenerado AS VARCHAR(10));

    END TRY
    BEGIN CATCH
        -- d. Manejar errores con TRY-CATCH y relanzar con THROW
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- Relanzar el error hacia el cliente
        THROW;
    END CATCH
END;
GO

/*
===============================================================
 EJERCICIO 2 - Trigger trg_ControlarEjecucionPipeline
===============================================================
Crear un trigger AFTER INSERT sobre EjecucionPipeline que:
a. Para cada fila insertada, calcule el porcentaje de éxito.
b. Si porcentajeExito < 80, insertar alerta.
c. Si porcentajeExito < 50, insertar alerta + ROLLBACK + error.
d. Debe manejar múltiples filas (NO cursores).
*/

CREATE OR ALTER TRIGGER trg_ControlarEjecucionPipeline
ON EjecucionPipeline
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para verificar si hay ejecuciones críticas
    DECLARE @hayEjecucionesCriticas BIT = 0;
    DECLARE @mensajeError NVARCHAR(500);

    -- Calcular porcentaje de éxito para todas las filas insertadas
    -- y detectar si hay ejecuciones críticas (porcentaje < 50)
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE
            CASE
                WHEN filasLeidas = 0 THEN 0
                ELSE (filasCargadas * 100.0) / filasLeidas
            END < 50
    )
    BEGIN
        SET @hayEjecucionesCriticas = 1;
    END

    -- b. Insertar alertas para ejecuciones con porcentaje < 80
    INSERT INTO AlertaEjecucion (idEjecucion, mensaje, fechaHora)
    SELECT
        i.idEjecucion,
        'Ejecución con porcentaje de éxito bajo: ' +
        CAST(
            CASE
                WHEN i.filasLeidas = 0 THEN 0
                ELSE CAST((i.filasCargadas * 100.0) / i.filasLeidas AS DECIMAL(5,2))
            END AS VARCHAR(10)
        ) + '%',
        GETDATE()
    FROM inserted i
    WHERE
        CASE
            WHEN i.filasLeidas = 0 THEN 0
            ELSE (i.filasCargadas * 100.0) / i.filasLeidas
        END < 80;

    -- c. Si hay ejecuciones críticas (porcentaje < 50), cancelar operación
    IF @hayEjecucionesCriticas = 1
    BEGIN
        -- Preparar mensaje de error con información detallada
        SELECT @mensajeError = STRING_AGG(
            'ID Ejecución: ' + CAST(idEjecucion AS VARCHAR(10)) +
            ' - Porcentaje: ' +
            CAST(
                CASE
                    WHEN filasLeidas = 0 THEN 0
                    ELSE CAST((filasCargadas * 100.0) / filasLeidas AS DECIMAL(5,2))
                END AS VARCHAR(10)
            ) + '%',
            '; '
        )
        FROM inserted
        WHERE
            CASE
                WHEN filasLeidas = 0 THEN 0
                ELSE (filasCargadas * 100.0) / filasLeidas
            END < 50;

        -- Cancelar la operación
        ROLLBACK TRANSACTION;

        -- Lanzar error
        DECLARE @errorMsg NVARCHAR(500) = 'Ejecución crítica detectada (porcentaje < 50%). ' + @mensajeError;
        THROW 50002, @errorMsg, 1;
    END
END;
GO

/*
===============================================================
 SCRIPTS DE PRUEBA
===============================================================
*/

PRINT '======================================';
PRINT 'PRUEBA 1: Ejecución exitosa (>80%)';
PRINT '======================================';
DECLARE @idGenerado1 INT;
EXEC sp_AltaEjecucionPipeline
    @idPipeline = 10,
    @fechaInicio = '2025-01-15 10:00',
    @fechaFin = '2025-01-15 10:05',
    @filasLeidas = 10000,
    @filasCargadas = 9500,  -- 95% éxito
    @estado = 'OK',
    @idEjecucionGenerado = @idGenerado1 OUTPUT;
PRINT 'ID Generado: ' + CAST(@idGenerado1 AS VARCHAR(10));
GO

PRINT '';
PRINT '======================================';
PRINT 'PRUEBA 2: Ejecución con alerta (70% < 80%)';
PRINT '======================================';
DECLARE @idGenerado2 INT;
EXEC sp_AltaEjecucionPipeline
    @idPipeline = 10,
    @fechaInicio = '2025-01-15 11:00',
    @fechaFin = '2025-01-15 11:05',
    @filasLeidas = 10000,
    @filasCargadas = 7000,  -- 70% éxito - debe generar alerta
    @estado = 'OK',
    @idEjecucionGenerado = @idGenerado2 OUTPUT;
PRINT 'ID Generado: ' + CAST(@idGenerado2 AS VARCHAR(10));
GO

PRINT '';
PRINT '======================================';
PRINT 'PRUEBA 3: Ejecución crítica (30% < 50%)';
PRINT 'Esta debe ser rechazada con ROLLBACK';
PRINT '======================================';
BEGIN TRY
    DECLARE @idGenerado3 INT;
    EXEC sp_AltaEjecucionPipeline
        @idPipeline = 10,
        @fechaInicio = '2025-01-15 12:00',
        @fechaFin = '2025-01-15 12:05',
        @filasLeidas = 10000,
        @filasCargadas = 3000,  -- 30% éxito - debe ser rechazada
        @estado = 'ERROR',
        @idEjecucionGenerado = @idGenerado3 OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'ERROR CAPTURADO (esperado):';
    PRINT '  Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '  Mensaje: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '';
PRINT '======================================';
PRINT 'PRUEBA 4: Pipeline inexistente';
PRINT '======================================';
BEGIN TRY
    DECLARE @idGenerado4 INT;
    EXEC sp_AltaEjecucionPipeline
        @idPipeline = 999,  -- No existe
        @fechaInicio = '2025-01-15 13:00',
        @fechaFin = '2025-01-15 13:05',
        @filasLeidas = 1000,
        @filasCargadas = 1000,
        @estado = 'OK',
        @idEjecucionGenerado = @idGenerado4 OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'ERROR CAPTURADO (esperado):';
    PRINT '  Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '  Mensaje: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '';
PRINT '======================================';
PRINT 'PRUEBA 5: Ejecución con 0 filas leídas';
PRINT '======================================';
DECLARE @idGenerado5 INT;
EXEC sp_AltaEjecucionPipeline
    @idPipeline = 10,
    @fechaInicio = '2025-01-15 14:00',
    @fechaFin = '2025-01-15 14:05',
    @filasLeidas = 0,  -- 0 filas leídas = 0% éxito
    @filasCargadas = 0,
    @estado = 'ERROR',
    @idEjecucionGenerado = @idGenerado5 OUTPUT;
GO

-- Consultar resultados
PRINT '';
PRINT '======================================';
PRINT 'EJECUCIONES REGISTRADAS';
PRINT '======================================';
SELECT
    idEjecucion,
    idPipeline,
    filasLeidas,
    filasCargadas,
    CASE
        WHEN filasLeidas = 0 THEN 0
        ELSE CAST((filasCargadas * 100.0) / filasLeidas AS DECIMAL(5,2))
    END AS PorcentajeExito,
    estado,
    fechaInicio
FROM EjecucionPipeline
ORDER BY idEjecucion DESC;
GO

PRINT '';
PRINT '======================================';
PRINT 'ALERTAS GENERADAS';
PRINT '======================================';
SELECT
    a.idAlerta,
    a.idEjecucion,
    a.mensaje,
    a.fechaHora
FROM AlertaEjecucion a
ORDER BY a.idAlerta DESC;
GO
