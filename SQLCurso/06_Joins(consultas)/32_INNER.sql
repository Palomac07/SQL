-- Comando que sirve para obtener los datos comunes de ambas tablas.
-- Devuelve las filas donde hay coincidencias.

-- PARA 1:1 :
-- Puede ir en ambos sentidos (tabla B tiene como FK la PK de la A en este caso).
SELECT * FROM nombreTablaA -- Poniendo * nos va a mostrar todas las columnas de ambas tablas, solo con las filas donde las columnas especificadas coinciden.
INNER JOIN nombreTablaB    -- También se puede poner simplemente JOIN, es lo mismo.
ON nombreTablaA.nombreColumnaA = nombreTablaB.nombreColumnaB; -- El ON es necesario porque sino va a mostrar las dos tablas completas.

-- Se pueden mostrar las columnas que querramos aclarando en el SELECT.
-- MUY IMPORTANTE = Nunca va a traer personas que no tengan pasaporte, ni pasaportes que no tengan persona asignada.
-- Si quisieramos, por ejemplo mostrar también las personas que no tienen pasaporte, usaríamos otro tipo de JOIN.

-- Ejemplo agregando modificadores:
SELECT Pasaporte.numero, Persona.nombre
FROM Pasaporte
INNER JOIN Persona
ON Persona.id = Pasaporte.persona_id
WHERE Persona.id = 1;
-- Muestra el nombre de la persona con ID = 1 y su número de pasaporte.

SELECT Pasaporte.numero, Persona.nombre, Persona.edad
FROM Persona                                            -- Acá cambié el orden de Persona y Pasaporte Y NO CAMBIA NADA.
INNER JOIN Pasaporte
ON Persona.id = Pasaporte.persona_id
ORDER BY Persona.edad DESC;
-- Muestra el pasaporte, el nombre y la edad de la persona, ordenados de mayor a menor por edad. NO MUESTRA PERSONAS SIN PASAPORTE NI VICERVERSA.

-- LA CONSULTA NO CREA UNA TABLA, solo muestra un resultado temporal que luego desaparece.
-- Si queremos que se guarde hay que crear una tabla:
CREATE TABLE PersonasConPasaporte AS
SELECT Pasaporte.numero, Persona.nombre, Persona.edad
FROM Persona
INNER JOIN Pasaporte
ON Persona.id = Pasaporte.persona_id
ORDER BY Persona.edad DESC;

-- Sino, podemos hacer una vista (una tabla virtual que se actualiza automáticamente):
CREATE VIEW vista_personas_pasaporte AS
SELECT Pasaporte.numero, Persona.nombre, Persona.edad
FROM Persona
INNER JOIN Pasaporte
ON Persona.id = Pasaporte.persona_id
ORDER BY Persona.edad DESC;
-- Nombre de la vista: vista_personas_pasaporte
-- Luego consultas con:
SELECT * FROM vista_personas_pasaporte;
------------------------------------------------------------------------------------------------------------------------

-- Para 1:N :
SELECT Empleado.nombre, Departamento.nombre
FROM Empleado
INNER JOIN Departamento
ON Empleado.depto_id = Departamento.id
WHERE Empleado.edad BETWEEN 18 AND 28
ORDER BY Empleado.edad ; -- Modificadores extra
-- La consulta muestra como resultado el nombre del empleado y el departamento al que pertenece (no muestra resultados con null).
-- Solamente muestra aquellos empleados que tengan entre 18 y 28 años, y los ordena de menor a mayor edad.
-- A diferencia de en 1:1, donde cada pasaporte pertenecía a un ID único, acá los departamentos pueden corresponder a varios empleados.

------------------------------------------------------------------------------------------------------------------------

-- Para N:M : Se hace un JOIN de tres tablas.
SELECT Estudiante.id, Estudiante.nombre, curso.titulo
FROM EstudianteCurso
INNER JOIN Estudiante                                 -- JOIN 1
ON Estudiante.id = EstudianteCurso.estudiante_id
INNER JOIN Curso                                      -- JOIN 2
ON Curso.id = EstudianteCurso.curso_id;
-- Muestra el ID y nombre de los estudiantes que tienen al menos un curso relacionado, así como el nombre del curso.
-- En este caso, tanto los ids y nombres de estudiantes como los nombres de los cursos se pueden repetir, pero nunca se va a repetir
-- el mismo estudiante con el mismo curso.

-- El orden en que se pongan las tablas SIGUE SIN INFLUIR.
-- Si partieramos de una de las tablas no intermedias:
SELECT Estudiante.id, Estudiante.nombre, Curso.titulo
FROM Estudiante
INNER JOIN EstudianteCurso                            -- JOIN 1
ON Estudiante.id = EstudianteCurso.estudiante_id
INNER JOIN Curso                                      -- JOIN 2
ON Curso.id = EstudianteCurso.curso_id;