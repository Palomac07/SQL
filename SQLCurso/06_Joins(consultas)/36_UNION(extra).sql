-- Combinar datos de tablas similares:
-- Ejemplo: Combinar empleados activos e inactivos de tablas diferentes
SELECT nombre, email FROM EmpleadosActivos
UNION
SELECT nombre, email FROM EmpleadosInactivos;

-- Combinar resultados con diferentes condiciones:
-- Ejemplo: Empleados menores a 25 O de departamento de ventas
SELECT id, nombre, edad, departamento
FROM Empleado
WHERE edad < 25

UNION

SELECT id, nombre, edad, departamento
FROM Empleado
WHERE departamento = 'Ventas';

-- Nota: Esto elimina duplicados automáticamente (si alguien cumple ambas condiciones, aparece una sola vez).

-- Crear categorías personalizadas:
-- Ejemplo: Clasificar empleados por rango de edad
SELECT nombre, 'Joven' as categoria
FROM Empleado
WHERE edad < 30

UNION

SELECT nombre, 'Adulto' as categoria
FROM Empleado
WHERE edad BETWEEN 30 AND 50

UNION

SELECT nombre, 'Senior' as categoria
FROM Empleado
WHERE edad > 50;
-- Muestra una columna con nombres y una columna con la categoría correspondiente.

-- Combinar datos reales con valores predeterminados:
-- Ejemplo: Lista de todos los departamentos (incluso si no tienen empleados)
SELECT nombre FROM Departamento

UNION

SELECT 'Sin Departamento' as nombre;

-- Unir consultas agregadas diferentes:
-- Ejemplo: Reporte de ventas y compras
SELECT 'Ventas' as tipo, SUM(monto) as total, MONTH(fecha) as mes
FROM Ventas
GROUP BY MONTH(fecha)

UNION

SELECT 'Compras' as tipo, SUM(monto) as total, MONTH(fecha) as mes
FROM Compras
GROUP BY MONTH(fecha)

ORDER BY mes, tipo;

-- Pivotear datos manualmente:
-- Ejemplo: Convertir filas en diferentes consultas
SELECT id, nombre, ventas_enero as ventas, 'Enero' as mes
FROM Empleado

UNION

SELECT id, nombre, ventas_febrero, 'Febrero'
FROM Empleado

UNION

SELECT id, nombre, ventas_marzo, 'Marzo'
FROM Empleado;