-- Disparador. Instrucciones que se ejecutan automáticamente cuando ocurren eventos en la tabla.
-- Evento programado.

-- Ejemplo de disparador: si un usuario actualiza su contraseña, que se guarde automáticamente la anterior en otra tabla.
-- PASOS

-- 1) Crear la nueva tabla:
CREATE TABLE historialContraseña (
    idContraseña INT IDENTITY PRIMARY KEY,
    idUsuario INT NOT NULL,
    valorContraseña VARCHAR(15) CHECK),
    CONSTRAINT CK_valorContraseña CHECK (LEN(valorContraseña) >= 6)
)

-- 2) Crear el TRIGGER:
CREATE TRIGGER tg_cambioContraseña
-- Posibilidades: BEFORE/AFTER UPDATE/DELETE/INSERT
AFTER UPDATE
ON usuario
FOR EACH ROW                                                        -- Para cada fila (se usa así)
-- Empezar a escribir la instrucción:
BEGIN
    IF OLD.contraseñaUsuario <> NEW.contraseñaUsuario THEN          -- OLD y NEW también son palabras reservadas. <> significa diferente en SQL.
        INSERT INTO historialContraseña(idUsuario, valorContraseña)
        VALUES (OLD.idUsuario, OLD.contraseñaUsuario);
    END IF;
END;

-- 3) Chequear si funciona:
SELECT contraseñaUsuario FOR usuario WHERE idUsuario = 6;                  -- Mostrar la contraseña actual.
UPDATE usuario SET contraseñaUsuario = 'Paloma123' WHERE idUsuario = 6; -- Actualiza la contraseña para el usuario 6 (asegurarse de que sea diferente).
SELECT contraseñaUsuario FOR usuario WHERE idUsuario = 6;                  -- Tiene que mostrar la nueva contraseña.
SELECT * FOR historialContraseña WHERE idUsuario = 6;                      -- Tiene que mostrar la contraseña vieja.

-- Aclaración: si el usuario "actualiza" su contraseña pero escribe la misma que estaba antes, no se va a activar el TRIGGER.
-- Podría crearse otro TRIGGER para cuando pasa esto: que el usuario no pueda actualizar su contraseña sin cambiar nada.

-- 4) Si lo queremos eliminar:
DROP TRIGGER tg_cambioContraseña;