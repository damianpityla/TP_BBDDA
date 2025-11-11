/* =========================================================
	04_Pruebas.sql - Com2900G13
	Proyecto: Altos de Saint Just
	Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo ejecuta las pruebas

	Alumnos:
		45628269 - Liber Federico Manuel 
		46265307 - Ares Nicolás jesús 
		45754471 - Pityla Damian 
		42587858 - Murillo Joel
		46292592 - Larriba Pedro Ezequiel 
		40464246 - Diaz Ortiz  Lucas Javier 
========================================================= */

USE Com2900G13
GO

------------------------------ BAULERAS Y COCHERAS -----------------------------

EXEC bda.spCargarBaulerasCocheras 

SELECT * FROM bda.Baulera
SELECT * FROM bda.Cochera

--DBCC CHECKIDENT ('bda.Baulera', RESEED, 0);
--DELETE FROM bda.Baulera

--DBCC CHECKIDENT ('bda.Cochera', RESEED, 0);
--DELETE FROM bda.Cochera

------------------------------ ALTA DE GASTOS EXTRAORDINARIOS -----------------------------

EXEC bda.spAltaGastoExtraordinario
	@IdConsorcio = 1,
	@Mes = 4,
	@Descripcion = 'INSTALACION CAMARAS DE SEGURIDAD PRIMER PISO',
	@Importe = 380000

EXEC bda.spAltaGastoExtraordinario
	@IdConsorcio = 1,
	@Mes = 5,
	@Descripcion = 'INSTALACION CAMARAS DE SEGURIDAD SEGUNDO PISO',
	@Importe = 570000

SELECT * FROM bda.Gastos_Extraordinarios

--DELETE FROM bda.Gastos_Extraordinarios
--DBCC CHECKIDENT ('bda.Gastos_Extraordinarios', RESEED, 0);

------------------------------ ALTA DE GASTOS ORDINARIOS DEL MES 7 -----------------------------

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 1,
	@Mes = 7,
	@ImporteBancario = 23000,
	@ImporteLimpieza = 130000,
	@ImporteAdministracion = 220000,
	@ImporteSeguros = 35000,
	@ImporteGastosGenerales = 10000,
	@ImporteAgua = 520000,
	@ImporteLuz = 560000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 2,
	@Mes = 7,
	@ImporteBancario = 24000,
	@ImporteLimpieza = 140000,
	@ImporteAdministracion = 240000,
	@ImporteSeguros = 34000,
	@ImporteGastosGenerales = 0,
	@ImporteAgua = 530000,
	@ImporteLuz = 570000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 3,
	@Mes = 7,
	@ImporteBancario = 25000,
	@ImporteLimpieza = 150000,
	@ImporteAdministracion = 240000,
	@ImporteSeguros = 37000,
	@ImporteGastosGenerales = 11000,
	@ImporteAgua = 540000,
	@ImporteLuz = 580000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 4,
	@Mes = 7,
	@ImporteBancario = 26000,
	@ImporteLimpieza = 160000,
	@ImporteAdministracion = 250000,
	@ImporteSeguros = 38000,
	@ImporteGastosGenerales = 12000,
	@ImporteAgua = 550000,
	@ImporteLuz = 590000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 5,
	@Mes = 7,
	@ImporteBancario = 27000,
	@ImporteLimpieza = 170000,
	@ImporteAdministracion = 260000,
	@ImporteSeguros = 39000,
	@ImporteGastosGenerales = 13000,
	@ImporteAgua = 560000,
	@ImporteLuz = 600000

SELECT * FROM bda.Gastos_Ordinarios WHERE mes = 7

--DELETE FROM bda.Gastos_Ordinarios WHERE mes = 7

------------------------------ GENERACION DE EXPENSAS DEL MES DE ABRIL -----------------------------

EXEC bda.spGenerarExpensas
	@MesInicio = 4,
	@MesFin = 7

SELECT * FROM bda.Expensa
SELECT * FROM bda.Detalle_Expensa ORDER BY id_expensa,id_uf

SELECT * FROM bda.vExpensaGenerada ORDER BY Uf

DBCC CHECKIDENT ('bda.Detalle_Expensa', RESEED, 0);
DELETE FROM bda.Detalle_Expensa

DBCC CHECKIDENT ('bda.Expensa', RESEED, 0);
DELETE FROM bda.Expensa