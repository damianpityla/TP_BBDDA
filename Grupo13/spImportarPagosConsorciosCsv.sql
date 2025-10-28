/* =========================================================
	importarPagos.sql - Com2900G13
	Proyecto: Altos de Saint Just (BDA)
	Importamos el archivo de pagos_consorcios.csv

	Alumnos:
		45628269 - Liber Federico Manuel 
		46265307 - Ares Nicolás jesús 
		45754471 - Pityla Damian 
		42587858 - Murillo Joel
		46292592 - Larriba Pedro Ezequiel 
		40464246 - Diaz Ortiz  Lucas Javier 

========================================================= */

DROP TABLE IF EXISTS #tmpPagos
GO

CREATE TABLE #tmpPagos( 
	id_pago INT IDENTITY(10000,1) PRIMARY KEY NOT NULL,
	fecha_pago VARCHAR(10) NOT NULL,
	cta_origen VARCHAR(22) NOT NULL,
	importe VARCHAR(12) NOT NULL
)
GO

--HAY QUE USAR UNA TABLA TEMPORAL PARA PODER CASTEAR DOS TIPOS DE DATO DEL .CSV:
--LA FECHA DEL PAGO ESTA EN FORMATO DD/MM/YYYY, EL MOTOR NO LO RECONOCE COMO DATE
--EL IMPORTE TIENE EL SIGNO $, EL MOTOR NO LO RECONOCE COMO DECIMAL(10,2)
--ENTONCES LOS TIPOS DE DATO SON VARCHAR

DROP PROCEDURE IF EXISTS bda.spImportarPagosConsorciosCsv
GO

CREATE PROCEDURE bda.spImportarPagosConsorciosCsv AS
BEGIN
	BULK INSERT #tmpPagos
	FROM 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\CSVData\pagos_consorcios.csv' --SOLO SIRVE PARA MI PC
	WITH(
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP',
		FIRSTROW = 2
		--ERRORFILE = 'C:\Users\fedel\OneDrive\Documentos\GitHub\TP_BBDDA\CSVData\myRubbishData.log'
		--MUESTRA UN ARCHIVO LOG CON LOS REGISTROS QUE NO SE PUDIERON IMPORTAR
		--SI NO HAY REGISTROS ERRONEOS, EL ARCHIVO LOG NO SE CREA
	)
END
GO

EXEC bda.spImportarPagosConsorciosCsv

SELECT * FROM #tmpPagos --SI QUIEREN VER LA PREVIEW DE LA TABLA TEMPORAL

DELETE FROM #tmpPagos WHERE id_pago = 11800
--HAY UN REGISTRO EN EL .CSV QUE MARCA EL FIN DE ARCHIVO
--PERO CREO QUE NO SE PUEDE HARDCODEAR, NO NECESARIAMENTE TIENE QUE SER EL DE ID 11800

INSERT INTO bda.Pagos (id_pago,fecha_pago,cta_origen,importe)
SELECT id_pago,CONVERT(date, fecha_pago, 103),cta_origen,REPLACE(importe, '$', '') FROM #tmpPagos

--ENTONCES MODIFICO LOS VARCHAR A MI GUSTO Y LOS INSERTO EN LA TABLA QUE NOS IMPORTA, QUE ES LA DE PAGOS

SELECT * FROM bda.Pagos --ESTADO FINAL DE LA TABLA