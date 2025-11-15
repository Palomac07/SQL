-- Elimina una fila de la tabla. Siempre condición de filtrado.
DELETE FROM nombreTabla WHERE nombreColumna = criterio; -- Elimina la fila de la tabla donde el valor de la columna cumpla el criterio.

-- DELETE no sirve para eliminar un valor específico, en ese caso haríamos UPDATE y estableceríamos como null o cadena vacía ('').