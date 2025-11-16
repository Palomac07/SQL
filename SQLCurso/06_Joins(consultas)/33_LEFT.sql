-- Muestra todos los datos de la tabla A incluyendo los que tiene en común con la B, pero no muestra el resto de los datos de la tabla B.

-- PARA 1:1 :
SELECT * FROM nombreTablaA -- Poniendo * nos va a mostrar todas las columnas de ambas tablas, con las filas donde las columnas especificadas coinciden Y
-- también el resto donde la tabla A podría no estar relacionada con la B (o sea la celda puede decir null en la parte correspondiente a B).
LEFT JOIN nombreTablaB
ON nombreTablaA.nombreColumnaA = nombreTablaB.nombreColumnaB;

-- Ejemplo:
SELECT Pasaporte.numero, Persona.nombre
FROM Persona
LEFT JOIN Pasaporte
ON Persona.id = Pasaporte.persona_id;
-- Muestra los nombres de TODAS las personas.
-- Si tienen un pasaporte asignado, se muestra el número, y sino null en su lugar.
-- SIGUE SIN MOSTRAR los pasaportes sin personas (en ese caso tendríamos que haberlo ESCRITO AL REVÉZ - FROM Psaporte LEFT JOIN Persona).

------------------------------------------------------------------------------------------------------------------------
-- Para 1:N :
SELECT Empleado.nombre, Departamento.nombre
FROM Empleado
LEFT JOIN Departamento
ON Empleado.depto_id = Departamento.id
WHERE Empleado.edad BETWEEN 18 AND 28
ORDER BY Empleado.edad ;
-- Muestra los nombre de TODOS los empleados que tengan entre 18 años, ordenados de menor a mayor.
-- Si el empleado tiene un departamento asignado, se muestra su nombre, sino se muestra null en esa fila de la columna.
-- No muestra los departamentos sin empleados.

-- Como un empleado puede tener un solo departamento, los empleados van a aparecer una sola vez, y los departamentos varias.

-- Si lo hubieramos escrito al revez (FROM Departamento...), lo único que cambiaría es que mostraría todos los departamentos pero
-- no mostraría los empleados sin departamento.

------------------------------------------------------------------------------------------------------------------------
-- Para N:M :
SELECT Estudiante.id, Estudiante.nombre, Curso.titulo
FROM Estudiante
LEFT JOIN EstudianteCurso                            -- JOIN 1
ON Estudiante.id = EstudianteCurso.estudiante_id
LEFT JOIN Curso                                      -- JOIN 2
ON Curso.id = EstudianteCurso.curso_id;

-- Acá importa mucho el órden.
-- Esto es así: Muestra TODOS los estudiantes con los cursos en los que estan inscritos. Si un estudiante no está inscrito en  ningún curso,
-- aparece con null en curso.titulo

-- Explicación paso a paso:

-- JOIN 1: Trae todos los estudiantes. Si están inscritos en cursos, trae las relaciones de EstudianteCurso, sino aparece igual (con null en
-- las columnas de EstudianteCurso

-- JOIN 2: Conecta las inscripciones con los datos del curso. Si hay inscripción, trae el título del curso, sino (null del join 1), completa
-- con null.