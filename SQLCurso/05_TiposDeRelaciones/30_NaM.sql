-- Un elemento de la tabla A se puede relacionar con varios elementos de la tabla B, y viceversa.
-- Se usa una tabla intermedia que queda 1 a N.

CREATE TABLE Estudiante (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE Curso (
    id INT PRIMARY KEY,
    titulo VARCHAR(100)
);

-- tabla intermedia:
CREATE TABLE EstudianteCurso (
    estudiante_id INT NOT NULL,                            -- NN es indispensable porque no puede haber null de ningún lado de la relación.
    curso_id INT NOT NULL,
    PRIMARY KEY (estudiante_id, curso_id),                 -- PK de la tabla intermedia
    FOREIGN KEY (estudiante_id) REFERENCES Estudiante(id), -- FK que corresponde a un único ID de Estudiante.
    FOREIGN KEY (curso_id) REFERENCES Curso(id),           -- FK que corresponde a un único ID de Curso.
    UNIQUE (estudiante_id, curso_id)                       -- Indica que la COMBINACIÓN DE IDs es única.
);
-- Un Estudiante puede tener N registros en EstudianteCurso.
-- Un Curso puede tener N registros en EstudianteCurso.
-- Cada registro en EstudianteCurso relaciona 1 estudiante con 1 curso.

-- INSERT:
INSERT INTO nombreTablaIntermedia(FKtablaA, FKtablaB) VALUES (valorA, valorB);
-- Como es muchos a muchos, esto se escribe para cada relación de la tabla.