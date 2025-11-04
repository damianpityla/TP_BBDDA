/* =========================================================
	03_EjecucionSPImportacionArchivos.sql - Com2900G13
	Proyecto: Altos de Saint Just
	Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo ejecuta los SP para la importacion de datos

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

------------------------------ Activacion de consultas AD-HOC y servidor OLEDB -----------------------------

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;
    
EXEC master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;
GO

------------------------------ CONSORCIOS "datos_varios.xlsx" HOJA: Consorcios$ -----------------------------

EXEC bda.spImportarDatosConsorcios
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\datos_varios.xlsx',
	@NombreHoja = 'Consorcios$';

SELECT * FROM bda.Consorcio

--DBCC CHECKIDENT ('bda.Consorcio', RESEED, 0);
--DELETE FROM bda.Consorcio

------------------------------ UNIDADES FUNCIONALES POR CONSORCIO "UF_por_consorcio.txt" -----------------------------

--NO ANDA
EXEC bda.spImportarUnidadesFuncionales  
	@RutaArchivo= 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\UF_por_consorcio.txt';

SELECT * FROM bda.Unidad_Funcional;

--DBCC CHECKIDENT ('bda.Unidad_Funcional', RESEED, 0);
--DELETE FROM bda.Unidad_Funcional

------------------------------ PAGOS POR UNIDAD FUNCIONAL "pagos_consorcios.csv" -----------------------------

EXEC bda.spImportarPagosConsorcios
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\pagos_consorcios.csv';

SELECT * FROM bda.pagos

--DBCC CHECKIDENT ('bda.Pagos', RESEED, 0);
--DELETE FROM bda.Pagos

------------------------------ INQUILINOS Y PROPIETARIOS "inquilinos_propietarios_datos.csv" -----------------------------

EXEC bda.spImportarPropietariosInquilinos
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\inquilinos_propietarios_datos.csv';

SELECT * FROM bda.Propietario
SELECT * FROM bda.Inquilino

--DBCC CHECKIDENT ('bda.Propietario', RESEED, 0);
--DELETE FROM bda.Propietario

--DBCC CHECKIDENT ('bda.Inquilino', RESEED, 0);
--DELETE FROM bda.Inquilino

------------------------------ INQUILINOS Y PROPIETARIOS EN CADA UNIDAD FUNCIONAL "inquilinos_propietarios_UF.csv" -----------------------------

EXEC bda.spImportarPropietariosInquilinosUF
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\inquilinos_propietarios_UF.csv';

SELECT * FROM bda.Propietario_en_UF
SELECT * FROM bda.Inquilino_en_UF

--DBCC CHECKIDENT ('bda.Propietario_en_UF', RESEED, 0);
--DELETE FROM bda.Propietario_en_UF

--DBCC CHECKIDENT ('bda.Inquilino_en_UF', RESEED, 0);
--DELETE FROM bda.Inquilino_en_UF

------------------------------ GASTOS DE CADA CONSORCIO "servicios.json" -----------------------------

--NO ANDA
EXEC bda.spImportarDetalleYGastos
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\servicios.json',
	@Anio = 2025;

SELECT * FROM bda.Gastos_Ordinarios
SELECT * FROM bda.Detalle_Expensa

------------------------------ PROVEEDORES "datos_varios.xlsx" HOJA: Proveedores$ -----------------------------


EXEC bda.importarDatosVariosProveedores
	@RutaArchivo = 'C:\Users\Joeee\Desktop\TP_BBDDA\Grupo13\ArchivosImportacion\datos_varios.xlsx',
	@NombreHoja = 'Proveedores$';

SELECT * FROM bda.Proveedor
