/* =========================================================
	03_EjecucionSPImportacionArchivos - Com2900G13
	Proyecto: Altos de Saint Just (BDA)
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

EXEC bda.spImportarPagosConsorciosCsv
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\pagos_consorcios.csv';

SELECT * FROM bda.pagos

EXEC bda.spImportarPropietariosInquilinosCsv
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\inquilino-propietarios-datos.csv';

SELECT * FROM bda.Propietario
SELECT * FROM bda.Inquilino

EXEC bda.spImportarPropietariosInquilinosUFCsv
	@RutaArchivo = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\inquilino-propietarios-UF.csv';

SELECT * FROM bda.Propietario_en_UF
SELECT * FROM bda.Inquilino_en_UF

--FALTA PROBAR YA QUE FALTAN UF Y CONSORCIOS
EXEC bda.spImportarDetalleYGastosDesdeJSON
	@RutaArchivo = 'C:\Users\damip\Downloads\consorcios\Servicios.json',
	@Anio = 2025;
SELECT * FROM bda.Gastos_Ordinarios
SELECT * FROM bda.Detalle_Expensa

exec bda.ImportarUnidadesFuncionales  
@RutaArchivo= 'C:\Users\User\Documents\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\UF por consorcio.txt';
select * from bda.Unidad_Funcional;
GO

------------------------------ AD HOC PARA IMPORTAR EXCEL -----------------------------
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

EXEC bda.importarDatosVariosConsorcios
@rutaArchivo = 'C:\Users\User\Documents\Facultad\Bases de Datos Aplicadas\TP\TP_BBDDA\Grupo13\ArchivosImportacion\datos varios',
@nombreHoja = 'Consorcios$';
SELECT * FROM bda.Consorcio