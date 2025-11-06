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

------------------------------ GENERACION DE ALGUNOS DATOS RANDOM -----------------------------

INSERT INTO bda.Cochera VALUES (4,1)
SELECT * FROM bda.Cochera

INSERT INTO bda.Baulera VALUES (4,1)
SELECT * FROM bda.Baulera

INSERT INTO bda.Gastos_Extraordinarios(id_uf,descripcion,importe) VALUES(4,'AIRE ACONDICIONADO', 63000)
SELECT * FROM bda.Gastos_Extraordinarios

delete from bda.Gastos_Extraordinarios

------------------------------ GENERACION DE EXPENSAS DEL MES DE ABRIL -----------------------------

EXEC bda.spGenerarExpensas
	@Mes = 4,
	@FechaEmision = '2025-04-10',
	@FechaVencimiento1 = '2025-04-12',
	@FechaVencimiento2 = '2025-04-15'

SELECT * FROM bda.Expensa
SELECT * FROM bda.Detalle_Expensa

SELECT * FROM bda.vExpensaGenerada ORDER BY Uf

--DBCC CHECKIDENT ('bda.Detalle_Expensa', RESEED, 0);
--DELETE FROM bda.Detalle_Expensa

--DBCC CHECKIDENT ('bda.Expensa', RESEED, 0);
--DELETE FROM bda.Expensa