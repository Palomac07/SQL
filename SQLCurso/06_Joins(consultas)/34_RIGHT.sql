-- Opuesto al LEFT: Trae toda la tabla B y solo lo que coincide de la A.

-- PARA 1:1 :
SELECT *
FROM nombreTablaA
RIGHT JOIN nombreTablaB
ON nombreTablaA.nombreColumnaA = nombreTablaB.nombreColumnaB;

-- Ejemplo:
SELECT Pasaporte.numero, Persona.nombre
FROM Persona
RIGHT JOIN Pasaporte
ON Persona.id = Pasaporte.persona_id;
-- Va a mostrar los números de todos los pasaportes, sin importar que no tengan ninguna persona asociada.
-- Las personas que no tengan pasaportes asociados no van a aparecer.

------------------------------------------------------------------------------------------------------------------------
-- Para 1:N :
SELECT Empleado.nombre, Departamento.nombre
FROM Empleado
RIGHT JOIN Departamento
ON Empleado.depto_id = Departamento.id
WHERE Empleado.edad BETWEEN 18 AND 28
ORDER BY Empleado.edad ;
-- Muestra los nombres de todos los departamentos, sin importar que ningún empleado pertenezca a ellos.
-- No muestra los empleados que no tienen departamentos.
-- Sigue filtrando por empleados que tengan entre 18 y 38.
-- Ordena de menor a mayor según la edad de los empleados QUE APAREZCAN.

------------------------------------------------------------------------------------------------------------------------
-- Para N:M :
SELECT Estudiante.id, Estudiante.nombre, Curso.titulo
FROM Estudiante
RIGHT JOIN EstudianteCurso                            -- JOIN 1
ON Estudiante.id = EstudianteCurso.estudiante_id
RIGHT JOIN Curso                                      -- JOIN 2
ON Curso.id = EstudianteCurso.curso_id;
-- Muestra todos los cursos, incluso si no tienen estudiantes inscritos (null).
-- JOIN 1: Prioriza EstudianteCurso (null en Estudiante.id si en un EstudianteCurso no hay id de estudiante).
-- JOIN 2: Prioriza Curso (null en EstudianteCurso si un curso existe pero no está en la tabla intermedia).
-- Efecto combinado: Se priorizan los cursos, pero también pueden aparecer inscripciones sin estudiante.

-- RIGHT JOIN es confuso. Es más difícil de leer porque va "hacia atras".
-- Se podría simpligicar con un LEFT ordenado como (Curso - EstudianteCurso - Estudiante).
-- Da el mismo resultado, solo es más fácil de entender.
