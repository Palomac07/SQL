-- EXISTS verifica si la subconsulta devuelve al menos una fila.
-- NOT EXISTS verifica su la subconsulta no devuelve ninguna fila.
-- Retornan TRUE o FALSE (no devuelven datos).
-- Se usan con WHERE, IF...

--Ejemplo: Mostrar usuarios que tienen al menos un pedido
SELECT u.id, u.nombre
FROM usuario u
WHERE EXISTS (
    SELECT 1                   -- 1 equivale a * en este caso, es lo mismo.
    FROM pedido p
    WHERE p.usuarioId = u.id
);


-- Puede tomarse como equivalente a IN y NOT IN, según que caso puede ser más eficiente uno o el otro.

-- Opción 1: EXISTS (más eficiente generalmente)
SELECT u.nombre
FROM usuario u
WHERE EXISTS (
    SELECT 1
    FROM pedido p
     WHERE p.usuarioId = u.id
);

-- Opción 2: IN
SELECT u.nombre
FROM usuario u
WHERE u.id IN (
    SELECT usuarioId
    FROM pedido
);

-- EXISTS busca al menos un resultado y se detiene cuando encuentra el primero, mientras que In busca una lista de valores y revisa todos.
-- Además, IN puede tener problemas con NULL.