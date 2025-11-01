/* =========================================================
	CreateDB.sql - Com2900G13
	Proyecto: Altos de Saint Just (BDA)
	Crea la base y el esquema de trabajo.

	Alumnos:
		45628269 - Liber Federico Manuel 
		46265307 - Ares Nicolás jesús 
		45754471 - Pityla Damian 
		42587858 - Murillo Joel
		46292592 - Larriba Pedro Ezequiel 
		40464246 - Diaz Ortiz  Lucas Javier 

========================================================= */

USE MASTER
GO

IF NOT EXISTS (SELECT NAME FROM master.dbo.sysdatabases WHERE name = 'Com2900G13')
BEGIN
	CREATE DATABASE Com2900G13
	COLLATE Latin1_General_CI_AI
END 
GO

USE Com2900G13
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bda')
BEGIN
	EXEC('CREATE SCHEMA bda')
END
GO