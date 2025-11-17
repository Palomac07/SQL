BEGIN TRAN
COMMIT
ROLLBACK
Es un grupo de operaciones que se ejecutan como una unidad. O se ejecutan TODAS correctamente, o NINGUNA se aplica.

BEGIN TRAN;  -- Inicia una transacción. Tod lo que sigue se puede deshacer con ROLLBACK si algo falla.

    BEGIN TRY  -- Empieza el bloque que puede fallar.
        INSERT INTO dbo.Pedido(idCliente, fecha, precioTotal, estado)  -- Inserta en la tabla Pedido del esquema dbo, las columnas idCliente, fecha, precioTotal, estado.
        VALUES(@idCliente, CAST(GETDATE() AS DATE), @cantidad * @precioUnitario, 'Confirmado'); -- @idCliente = variable con el id del cliente (parámetro del procedimiento).
        -- CAST(GETDATE() AS DATE = Convierte la fecha y hora actual a sólo fecha.
        -- @cantidad * @precioUnitario = Calcula el precio total del pedido.
        -- 'Confirmado' = Estado del pedido (valor fijo).
        SET @idPedido = SCOPE_IDENTITY(); -- Obtiene el ID auto-generado del INSERT anterior. Lo guarda en la variable @idPedido.
        -- Este ID se va a usar ´para relacionar el detalle del pedido.

        INSERT INTO dbo.DetallePedido(idPedido, idProducto, cantidad, precioUnitario) -- Insert el detalle del pedido.
        VALUES(@idPedido, @idProducto, @cantidad, @precioUnitario);
        -- El id capturado, la variable con el id del producto, la cantidad de productos, y el precio por unidad.

        UPDATE dbo.Producto -- Actualiza la tabla de productos.
        SET stockDisponible = stockDisponible - @cantidad -- Resta la cantidad vendida del stock.
        WHERE idProducto = @idProducto; -- Sólo actualiza el producto específico.

        INSERT INTO dbo.Alerta(tipo, descripcion, fecha) -- Registra una alerta en el sistema.
        VALUES ('Stock', 'Se registró un nuevo pedido.', GETDATE()); -- Stock es el tipo de alerta, después viene el mensaje descriptivo, y después la fecha y hora del momento.

        COMMIT TRAN; -- Confirma todos los cambios hechos en la transacción (los 4 INSERT/UPDATE se hacen permanentes).
        PRINT('Pedido registrado correctamente.'); -- útil para debug o confirmar que tod salió bien.
    END TRY  -- Si llegó acá, es porque no hubo errores.
    BEGIN CATCH  -- Se ejecuta sólo si hubo un error en el TRY.
        IF XACT_STATE() <> 0 ROLLBACK TRAN; -- Si hay transacción activa (1 o -1), deshace todos los cambios de la transacción para evitar error.
        -- Que la transacción esté activa significa que se ejecutó BEGING TRANS pero todavía no se hizo COMMIT ni ROLLBACk. Esto bloquea recursos y consume memoria.
        -- En este caso, si está activa es porque no se llegó a COMMIT, hubo un error antes. Por eso hace ROLLBACK deshaciendo los cambios.

        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE(); -- Crea variable local con el tipo de error que ocurrió.
        RAISERROR('Error en sp_RegistrarPedido: %s', 16, 1, @msg); -- Lanza el error personalizado.
        RETURN;  -- Sale del procedimiento.
    END CATCH  -- Termina el bloque CATCH.
END  -- Termina el SP.
GO  -- Separa lotes.
