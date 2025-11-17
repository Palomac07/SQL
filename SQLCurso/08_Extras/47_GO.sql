-- GO es un separador de lotes. No es un comando SQL, sino una instrucción del cliente (SSMS).
-- Divide el script en lotes separados que se ejecutan uno después del otro.

-- Se usa después de:
-- CREATE DATABASE.
-- CREATE/ALTER PROCEDUER/FUNCTION/TRIGGER/VIEW.
-- USE.

-- Cada GO reinicia el contexto:
-- Las variables declaradas antes de GO no existen después.
-- Cada lote se compila y ejecuta por separado.

-- GO con repeticiones: Se puede repetir un lote múltiples veces.
INSERT INTO logs (mensaje, fecha)
VALUES ('Test', GETDATE());
GO 10  -- Ejecuta el INSERT 10 veces.
-- Resultado: 10 filas insertadas.