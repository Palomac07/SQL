-- Realiza inserciones dentro de la tabla. Se usa cuando la fila todavía no existe.
INSERT INTO nombreTabla(nombreColumna1, nombreColumna2, nombreColumna3, ...) VALUES(valor1, valor2, valor3, ...); -- Inserta los valores en las columnas
-- correspondientes.
-- Posibles errores: si intentamos ingresar un ID que ya existe (y establecimos que ID es identificador único), no nos va a dejar.
-- Si insertamos, por ejemplo, nombre y apellido sin ID, no pasa nada porque establecimos ID como autoincremental, por lo que automaticamente lo
-- establece como el último ID +1.
-- Si insertamos un ID que no exista en la tabla y que no sea el "+1" que correspondería no pasa nada. Siempre el siguiente que se cree automáticamente
-- va a ser el mayor +1, no importa si en el medio se saltó algunos.

-- Con tabla intermedia:
INSERT INTO nombreTablaIntermedia(FKtablaA, FKtablaB) VALUES (valorA, valorB);
-- Como es muchos a muchos, esto se escribe para cada relación de la tabla.