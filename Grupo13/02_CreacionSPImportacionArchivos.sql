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
USE Com2900G13
GO

CREATE OR ALTER PROCEDURE bda.spImportarPagosConsorciosCsv 
	@RutaArchivo NVARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tmpPagos( 
		id_pago INT IDENTITY(10000,1) PRIMARY KEY NOT NULL,
		fecha_pago VARCHAR(10) NOT NULL,
		cta_origen VARCHAR(22) NOT NULL,
		importe VARCHAR(12) NOT NULL
	)
	--HAY QUE USAR UNA TABLA TEMPORAL PARA PODER CASTEAR DOS TIPOS DE DATO DEL .CSV:
	--LA FECHA DEL PAGO ESTA EN FORMATO DD/MM/YYYY, EL MOTOR NO LO RECONOCE COMO DATE
	--EL IMPORTE TIENE EL SIGNO $, EL MOTOR NO LO RECONOCE COMO DECIMAL(10,2)
	--ENTONCES LOS TIPOS DE DATO SON VARCHAR

	DECLARE @SQL NVARCHAR(MAX) = ''

	SET @SQL = '
	BULK INSERT #tmpPagos
	FROM ''' + @RutaArchivo + '''
	WITH(
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''ACP'',
		FIRSTROW = 2
	)'

	EXEC sp_executesql @SQL;
	--USAMOS SQL DINAMICO PARA INSERTAR LA VARIABLE DE LA RUTA DEL ARCHIVO EN EL BULK INSERT

	DELETE FROM #tmpPagos WHERE id_pago IN (SELECT MAX(id_pago) FROM #tmpPagos)
	--HAY UN REGISTRO EN EL .CSV QUE MARCA EL FIN DE ARCHIVO

	INSERT INTO bda.Pagos (id_pago,fecha_pago,cta_origen,importe)
	SELECT id_pago,CONVERT(date, fecha_pago, 103),cta_origen,REPLACE(importe, '$', '') FROM #tmpPagos
	--ENTONCES MODIFICO LOS VARCHAR A MI GUSTO Y LOS INSERTO EN LA TABLA QUE NOS IMPORTA, QUE ES LA DE PAGOS

	DROP TABLE IF EXISTS #tmpPagos

	--SELECT * FROM bda.Pagos --ESTADO FINAL DE LA TABLA
	--DELETE FROM bda.Pagos

	PRINT('Archivo de pagos por consorcio importado exitosamente');
END
GO