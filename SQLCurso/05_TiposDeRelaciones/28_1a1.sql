-- Cada elemento de la TABLA A solo puede estar relaionado con un elemento de la TABLA B, y viceversa.
-- Para representarlo se usan los identificadores únicos de las tablas como FK:
-- La PK de la tabla A se guarda en el elemento correspondiente de la tabla B, pero como FK.

CREATE TABLE Persona (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE Pasaporte (
    id INT PRIMARY KEY,
    numero VARCHAR(20),
    persona_id INT UNIQUE, -- clave foránea única (el UNIQUE asegura el 1:1).
    FOREIGN KEY (persona_id) REFERENCES Persona(id)
);
-- Como se puede ver, sólo se escribe en una tabla la PK de la otra (como FK).