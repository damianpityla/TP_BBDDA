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


--FALTA PROBAR YA QUE FALTAN UF Y CONSORCIOS
EXEC bda.spImportarDetalleYGastosDesdeJSON
	@RutaArchivo = 'C:\Users\damip\Downloads\consorcios\Servicios.json',
	@Anio = 2025;
SELECT * FROM bda.Gastos_Ordinarios
SELECT * FROM bda.Detalle_Expensa
SELECT * FROM bda.Propietario
SELECT * FROM bda.Inquilino

exec bda.ImportarUnidadesFuncionales  
@RutaArchivo= 'C:\Users\User\Documents\GitHub\TP_BBDDA\Grupo13\ArchivosImportacion\UF por consorcio.txt';
select * from bda.Unidad_Funcional;