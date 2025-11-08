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

------------------------------ GENERACION DE GASTOS EXTRAORDINARIOS -----------------------------

INSERT INTO bda.Gastos_Extraordinarios(id_consorcio,descripcion,importe) VALUES(1,'INSTALACION CAMARAS DE SEGURIDAD',380000)
SELECT * FROM bda.Gastos_Extraordinarios

--DELETE FROM bda.Gastos_Extraordinarios

------------------------------ GENERACION DE EXPENSAS DEL MES DE ABRIL -----------------------------

EXEC bda.spGenerarExpensas
	@Mes = 4,
	@FechaEmision = '2025-04-10',
	@FechaVencimiento1 = '2025-04-12',
	@FechaVencimiento2 = '2025-04-15'

SELECT * FROM bda.Expensa
SELECT * FROM bda.Detalle_Expensa ORDER BY id_expensa,id_uf

SELECT * FROM bda.vExpensaGenerada ORDER BY Uf

DBCC CHECKIDENT ('bda.Detalle_Expensa', RESEED, 0);
DELETE FROM bda.Detalle_Expensa

DBCC CHECKIDENT ('bda.Expensa', RESEED, 0);
DELETE FROM bda.Expensa