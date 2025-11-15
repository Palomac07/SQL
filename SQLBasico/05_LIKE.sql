-- Criterio de búsqueda variable. Con que una parte cumpla, ya se agrega (por ejemplo que contenga @gmail).
SELECT nombreColumnaIndicada FROM nombreTabla WHERE nombreColumnaCondicional LIKE criterioAmplio; -- Devuelve los valores de la columna indicada donde
-- la columna condicional cumpla con el criterio amplio.
-- IMPORTANTE: si queremos indicar que el mail termina en @gmail.com, hay que escirbirlo como '%gmail.com'. Las comillas van siempre que el criterio
-- sea un string, y el porcentaje indica que hay una cantidad variable de valores antes de la parte que debe coincidir.
