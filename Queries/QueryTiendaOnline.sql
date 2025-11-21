/* =========================================
   1) Creaci�n de Base de Datos (si no existe)
   ========================================= */
IF DB_ID(N'TiendaOnline_NovaShop') IS NULL      -- Si el ID de la DB no existe...
-- La N es un prefijo que indica que la cadena de textos contiene caracteres Unicodeindica NVARCHAR texto Unicode (estándar que permite representar todos los caracteres de todos los idiomas del mundo).
BEGIN
    -- Crea una variable para guardar el comando SQL:
    DECLARE @sqlCreate NVARCHAR(MAX) = N'
    CREATE DATABASE [TiendaOnline_NovaShop]     -- Este es el comando.
    CONTAINMENT = NONE      -- La DB no es contenida (se ejecuta como una entidad independiente en el servidor SQL Server).
    ';
    EXEC(@sqlCreate);       -- Ejecuta el comando guardado en la variable.
END;        -- Esta es la única forma de crear una DB condicionalmente, porque SQL Server no permite CREATE DATABASE dentro de un IF.
GO      -- Separador de lotes, permite usar la DB en el siguiente batch.

ALTER DATABASE [TiendaOnline_NovaShop] SET COMPATIBILITY_LEVEL = 160;       -- Altera el nivel de compatibilidad (SQL Server 2022). Es para usar las funcionalidades de esta versión, como JSON.
GO

-- Ajustes de optimización:
ALTER DATABASE [TiendaOnline_NovaShop] SET AUTO_UPDATE_STATISTICS ON;       -- Actualiza automáticamene las estadísticas para optimizar consultas.
ALTER DATABASE [TiendaOnline_NovaShop] SET QUERY_STORE = ON;        -- Activa el almacén de consultas para monitoreo de rendimiento.
GO

/* =========================================
   2) Tablas base (solo si no existen)
   ========================================= */
IF OBJECT_ID(N'dbo.Cliente', N'U') IS NULL      -- OBJECT_ID verifica si un objecto existe en la DB. U es el tipo de objeto (tabla de usuario).
BEGIN
CREATE TABLE dbo.Cliente(
    idCliente       INT IDENTITY(1,1) PRIMARY KEY,      -- Columna autoincremental que empieza en 1 y aumenta de a 1. Es una clave primario (identificación única)
    nombre          NVARCHAR(50) NOT NULL,      -- NOT NULL = Campo obligatorio.
    apellido        NVARCHAR(50) NOT NULL,
    email           NVARCHAR(100) NOT NULL,
    telefono        NVARCHAR(20) NULL,      -- NULL = Campo opcional.
    estado          NVARCHAR(15) NULL CONSTRAINT DF_Cliente_estado DEFAULT('Activo')        -- Valor 'Activo' por defecto.
);
-- CREATE UNIQUE NONCLUSTERED INDEX UX_Cliente_email ON dbo.Cliente(email);        -- Indice separado, con punteros a la fila que corresponde el valor.
ALTER TABLE dbo.Cliente WITH CHECK ADD CONSTRAINT CK_Cliente_estado CHECK (estado IN ('Activo','Inactivo'));        -- CHECK= Validación.
END;
GO

IF OBJECT_ID(N'dbo.Categoria', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Categoria(
    idCategoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre      NVARCHAR(50) NOT NULL
);
END;
GO      -- Tabla con ID autoincremental y nombre de categoría.

IF OBJECT_ID(N'dbo.Producto', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Producto(
    idProducto       INT IDENTITY(1,1) PRIMARY KEY,
    nombre           NVARCHAR(100) NOT NULL,
    idCategoria      INT NULL,      -- FK hacia categoría (N:1) porque categoría no es UNIQUE.
    costoUnitario    DECIMAL(10,2) NULL CONSTRAINT CK_Producto_costo CHECK (costoUnitario >= 0),        -- Número decimal con 10 dígitos totales, 2 después del punto.
    precioVenta      DECIMAL(10,2) NULL CONSTRAINT CK_Producto_precioVenta CHECK (precioVenta >= 0),
    stockDisponible  INT NULL CONSTRAINT CK_Producto_stock CHECK (stockDisponible >= 0),
    estado           NVARCHAR(15) NULL CONSTRAINT DF_Producto_estado DEFAULT('Activo'),
    cupoLimite       INT NULL       -- Límite de unidades que se pueden vender (opcional por NULL).
);
ALTER TABLE dbo.Producto WITH CHECK ADD CONSTRAINT CK_Producto_estado CHECK (estado IN ('Activo','Inactivo'));
END;
GO      -- Verifica que el estado sea válido.

IF OBJECT_ID(N'dbo.Pedido', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Pedido(
    idPedido     INT IDENTITY(1,1) PRIMARY KEY,
    idCliente    INT NOT NULL,      -- Referencia hacia el cliente que hizo el pedido. FK (N:1).
    fecha        DATE NOT NULL,     -- Solo fecha, sin hora.
    precioTotal  DECIMAL(10,2) NULL CONSTRAINT CK_Pedido_precioTotal CHECK (precioTotal >= 0),
    estado       NVARCHAR(20) NULL CONSTRAINT DF_Pedido_estado DEFAULT('Pendiente')     -- Estado Pendiente por defecto.
);
ALTER TABLE dbo.Pedido WITH CHECK ADD CONSTRAINT CK_Pedido_estado CHECK (estado IN ('Pendiente','Confirmado','Anulado'));
END;
GO      -- Valida el valor de estado.

IF OBJECT_ID(N'dbo.DetallePedido', N'U') IS NULL
BEGIN
CREATE TABLE dbo.DetallePedido(     -- Relaciona cada pedido con los productos comprados.
    idDetallePedido INT IDENTITY(1,1) PRIMARY KEY,
    idPedido        INT NOT NULL,
    idProducto      INT NOT NULL,
    cantidad        INT NULL CONSTRAINT CK_Detalle_cantidad CHECK (cantidad > 0),       -- No se puede comprar menos de una unidad de un producto.
    precioUnitario  DECIMAL(10,2) NULL CONSTRAINT CK_Detalle_precio CHECK (precioUnitario >= 0)
);
END;
GO

IF OBJECT_ID(N'dbo.Catalogo', N'U') IS NULL     -- Permite diferentes catálogos por temporada.
BEGIN
CREATE TABLE dbo.Catalogo(
    idCatalogo  INT IDENTITY(1,1) PRIMARY KEY,
    temporada   NVARCHAR(30) NOT NULL
);
END;
GO

IF OBJECT_ID(N'dbo.CatalogoProducto', N'U') IS NULL     -- Tabla intermedia entre catálogo y producto.
BEGIN
CREATE TABLE dbo.CatalogoProducto(
    idCatalogo          INT NOT NULL,       -- FK (N:1)
    idProducto          INT NOT NULL,       -- FK (N:1)
    precioPromocional   DECIMAL(10,2) NULL,
    fechaInclusion      DATE NOT NULL,
    CONSTRAINT PK_CatalogoProducto PRIMARY KEY (idCatalogo, idProducto)     -- PK compuesta (2 columnas), la combinación debe ser única.
);
END;
GO

IF OBJECT_ID(N'dbo.Pago', N'U') IS NULL     -- Registra los pagos de cada pedido.
BEGIN
CREATE TABLE dbo.Pago(
    idPago      INT IDENTITY(1,1) PRIMARY KEY,
    idPedido    INT NOT NULL,
    modalidad   NVARCHAR(30) NULL,
    monto       DECIMAL(10,2) NULL CONSTRAINT CK_Pago_monto CHECK (monto > 0)       -- No puede ser gratis.
);
ALTER TABLE dbo.Pago WITH CHECK ADD CONSTRAINT CK_Pago_modalidad CHECK (modalidad IN ('Efectivo','Transferencia','Tarjeta'));
END;
GO      -- Valida la modalidad. SI ES NULL EL CHECK NO SE HACE.

IF OBJECT_ID(N'dbo.Alerta', N'U') IS NULL       -- Alertas del sistema.
BEGIN
CREATE TABLE dbo.Alerta(
    idAlerta     INT IDENTITY(1,1) PRIMARY KEY,
    tipo         NVARCHAR(30) NULL,
    descripcion  NVARCHAR(255) NULL,
    fecha        DATETIME NOT NULL      -- Fecha y hora yyyy-mm-dd hh:mm:ss
);
ALTER TABLE dbo.Alerta WITH CHECK ADD CONSTRAINT CK_Alerta_tipo CHECK (tipo IN ('Error','Stock','Repetici�n'));
END;
GO      -- Valida el tipo de alerta

/* =========================================
   3) FKs (solo si faltan)
   ========================================= */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Pedido_Cliente')     -- Verifica en la tabla foreign_keys del esquema sys si ya existe una FK con ese nombre.
    ALTER TABLE dbo.Pedido ADD CONSTRAINT FK_Pedido_Cliente FOREIGN KEY(idCliente) REFERENCES dbo.Cliente(idCliente);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Producto_Categoria')
    ALTER TABLE dbo.Producto ADD CONSTRAINT FK_Producto_Categoria FOREIGN KEY(idCategoria) REFERENCES dbo.Categoria(idCategoria);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DetallePedido_Pedido')
    ALTER TABLE dbo.DetallePedido ADD CONSTRAINT FK_DetallePedido_Pedido FOREIGN KEY(idPedido) REFERENCES dbo.Pedido(idPedido);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DetallePedido_Producto')
    ALTER TABLE dbo.DetallePedido ADD CONSTRAINT FK_DetallePedido_Producto FOREIGN KEY(idProducto) REFERENCES dbo.Producto(idProducto);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Pago_Pedido')
    ALTER TABLE dbo.Pago ADD CONSTRAINT FK_Pago_Pedido FOREIGN KEY(idPedido) REFERENCES dbo.Pedido(idPedido);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CatalogoProducto_Catalogo')
    ALTER TABLE dbo.CatalogoProducto ADD CONSTRAINT FK_CatalogoProducto_Catalogo FOREIGN KEY(idCatalogo) REFERENCES dbo.Catalogo(idCatalogo);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CatalogoProducto_Producto')
    ALTER TABLE dbo.CatalogoProducto ADD CONSTRAINT FK_CatalogoProducto_Producto FOREIGN KEY(idProducto) REFERENCES dbo.Producto(idProducto);
GO

/* =========================================
   4) Funci�n
   ========================================= */

-- A) Calcula el margen de ganancia de un producto:
IF OBJECT_ID(N'dbo.fn_CalcularMargen', N'FN') IS NULL       -- FN = Tipo de objeto función escalar.
    EXEC('
    -- EXEC se usa porque no se pueden crear funciones dentro de un bloque IF...BEGIN...END directamente.

    CREATE FUNCTION dbo.fn_CalcularMargen(@idProducto INT)      -- La función recibe como parámetro el id del producto.
    RETURNS DECIMAL(10,2)       -- Devuelve un valor decimal.
    AS      -- Inicio de la definición del cuerpo de la función.
    BEGIN       -- Inicio del bloque de código.
        DECLARE @margen DECIMAL(10,2);      -- Declara una variable local, que almacenará el resulatado del cálculo.
        SELECT @margen = precioVenta - costoUnitario        -- Asigna el valor correspondiente a la variable.
        FROM dbo.Producto WHERE idProducto = @idProducto;       -- De la fila de Producto donde el id coincida con el ingresado como parámetro.
        RETURN @margen;     -- Devuelve el márgen.
    END     -- Cierra el bloque BEGIN.
    ');
    -- Cierra el string del EXEC() y la isntrucción completa.
GO

/* =========================================
   5) Procedimientos almacenados
   ========================================= */

-- A) Busca todos los productos con stock = 0 y estado = 'Activo'. Por cada uno, lo marca como 'Inactivo' y crea una alerta indicando que fue inactivado.
IF OBJECT_ID(N'dbo.sp_InactivarProductosSinStock_Cursor', N'P') IS NULL     -- Verifica si el procedimiento no existe antes de crearlo. P = tipo de objeto Procedure.
    EXEC('
    CREATE PROCEDURE dbo.sp_InactivarProductosSinStock_Cursor       -- Crea el SP, no recibe parámetros.
    AS
    BEGIN
        SET NOCOUNT ON;     -- Desactiva el mensaje "X filas agregadas", mejorando el rendimiento y limpiando la salida.
        DECLARE @idProducto INT, @nombre NVARCHAR(100);     -- Declara dos variables que se van a usar en el cursos (id y nombre del producto actual).
        DECLARE cu_productos CURSOR FOR     -- CURSOR = Estructura que permite recorrer fila por fila un conjunto de resultados.
            SELECT idProducto, nombre FROM dbo.Producto
            WHERE stockDisponible = 0 AND estado = ''Activo''       -- Busca productos con stock 0 aunque estén activos.
            FOR UPDATE OF estado;       -- Indica que se va a actualizar la columna estado (permite usar WHERE CURRENT OF).
        OPEN cu_productos;      -- Abre el cursor para empezar a usarlo.
        FETCH NEXT FROM cu_productos INTO @idProducto, @nombre;     -- Obtiene la siguiente fila del cursor y guarda los valores en las variables.
        WHILE @@FETCH_STATUS = 0        -- Mientras el estado del último fetch sea 0 (éxito - hay una fila)... O sea mientras haya filas por procesar.
        BEGIN
            UPDATE dbo.Producto SET estado = ''Inactivo'' WHERE CURRENT OF cu_productos;        -- Actualiza el estado en la fila actual del cursor (alternativa menos eficiente: WHERE idProducto = @idProducto).
            INSERT INTO dbo.Alerta(tipo, descripcion, fecha)        -- Inserta una alerta en la tabla Alerta.
            VALUES (''Stock'', CONCAT(''Producto "'', @nombre, ''" inactivado por falta de stock.''), GETDATE());       -- CONCAT concatena strings, GETDATE devuelve la fecha y hora actuales.
            FETCH NEXT FROM cu_productos INTO @idProducto, @nombre;     -- Avanza a la siguiente fila del cursor.
        END     -- Deja de repetirse cuando el estado de fetch es diferente a 0.
        CLOSE cu_productos; DEALLOCATE cu_productos;        -- Cierra el cursor y libera los recursos del cursor de la memoria.
        PRINT(''Proceso completado: productos inactivados y alertas generadas.'');
    END
    ');
GO

-- B) Valida el producto, crea el pedido y el detalle, descuenta el stock, avisa, y si algo falla deshace tod.
IF OBJECT_ID(N'dbo.sp_RegistrarPedido', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarPedido;      -- Si ya existe, lo elimina (no hace validación con IS NULL), lo que permite recrearlo cada vez que ejcutamos el script.
GO
CREATE PROCEDURE dbo.sp_RegistrarPedido
    @idCliente INT,     -- Cliente que compra.
    @idProducto INT,        -- Producto que compra.
    @cantidad INT,      -- Cantidad.
    @precioUnitario DECIMAL(10,2)       -- Precio unitario.
AS
BEGIN
    SET NOCOUNT ON;     -- Mejora rendimiento.

    DECLARE @stock INT, @estado NVARCHAR(15);
    SELECT @stock = stockDisponible, @estado = estado
    FROM dbo.Producto
    WHERE idProducto = @idProducto;     -- Obtiene el stock y estado del producto solicitado, guardando los valores en variables para validar.

    -- Validación 1:
    IF @stock IS NULL       -- Significa que el producto no existe.
    BEGIN PRINT('Producto no existe.'); RETURN; END;        -- Sale del procedimiento inmediatamente.

    -- Validación 2:
    IF @estado = 'Inactivo'     -- No se puede comprar un producto inactivo.
    BEGIN PRINT('El producto est� inactivo.'); RETURN; END;

    -- Validación 3:
    IF @stock < @cantidad       -- No hay suficiente stock para la cantidad solicitada.
    BEGIN PRINT('Stock insuficiente.'); RETURN; END;

    DECLARE @idPedido INT;      -- Variable para guardar el ID del pedido que se va a crear.

    BEGIN TRAN;     -- Inicia una transacción. Tod lo que sigue es una operación atómica (tod o nada).

    BEGIN TRY       -- Inicia un bloque de manejo de errores.

        -- Paso 1: Crea el pedido (agrega una fila a la tabla)
        INSERT INTO dbo.Pedido(idCliente, fecha, precioTotal, estado)
        VALUES(@idCliente, CAST(GETDATE() AS DATE), @cantidad * @precioUnitario, 'Confirmado');     -- id, fecha actual sin hora, precio total (cálculo), estado.
        SET @idPedido = SCOPE_IDENTITY();       -- Obtiene el último ID insertado (el del pedido recién crado).

        -- Paso 2: Crea el detalle del pedido (qué producto compró).
        INSERT INTO dbo.DetallePedido(idPedido, idProducto, cantidad, precioUnitario)
        VALUES(@idPedido, @idProducto, @cantidad, @precioUnitario);

        -- Paso 3: Descuenta del stock la cantidad vendida del producto.
        UPDATE dbo.Producto
        SET stockDisponible = stockDisponible - @cantidad
        WHERE idProducto = @idProducto;     -- Paso 3

        -- Paso 4: Mensaje informativo.
        INSERT INTO dbo.Alerta(tipo, descripcion, fecha)
        VALUES ('Stock', 'Se registr� un nuevo pedido.', GETDATE());

        COMMIT TRAN;        -- Confirma la transacción (hace permanentes todos los cambios).
        PRINT('Pedido registrado correctamente.');
    END TRY     -- Fin del bloque TRY.
    BEGIN CATCH     -- Si durante el bloque TRY ocurre un error, el código salta a esta parte. Sino, este bloque no se ejecuta.
        IF XACT_STATE() <> 0 ROLLBACK TRAN;     -- Si el estado de la transacción es 1 (activa y confirmable) o -1 (error), deshace todos los cambios de la transacción.
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();      -- Obtiene el mensaje de error.
        RAISERROR('Error en sp_RegistrarPedido: %s', 16, 1, @msg);      -- Lanza un error personalizado (se elijen el nivel de severidad 16, estado 1, marcador de posición).
        RETURN;     -- Sale del SP.
    END CATCH
END
GO

-- C) Muestra todos los productos con su información, para reportar el márgen.
IF OBJECT_ID(N'dbo.sp_ReporteMargenProductos', N'P') IS NULL
    EXEC('
    CREATE PROCEDURE dbo.sp_ReporteMargenProductos      -- No recibe parámetros.
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT p.idProducto, p.nombre, p.costoUnitario, p.precioVenta,
               dbo.fn_CalcularMargen(p.idProducto) AS margen, p.estado      -- Usa la función para calcular el márgen.
        FROM dbo.Producto p ORDER BY margen ASC;        -- Ordena por márgen de menor a mayor (productos menos rentables primero).
    END
    ');
GO

-- D) Muestra la cantidad de alertas de cada tipo por mes.
IF OBJECT_ID(N'dbo.sp_ReporteAlertasPorMesYTipo', N'P') IS NULL
    EXEC('
    CREATE PROCEDURE dbo.sp_ReporteAlertasPorMesYTipo       -- No recibe parámetros.
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT UPPER(DATENAME(MONTH, fecha)) AS Mes,        -- Nombre del mes en mayúsculas.
               DATEPART(MONTH, fecha) AS MesNumero,     -- Número del mes.
               DATEPART(YEAR, fecha) AS A�o,        -- Año en números.
               tipo AS TipoAlerta,
               COUNT(*) AS TotalAlertas     -- Cuenta cuántas alertas hay por grupo.
        FROM dbo.Alerta     -- Lo obtiene de la tabla de alertas, entonces no hay que preocuparse porque solo va a tomar en cuenta las fechas en las que haya registradas alertas.
        GROUP BY DATENAME(MONTH, fecha), DATEPART(MONTH, fecha), DATEPART(YEAR, fecha), tipo        -- Agrupa por mes, año y tipo de alerta.
        ORDER BY A�o DESC, MesNumero;       -- Ordena por año descendente y luego por número (por defecto ASC).
    END
    ');
GO

/* =========================================
   6) Vistas
   ========================================= */

-- A) Muestra productos en catálogos con sus precios promocionales.
IF OBJECT_ID(N'dbo.vw_CatalogoConPromos', N'V') IS NULL
    EXEC('
    CREATE VIEW dbo.vw_CatalogoConPromos AS
    SELECT c.temporada, p.nombre AS producto, p.precioVenta AS precioLista,
           cp.precioPromocional, cp.fechaInclusion      -- Se seleccionan las columnas de las distintas tablas que se van a mostrar, a algunas se les cambia el nombre.
    FROM dbo.Catalogo c
    JOIN dbo.CatalogoProducto cp ON c.idCatalogo = cp.idCatalogo        -- INNER JOIN 1 con tabla intermedia CatalogoProducto via idCatalogo.
    JOIN dbo.Producto p ON cp.idProducto = p.idProducto;        -- INNER JOIN 2 con tabla Producto via idProducto.
    ');
GO      -- (INNER) JOIN Sólo muestra las filas donde hay coincidencias en las colmnas indicadas (en este caso los ids).

-- B) Muestra cuando un cliente compró el mismo producto en la misma fecha más de una vez.
IF OBJECT_ID(N'dbo.vw_ComprasDuplicadas', N'V') IS NULL
    EXEC('
    CREATE VIEW dbo.vw_ComprasDuplicadas AS
    SELECT c.idCliente, c.nombre, c.apellido,
           dp.idProducto, p.nombre AS nombreProducto,
           ped.fecha, DATENAME(WEEKDAY, ped.fecha) AS diaSemana,        -- Muestra el día de la semana escrito.
           COUNT(*) AS cantidadCompras      -- Contador para identificar duplicados.
    FROM dbo.Cliente c      -- Tabla 1.
    JOIN dbo.Pedido ped ON c.idCliente = ped.idCliente      -- JOIN con tabla 2 através de idCliente. Si un cliente no tiene pedidos, desaparece. Si un cliente tiene múltiples pedidos, se duplica.
    JOIN dbo.DetallePedido dp ON ped.idPedido = dp.idPedido     -- JOIN con tabla 3 através de idPedido. Une cada pedido con los productos que contiene. Cada fila representa una línea de pedido (un producto específico dentro de un pedido).
    JOIN dbo.Producto p ON dp.idProducto = p.idProducto     -- JOIN con tabla 4 a través de idProducto, agrega el nombre del producto para hacerlo más legible.
    GROUP BY c.idCliente, c.nombre, c.apellido, dp.idProducto, p.nombre, ped.fecha      -- Agrupa filas que tienen los mismos valores en las columnas especificadas y las colapsa en una sola fila. En este caso son todas las filas que tengan la misma combinación de (Cliente + Producto + Fecha)
    HAVING COUNT(*) > 1;        -- Sólo muestra duplicados
    ');
GO

/* =========================================
   7) Triggers
   ========================================= */

-- Trigger STOCK BAJO
IF OBJECT_ID(N'dbo.trg_AlertaStockBajo', N'TR') IS NULL     -- N'TR' busca específicamente un TRigger.
    EXEC('
    CREATE TRIGGER dbo.trg_AlertaStockBajo ON dbo.Producto      -- Producto es la tabla vigilada.
    AFTER UPDATE AS     -- Se dispara después de actualizar (UPDATE) Producto.
    BEGIN
        -- Parte 1: Alerta de stock bajo.
        SET NOCOUNT ON;     -- Evita mensajes de cantidad de filas afectadas.
        INSERT INTO dbo.Alerta(tipo, descripcion, fecha)        -- Guarda en la tabla Alerta.
        SELECT ''Stock'',
               CONCAT(''Stock bajo para "'', i.nombre, ''": quedan '', i.stockDisponible, '' unidades.''),
               GETDATE()
        FROM inserted i     -- Tabla temporal (se crea automáticamente cuando se dispara el trigger con valores nuevos (después del UPDATE). Obtiene los valores nuevos.
        JOIN deleted d ON i.idProducto = d.idProducto       -- Tabla temporal automática con valores viejos (antes del UPDATE). Compara con los valores viejos.
        WHERE i.stockDisponible <= 2 AND i.stockDisponible <> d.stockDisponible;        -- Si el stock nuevo es <= 2 Y antes era distinto, entonces inserta la alerta en la tabla Alerta.

        -- Parte 2: Inactivar productos sin stock.
        UPDATE dbo.Producto SET estado = ''Inactivo''
        WHERE idProducto IN (SELECT idProducto FROM inserted WHERE stockDisponible = 0); -- Desactiva el producto por stock 0.

        -- Parte 3: Alerta de producto inactivado (sin duplicados).
        INSERT INTO dbo.Alerta(tipo, descripcion, fecha)
        SELECT ''Stock'',
               CONCAT(''Producto "'', i.nombre, ''" inactivado por falta de stock.''),
               GETDATE()
        FROM inserted i
        WHERE i.stockDisponible = 0     -- Donde el stock nuevo es 0.
          AND NOT EXISTS (
              SELECT 1 FROM dbo.Alerta
              WHERE tipo = ''Stock'' AND descripcion LIKE CONCAT(''%'', i.nombre, ''%inactivado%'')
          );        -- Sólo se genera si no había una alerta del mismo tipo previa.
    END
    ');
GO

-- Trigger ANTI-DUPLICADOS (sin tabla ProductoDuplicado).
IF OBJECT_ID(N'dbo.trg_DetallePedido_AntiDuplicado_Unificado', N'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_DetallePedido_AntiDuplicado_Unificado;     -- Si el tr ya existía, lo elimina.
GO

CREATE TRIGGER dbo.trg_DetallePedido_AntiDuplicado_Unificado
ON dbo.DetallePedido
INSTEAD OF INSERT       -- Reemplaza el INSERT original. Su propósito es la PREVENSIÓN. SIEMPRE que se quiera hacer un INSERT a DetallePedido se activa.
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #ins(
        idPedido INT,
        idProducto INT,
        cantidad INT,
        precioUnitario DECIMAL(10,2)
    );      -- Crea una tabla temporal para capturar los datos.

    INSERT INTO #ins
    SELECT idPedido, idProducto, cantidad, precioUnitario
    FROM inserted; -- Guarda en la tabla los datos que se intentaron insertar.

    CREATE TABLE #dups_mismo_pedido(
        idPedido INT,
        idProducto INT,
        cantidad INT,
        precioUnitario DECIMAL(10,2),
        cantidadExistente INT
    );      -- Crea una tabla temporal(#) para capturar productos duplicados en un pedido.
    -- Una tabla temporal sólo existe durante la sesión y después se elimina.

    INSERT INTO #dups_mismo_pedido
    SELECT i.idPedido, i.idProducto, i.cantidad, i.precioUnitario, dp.cantidad
    FROM #ins i     -- Desde la tabla de captura.
    JOIN dbo.DetallePedido dp       -- JOIN con DetallePedido.
      ON dp.idPedido = i.idPedido
     AND dp.idProducto = i.idProducto;      -- A través del id del pedido Y el id del producto.
     -- Esta tabla va a guardar pedidos duplicados.
     -- Nosotros tenemos un detalle e intentamos insertar un producto en un pedido existente. Si el id del producto ya estaba en el detalle de ese pedido, se considera duplicado.

    CREATE TABLE #inserted_enriquecido(
        idPedido INT,
        idProducto INT,
        cantidad INT,
        precioUnitario DECIMAL(10,2),
        idCliente INT,
        fechaPedido DATE
    );      -- Crea una tabla temporal enriquecida para completar la información de #ins.

    INSERT INTO #inserted_enriquecido
    SELECT i.idPedido, i.idProducto, i.cantidad, i.precioUnitario, p.idCliente, CAST(p.fecha AS DATE)       -- fecha era DATETIME, convierte a solo DATE.
    FROM #ins i     -- Toma datos de #ins.
    JOIN dbo.Pedido p ON p.idPedido = i.idPedido;       -- Los "enriquece" agregando idCliente y fechaPedido.

    CREATE TABLE #dups_cruzados(
        idPedido INT,
        idProducto INT,
        cantidad INT,
        precioUnitario DECIMAL(10,2),
        idCliente INT,
        fechaPedido DATE
    );      -- Crea una tabla temporal para capturar duplicados cruzados.

    INSERT INTO #dups_cruzados
    SELECT ie.idPedido, ie.idProducto, ie.cantidad, ie.precioUnitario, ie.idCliente, ie.fechaPedido
    FROM #inserted_enriquecido ie
    WHERE EXISTS (
        SELECT 1
        FROM dbo.Pedido p2      -- Tabla Pedido.
        JOIN dbo.DetallePedido dp2 ON dp2.idPedido = p2.idPedido        -- JOIN con detalle en base al id de pedido.
        WHERE p2.idCliente = ie.idCliente       -- Donde el id del cliente en Pedido es el mismo que en #inserted_enriquecido. (MISMO CLIENTE).
          AND dp2.idProducto = ie.idProducto        -- Y el id del producto también. (MISMO PRODUCTO).
          AND CAST(p2.fecha AS DATE) = ie.fechaPedido       --  Y la fecha también es la misma. (MISMO DÍA).
          AND p2.idPedido <> ie.idPedido        -- Y los ids de pedido son diferentes (DIFERENTE PEDIDO).
    );      -- Guarda cuando el mismo cliente compró el mismo producto en otro pedido del mismo día.

    -- Insertar los v�lidos
    INSERT INTO dbo.DetallePedido(idPedido, idProducto, cantidad, precioUnitario)       -- En DetallePedido.
    SELECT i.idPedido, i.idProducto, i.cantidad, i.precioUnitario
    FROM #ins i     -- Desde la tabla de datos a insertar.
    WHERE NOT EXISTS (
            SELECT 1 FROM #dups_mismo_pedido d
            WHERE d.idPedido = i.idPedido AND d.idProducto = i.idProducto       -- Donde los ids a insertar no estan en la tabla de productos duplicados.
        )
      AND NOT EXISTS (
            SELECT 1 FROM #dups_cruzados c
            WHERE c.idPedido = i.idPedido AND c.idProducto = i.idProducto       -- Y los ids a ingresar no están en la tabla de duplicados cruzados.
        );

    -- Alertas por duplicado dentro del mismo pedido
    INSERT INTO dbo.Alerta(tipo, descripcion, fecha)
    SELECT 'Repetici�n',        -- Tipo de alerta.
           CONCAT('Intento de producto duplicado en el mismo pedido (Pedido ', idPedido,
                  ', Producto ', idProducto,
                  ', Cantidad existente ', cantidadExistente,
                  ', Intentada ', cantidad, ').'),
           GETDATE()
    FROM #dups_mismo_pedido;        -- Para cada duplicado detectado (como es temporal sabemos que se detectaron en esta ejecución).

    -- Alertas por duplicado cruzado (otro pedido mismo cliente mismo d�a)
    INSERT INTO dbo.Alerta(tipo, descripcion, fecha)
    SELECT 'Repetici�n',
           CONCAT('Intento de compra duplicada (Cliente ', idCliente,
                  ', Producto ', idProducto,
                  ', Fecha ', CONVERT(VARCHAR(10), fechaPedido, 120), ').'),
           GETDATE()
    FROM #dups_cruzados;        -- Lo mismo, para cada duplicado que se detectó.
END;
GO





-- ==========================================================
-- 1) Limpiar datos previos (sin borrar estructura)
-- ==========================================================
PRINT('Limpiando datos previos...');
DELETE FROM Alerta;
DELETE FROM DetallePedido;
DELETE FROM Pedido;
DELETE FROM Producto;
DELETE FROM Categoria;
DELETE FROM Cliente;
GO
-- Borra datos previos en orden correcto(primero tablas hijas, luego padres, respetando las FK para evitar errores.

-- ==========================================================
-- 2) Insertar datos base
-- ==========================================================
PRINT('Insertando datos base...');

INSERT INTO Categoria(nombre)
VALUES ('Calzado'), ('Ropa'), ('Accesorios');

INSERT INTO Producto(nombre, idCategoria, costoUnitario, precioVenta, stockDisponible)
VALUES
('Zapatillas Nike', 1, 25000, 35000, 5),
('Remera Adidas', 2, 8000, 12000, 3),
('Gorra Puma', 3, 6000, 9000, 2);

INSERT INTO Cliente(nombre, apellido, email, telefono)
VALUES
('Juliana', 'Galiano', 'juli@demo.com', '11223344'),
('Juan', 'P�rez', 'juan@demo.com', '22334455');
GO

-- ==========================================================
-- 3) Generar pedidos normales
-- ==========================================================
PRINT('Generando pedidos normales...');

EXEC dbo.sp_RegistrarPedido @idCliente = 1, @idProducto = 1, @cantidad = 1, @precioUnitario = 35000;
EXEC dbo.sp_RegistrarPedido @idCliente = 1, @idProducto = 2, @cantidad = 1, @precioUnitario = 12000;
EXEC dbo.sp_RegistrarPedido @idCliente = 2, @idProducto = 3, @cantidad = 1, @precioUnitario = 9000;

-- ==========================================================
-- 4) Forzar intento duplicado dentro del mismo pedido
-- ==========================================================
PRINT('Forzando intento duplicado en mismo pedido...');
-- Se intenta volver a insertar el mismo producto del pedido 1 (cliente 1)
INSERT INTO DetallePedido(idPedido, idProducto, cantidad, precioUnitario)
VALUES (1, 1, 2, 35000);
GO

-- ==========================================================
-- 5) Forzar duplicado cruzado (mismo cliente, mismo d�a)
-- ==========================================================
PRINT('Forzando intento duplicado entre pedidos del mismo cliente...');
-- Crear un nuevo pedido del mismo cliente con el mismo producto y fecha
DECLARE @idNuevoPedido INT;
INSERT INTO Pedido(idCliente, fecha, precioTotal, estado)
VALUES (1, CAST(GETDATE() AS DATE), 35000, 'Confirmado');
SET @idNuevoPedido = SCOPE_IDENTITY();

-- Intentar comprar el mismo producto del pedido anterior ? debe generar alerta
INSERT INTO DetallePedido(idPedido, idProducto, cantidad, precioUnitario)
VALUES (@idNuevoPedido, 1, 1, 35000);
GO

-- ==========================================================
-- 6) Forzar stock bajo (actualiza stock a 2 o menos)
-- ==========================================================
PRINT('Forzando stock bajo...');
UPDATE Producto SET stockDisponible = 2 WHERE idProducto = 3;
UPDATE Producto SET stockDisponible = 0 WHERE idProducto = 2;
GO

-- ==========================================================
-- 7) Mostrar resultados
-- ==========================================================
PRINT('==================== RESULTADOS ====================');

-- Productos
SELECT * FROM Producto;

-- Pedidos
SELECT * FROM Pedido;

-- Detalles de pedidos
SELECT * FROM DetallePedido;

-- Alertas generadas
SELECT idAlerta, tipo, descripcion, fecha
FROM Alerta
ORDER BY fecha DESC;
GO

EXEC sp_ReporteAlertasPorMesYTipo;
EXEC sp_ReporteMargenProductos;
EXEC sp_InactivarProductosSinStock_Cursor;
