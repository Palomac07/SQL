-- STORED PROCEDURES son consultas que se guardan en "favoritos".
-- Puede ejecutar múltiples operaciones (INSERT, UPDATE, DELETE) y lógica compleja (IF, loops, variables).
-- Usar VIEW para consultas fijas que quieres reutilizar como tablas. Usar STORED PROCEDURE cuando necesites parámetros o lógica compleja.

-- Ejemplo: consultar todos los usuarios menores de edad, y se pueden filtrar por nacionalidad.
CREATE PROCEDURE p_menores
@nacionalidad VARCHAR (50)                                           -- Este es el input (parámetro de entrada).
AS
BEGIN
    SELECT nombreUsuario, edadUsuario, nacionalidadUsuario
    FROM usuario
    WHERE edadUsuario < 18 AND nacionalidadUsuario = @nacionalidad;
    ORDER BY edadUsuario DESC;
END;
GO
-- Obviamente esto es una pavada de ejemplo, se usa para consultas más complejas.

-- Para ejecutarlo (se ejecuta, no se consulta):
EXEC p_menores @nacionalidad = 'Argentina';
-- O simplemente:
EXEC p_menores 'Argentina';
-- Va a mostrar todos los usuarios menores de edad que sean de Argentina, ordenados de mayor a menor edad.
-- Si @nacionalidad es NULL muestra todos.

-- Si @nacionalidad no existe no muestra ninguno (se puede agregar para que imprima un mensaje):
 CREATE PROCEDURE p_menores
      @nacionalidad VARCHAR(50) = NULL
  AS
  BEGIN
      -- Verificar si existe al menos un usuario con esa nacionalidad
      IF @nacionalidad IS NOT NULL AND NOT EXISTS (
          SELECT 1 FROM usuario WHERE nacionalidadUsuario = @nacionalidad
      )
      BEGIN
          PRINT 'No existen usuarios con la nacionalidad: ' + @nacionalidad;
          RETURN;  -- Sale del procedimiento
      END

      -- Si existe o es NULL, ejecuta la consulta
      SELECT nombreUsuario, edadUsuario, nacionalidadUsuario
      FROM usuario
      WHERE edadUsuario < 18
        AND (@nacionalidad IS NULL OR nacionalidadUsuario = @nacionalidad);
  END;

-- Para borrarla:
DROP PROCEDURE p_menores