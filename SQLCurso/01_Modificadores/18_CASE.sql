-- Decidir en función de un resultado qué va a pasar.
SELECT *,                                       -- Muy importante la , (antes no se usaba, acá es necesaria).
CASE
    WHEN nombreColumna = criterio THEN 'texto'
    ELSE 'texto alternativo'
END AS nuevoNombre                              -- Igual que siempre es opcional pero recomendado, sino va a imprimir la primera condición.
FROM nombreTabla;
-- Estamos seleccionando todas las filas de la tabla. Para cada fila, si la columna condicional cumple con el criterio dado, imprimimos otra cosa. Si
-- no cumple imprimimos otra cosa. La tabla resutado se va a imprimir con el nuevo nobre.

-- Acá entramos en consultas de varias lineas. Se separa así para una mejor comprensión, pero cuaquier consulta se puede escribir de ambas formas.
-- Es recomendable escribirlas de esta forma salvo que sean muy cortas.

-- Un buen uso para CASE son los Boolean: como título (AS) se pone una pregunta ('¿Es mayor de edad?') y como valores de las celdas (CASE y ELSE) se
-- pone True (va a imprimir 1) o False (va a imprimir 0).

-- También se pueden agregar condiciones:
SELECT *,
CASE
    WHEN nombreColumna = criterio1 THEN 'texto1' -- Supongamos que preguta si es mayor de edad.
    WHEN nombreColumna = criterio2 THEN 'texto2' -- Supongamos que pregunta si tiene exactamente 18 años.
    ELSE 'texto alternativo'
END AS nuevoNombre
FROM nombreTabla;
-- Resultado: Aunque se cumplan ambos WHEN mprime solo el primer texto en la celda correspondiente. Funciona como un IF: si se cumple el condicional
-- ya no chequea el resto de las posibilidades.

-- Una posible alternativa:
SELECT *,
CASE
    WHEN nombreColumna = criterio1 THEN 'texto1' -- Supongamos que preguta si es mayor de 18.
    WHEN nombreColumna = criterio2 THEN 'texto2' -- Supongamos que pregunta si tiene exactamente 18 años.
    ELSE 'texto alternativo'
END AS nuevoNombre
FROM nombreTabla;
-- Acá (cuando el valor es 18) no se cumple el primer WHEN, pero el segundo sí, entonces se imprime el segundo texto. También se podría simplemente
-- haber cambiado el orden (primero chequea si tiene 18, entonces no llega a chequear si es mayor de edad).
