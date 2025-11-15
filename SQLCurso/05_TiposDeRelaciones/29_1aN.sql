-- Un elemento de la tabla A se puede relacionar con varios elementos de la tabla B, pero un elemento de la tabla B se puede relacionar con un
-- único elemento de la tabla A.

CREATE TABLE Departamento (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE Empleado (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    depto_id INT,
    FOREIGN KEY (depto_id) REFERENCES Departamento(id)
);

-- El ID de un empleado sólo puede estar relacionado con UN ID de la tabla Departamento, pero un ID de la tabla Departamento puede ser FK de
-- muchos empleados.