-- Modificar un valor de la tabla. Siempre se hacen con un condicional. Se usa cuando la fila ya existe.
UPDATE nombreTabla SET nombreColumnaCambiar = nuevoValor WHERE nombreColumnaCondicional = criterio; -- Edita el o los valores de la columna cambiar
-- donde la columna condicional cumpla el criterio (por ejemplo la columna condicional sería un nombre o un ID).
UPDATE nombreTabla SET nombreColumnaCambiar1 = nuevoValor1, nombreColumnaCambiar2 = nuevoValor2 WHERE nombreColumnaCondicional = criterio; -- Se pueden
-- cambiar varios valores de distintas columnas a la vez.
