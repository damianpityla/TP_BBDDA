/* =========================================================
   CreateDB.sql - Com2900G13
   Proyecto: Altos de Saint Just (BDA)
   Alumnos:
   45628269 - Liber Federico Manuel 
   46265307 - Ares Nicolás jesús 
   45754471 - Pityla Damian 
   42587858 - Murillo Joel
   46292592 - Larriba Pedro Ezequiel 
   40464246 - Diaz Ortiz  Lucas Javier 

   Crea la base y el esquema de trabajo.
   ========================================================= */

IF DB_ID('Com2900G13') IS NULL
BEGIN
  CREATE DATABASE Com2900G13;
END
GO
USE Com2900G13;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bda')
  EXEC('CREATE SCHEMA bda');
GO