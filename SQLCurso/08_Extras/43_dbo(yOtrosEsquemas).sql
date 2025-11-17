-- dbo significa Database Owner y es el esquema por defecto en SQL SERVER.
-- Un esquema es como una carpeta o namespace que agrupa objetos de la base de datos (tablas, vistas, procedimientos, ect.)

-- USOS:

-- 1) Especificar el esquema de un objeto:
-- Forma completa
SELECT * FROM dbo.usuario;
-- Forma corta (usa dbo por defecto si no especificas)
SELECT * FROM usuario;
-- Ambas son equivalentes si usario está en el esquema dbo.

-- 2) Crear objetos en el esquema dbo:
-- Crear tabla en dbo
CREATE TABLE dbo.usuario(
    id INT PRIMARY KEY,
    nombre VARCHAR(50)
)

-- 3) Cuando hay múltiples esquemas:
-- Se pueden crear diferentes esquemas para organizar objetos.

-- Crear esquemas personalizados
CREATE SCHEMA ventas;
CREATE SCHEMA administracion;

-- Crear tablas en diferentes esquemas
CREATE TABLE dbo.usuario (...);           -- Esquema por defecto
CREATE TABLE ventas.producto (...);       -- Esquema de ventas
CREATE TABLE administracion.log (...);    -- Esquema de administración

-- Consultar especificando el esquema
SELECT * FROM dbo.usuario;
SELECT * FROM ventas.producto;
SELECT * FROM administracion.log;

-- Es OBLIGATORIO usarlo cuando hay AMBIGUEDAD:
-- Si hay dos tablas con el mismo nombre en diferentes esquemas.

------------------------------------------------------------------------------------------------------------------------

-- SYS
-- sys es un ESQUEMA DEL SISTEMA, que contiene vistas y funciones del sistema con información sobre la base de datos (tablas, columnas, índices,
-- constraints, usuarios, permisos, estadísticas, etc.).

-- Ver todas las tablas
SELECT * FROM sys.tables;

-- Ver todas las columnas
SELECT * FROM sys.columns;

-- Ver todos los índices
SELECT * FROM sys.indexes;

-- Ver todas las constraints
SELECT * FROM sys.check_constraints;
SELECT * FROM sys.foreign_keys;
SELECT * FROM sys.key_constraints;

-- Ver todas las bases de datos
SELECT * FROM sys.databases;

-- Ver todos los procedimientos almacenados
SELECT * FROM sys.procedures;

-- Ver todas las vistas
SELECT * FROM sys.views;

-- Ver todos los usuarios
SELECT * FROM sys.database_principals;

------------------------------------------------------------------------------------------------------------------------

-- El otro esquema existente es INFORMATION_SCHEMA, tiene las vistas estándar SQL.
-- sys es más completo.
