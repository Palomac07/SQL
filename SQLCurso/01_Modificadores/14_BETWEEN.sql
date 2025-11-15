-- Sirve para encontrar un resultado que se comprenda entre dos valores (un valor mínimo y uno máximo).
-- Es lo mismo que hacer:
SELECT * FROM nombreTabla WHERE nombreColumnaCondicional >= valorMin AND nombreColumnaCondicional <= valorMax;
-- Eso mostraría todas las filas de la tabla donde el valor de la columna condicional sea mayor o igual que el mínimo y menor o igual que el máximo.
-- BETWEEN lo simplifica:
SELECT * FROM nombreTabla WHERE nombreColumnaCondicional BETWEEN minimo AND maximo;