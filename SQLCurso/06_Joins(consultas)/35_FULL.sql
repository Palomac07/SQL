-- El FULL JOIN se queda con todos los datos de ambas tablas.
-- En sql Server existe, sólo en MySQL no existe y hay que usar una combinación.

-- Para 1:1 :
SELECT Persona.id, Persona.nombre, Pasaporte.titulo
FROM Persona
FULL OUTER JOIN Pasaporte
ON Persona.id = Pasporte.persona_id;

-- Equivale a:
SELECT Persona.id, Persona.nombre, Pasaporte.numero
FROM Persona
LEFT JOIN Pasaporte ON Persona.id = Pasaporte.persona_id

UNION

SELECT Persona.id, Persona.nombre, Pasaporte.numero
FROM Persona
RIGHT JOIN Pasaporte ON Persona.id = Pasaporte.persona_id
WHERE Persona.id IS NULL;
-- Por suerte tod eso nosotros no lo tenemos que hacer, pero lo dejo para saberlo.

------------------------------------------------------------------------------------------------------------------------
-- Para 1:N :
SELECT Empleado.nombre, Departamento.nombre
FROM Empleado
FULL JOIN Departamento
ON Empleado.depto_id = Departamento.id
-- No podemos usar (WHERE Empleado.edad BETWEEN 18 AND 28): Los departamentos sin empleados tendrán NULL en Empleado.edad,
-- entonces serán eliminados por el WHERE.
ORDER BY Empleado.edad ;
-- Muestra los nombres de todos los empleados y los de todos los departamentos (con null donde no hay coincidencias).
-- Si hubiera dejado el WHERE, se comportaría como un INNER JOIN.

-- SI QUISIERA PONER LA CONDICIÓN:
 SELECT Empleado.nombre, Departamento.nombre
FROM Empleado
FULL JOIN Departamento
ON Empleado.id = Departamento.persona_id
AND Empleado.edad BETWEEN 18 AND 28         -- Los ids coinciden Y la edad está dentro de los límites.
ORDER BY Empleado.edad;
-- Acá va a mostrar todos los departamentos Y todos los empleados QUE CUMPLAN LA CONDICIÓN.
-- Si un empleado está asignado a un depto pero no cumple la condición, se rellena con null.
-- Lo importante es que siguen apareciendo todos los departamentos, a diferencia de con el WHERE.

------------------------------------------------------------------------------------------------------------------------
-- Para N:M :
SELECT Estudiante.id, Estudiante.nombre, Curso.titulo
FROM Estudiante
FULL JOIN EstudianteCurso                            -- JOIN 1
ON Estudiante.id = EstudianteCurso.estudiante_id
FULL JOIN Curso                                      -- JOIN 2
ON Curso.id = EstudianteCurso.curso_id;
-- Muestra TODOS los estudiantes Y TODOS los cursos, incluyendo:
-- Estudiantes sin cursos
-- Cursos sin estudiantes
-- Las inscripciones normales (estudiantes con cursos)

-- FULL JOIN 1:
-- Trae todos los estudiantes (incluso sin inscripciones)
-- Trae todas las inscripciones (incluso si falta el estudiante)

-- FULL JOIN 2:
-- Trae todos los cursos (incluso sin estudiantes)
-- Completa los datos de las inscripciones del JOIN anterior.
