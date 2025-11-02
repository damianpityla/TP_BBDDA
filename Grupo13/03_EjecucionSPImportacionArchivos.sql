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