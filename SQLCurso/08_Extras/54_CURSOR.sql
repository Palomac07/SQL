-- CURSOR es un mecanismo que permite procesar filas de una consulta una por una, en lugar de todas a la vez.
-- Normalmente SQL trabaja con conjuntos. CURSOR permite iterar.
-- Por defecto, avanza hacia adelanta. Hay otros tipos pero no los usamos.
-- Es muy lento, hay que usarlo sólo cuando sea absolutamente necesario.
-- Preferir operaciones basadas en conjuntos cuando sea posible.

-- Sin CURSOR trabaja con TODAS las filas a la vez
UPDATE producto SET precio = precio * 1.1;

-- Con CURSOR:
-- Procesar cada producto individualmente
 DECLARE cursor_productos CURSOR FOR SELECT id, precio FROM producto;
-- Abrir cursor
-- Recorrer fila por fila
-- Hacer algo con cada fila

-- Sintaxis básica = DECLARE → OPEN → FETCH → WHILE → CLOSE → DEALLOCATE

-- 1. Declarar cursor
DECLARE nombre_cursor CURSOR FOR
SELECT columnas FROM tabla
WHERE condicion
FOR UPDATE OF columna;                               -- Cláusula que se usa en cursores para especificar qué columnas se pueden actualizar a través del cursor.;

-- 2. Abrir cursor
OPEN nombre_cursor;                                  -- Ejecuta consulta y carga datos.

-- 3. Leer primera fila
FETCH NEXT FROM nombre_cursor INTO @variables;       -- Lee la siguiente fila del cursor y guarda cada columna en una variable. Avanza el cursor una posición.

-- 4. Procesar filas en loop
WHILE @@FETCH_STATUS = 0                              --- Indica el estado de la última operación FETCH.
                                                      -- 0 = ÉXITO
                                                      -- -1 = no hay más filas.
BEGIN
    -- Hacer algo con los datos (UPDATE/INSERT...).
    FETCH NEXT FROM nombre_cursor INTO @variables;    -- Leer siguiente fila.
END

-- 5. Cerrar cursor
CLOSE nombre_cursor;                                 -- Libera datos, mantiene definición.

-- 6. Liberar recursos
DEALLOCATE nombre_cursor;                            -- Elimina el cursor completamente (guarda tod).

WHERE CURRENT OF -- Permite actualizar o eliminar la fila actual del cursor sin especificar la clave primaria.
-- Es equivalente a un WHERE con PK:
DECLARE @id INT, @precio DECIMAL(10,2);

DECLARE cursor_x CURSOR FOR SELECT id, precio FROM producto;
OPEN cursor_x;
FETCH NEXT FROM cursor_x INTO @id, @precio;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE producto
    SET precio = @precio * 1.10
    WHERE id = @id;  -- ← Necesitas especificar la clave

    FETCH NEXT FROM cursor_x INTO @id, @precio;
END

CLOSE cursor_x;
DEALLOCATE cursor_x;
