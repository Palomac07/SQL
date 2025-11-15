-- Una relación dentro de la propia tabla.
-- Ejemplo: dentro de una tabla "Empleados" existe la columna "jefe". Para cada ID, marcamos el ID que corresponde a su jefe (al nivel más alto podemos
-- ponerle su propia ID, o null).

CREATE TABLE Empleado (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    jefe_id INT,
    FOREIGN KEY (jefe_id) REFERENCES Empleado(id)
);