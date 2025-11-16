-- Una relación dentro de la propia tabla.
-- Ejemplo: dentro de una tabla "Empleados" existe la columna "jefe". Para cada ID, marcamos el ID que corresponde a su jefe (al nivel más alto podemos
-- ponerle su propia ID, o null).

CREATE TABLE Empleado (
    id INT PRIMARY KEY, -- ID único del empleado.
    nombre VARCHAR(100),
    jefe_id INT,        -- ID del jefe de este empleado (un empleado puede tener un sólo jefe, un jefe puede tener muchos empleados).
    FOREIGN KEY (jefe_id) REFERENCES Empleado(id) -- Clave foránea que apunta a la misma tabla.
);