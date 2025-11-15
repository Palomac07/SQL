-- Filtrado en el que se conocen precisamente los datos. Límite basado en uno o varios elementos conocidos.
-- O sea, comprobar que un campo tome diferentes valores y filtrarlo.
-- No es case sensitive. Es necesario usar COMILLAS SIMPLES.
-- Las comillas dobles se usan solo en algunas bases de datos, es SQL Server no se usan nunca (se usan corchetes en su lugar).
-- Los corchetes se usan para nombres con espacios o caracteres especiales.
SELECT * FROM nombreTabla WHERE nombreColumna IN('valor');
-- Se pueden seleccionar varios valores (IN('valor1','valor2'))
-- A diferencia del LIKE, acá tienen que coincidir 100%.