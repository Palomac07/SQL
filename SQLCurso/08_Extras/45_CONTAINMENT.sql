-- CONTAINMENT es una característica de SQL Server que permite crear bases de datos parcial o totalmente independientes de la instancia del servidor.
-- Cosas como usuarios, logins y coonfiguraciones se almacenan a nivel de servidor. Con CONTAINMENT, se puede incluirlas dentro de la base
-- de datos, haciendola más portable y autónoma.

-- TIPOS

-- 1) NONE (por defecto):
-- La base de datos no es contenida. Depende del servidor para logins, configuraciones, etc.
CREATE DATABASE Base
CONTAINMENT = NONE;

-- 2) PARTIAL
-- La base de datos es parcialmente contenida. Algunos elementos (como usuarios) pueden estar dentrp de la DB.
CREATE DATABASE Base
CONTAINMENT = PARTIAL;
-- Ventajas:
-- Usuarios contenidos en la DB:
-- Sin CONTAINMENT, se necesita login a nivel de servidor y usuario a nivel de base de datos.
-- Con CONTAINMENT, se puede crear un usuario directamente en la DB (sin login en servidor) y sarle permisos.
-- Portabilidad: Si se mueve la DB a otro servidor, los usuarios ya vienen incluidos.
-- Aislamiento de configuraciones: Se puede configurar, por ejemplo, el idioma a nivel de DB contenida.
