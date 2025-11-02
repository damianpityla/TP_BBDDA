/* =========================================================
	02_CreacionSPImportacionArchivos - Com2900G13
	Proyecto: Altos de Saint Just (BDA)
	Este archivo crea los SP para la importacion de datos

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

	DECLARE @FilasInsertadas INT,
			@FilasDuplicadas INT;

	CREATE TABLE #tmpPagos( 
		id_pago INT IDENTITY(10000,1) PRIMARY KEY NOT NULL,
		fecha_pago VARCHAR(10) NOT NULL,
		cta_origen VARCHAR(22) NOT NULL,
		importe VARCHAR(12) NOT NULL
	)
	/*HAY QUE USAR UNA TABLA TEMPORAL PARA PODER CASTEAR DOS TIPOS DE DATO DEL .CSV:
	LA FECHA DEL PAGO ESTA EN FORMATO DD/MM/YYYY, EL MOTOR NO LO RECONOCE COMO DATE
	EL IMPORTE TIENE EL SIGNO $, EL MOTOR NO LO RECONOCE COMO DECIMAL(10,2)
	ENTONCES LOS TIPOS DE DATO SON VARCHAR*/

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
	SELECT id_pago,CONVERT(date, fecha_pago, 103),cta_origen,REPLACE(importe, '$', '') FROM #tmpPagos t1
	WHERE NOT EXISTS(SELECT id_pago FROM bda.pagos t2 WHERE t1.id_pago = t2.id_pago)
	--ENTONCES MODIFICO LOS VARCHAR A MI GUSTO Y LOS INSERTO EN LA TABLA QUE NOS IMPORTA, QUE ES LA DE PAGOS
	--ADEMAS EVITO LA INSERCION DE DUPLICADOS

	SET @FilasInsertadas = @@ROWCOUNT
	SET @FilasDuplicadas = (SELECT COUNT(*) FROM #tmpPagos) - @FilasInsertadas

	--SELECT * FROM bda.Pagos
	--DELETE FROM bda.Pagos

	PRINT('Se ha importado el archivo de pagos por consorcio
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END
GO

CREATE OR ALTER PROCEDURE bda.spImportarPropietariosInquilinosCsv
	@RutaArchivo NVARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @FilasInsertadasPropietario INT,
			@FilasDuplicadasPropietario INT,
			@FilasInsertadasInquilino INT,
			@FilasDuplicadasInquilino INT

	CREATE TABLE #tmpPropietarioInquilino( 
		Nombre VARCHAR(30),
		Apellido VARCHAR(30),
		DNI VARCHAR(15),
		Email VARCHAR(60),
		Telefono VARCHAR(15),
		CVU_CBU VARCHAR(22),
		Inquilino CHAR(1)
	)

	DECLARE @SQL NVARCHAR(MAX) = ''

	SET @SQL = '
	BULK INSERT #tmpPropietarioInquilino
	FROM''' + @RutaArchivo + '''
	WITH(
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''ACP'',
		FIRSTROW = 2
	)'

	EXEC sp_executesql @SQL;

	DELETE FROM #tmpPropietarioInquilino WHERE Nombre IS NULL

	INSERT INTO bda.Propietario (Nombre,Apellido,DNI,Email,Telefono,CVU_CBU)
	SELECT LTRIM(UPPER(Nombre)),LTRIM(UPPER(Apellido)),DNI,REPLACE(LOWER(Email), ' ', ''),Telefono,CVU_CBU FROM #tmpPropietarioInquilino t1
	WHERE NOT EXISTS(SELECT DNI FROM bda.Propietario t2 WHERE t1.DNI COLLATE Latin1_General_CI_AI = t2.DNI COLLATE Latin1_General_CI_AI)
	AND Inquilino = 0

	SET @FilasInsertadasPropietario = @@ROWCOUNT
	SET @FilasDuplicadasPropietario = (SELECT COUNT(*) FROM bda.Propietario) - @FilasInsertadasPropietario

	INSERT INTO bda.Inquilino (Nombre,Apellido,DNI,Email,Telefono,CVU_CBU)
	SELECT LTRIM(UPPER(Nombre)),LTRIM(UPPER(Apellido)),DNI,REPLACE(LOWER(Email), ' ', ''),Telefono,CVU_CBU FROM #tmpPropietarioInquilino t1
	WHERE NOT EXISTS(SELECT DNI FROM bda.Inquilino t2 WHERE t1.DNI COLLATE Latin1_General_CI_AI = t2.DNI COLLATE Latin1_General_CI_AI)
	AND Inquilino = 1

	SET @FilasInsertadasInquilino = @@ROWCOUNT
	SET @FilasDuplicadasInquilino = (SELECT COUNT(*) FROM bda.Inquilino) - @FilasInsertadasInquilino

	--SELECT * FROM bda.Propietario
	--DELETE FROM bda.Propietario

	--SELECT * FROM bda.Inquilino
	--DELETE FROM bda.Inquilino

	PRINT('Se ha importado el archivo de inquilinos y propietarios
	Filas insertadas en la tabla de propietarios = ' + CAST(@FilasInsertadasPropietario AS VARCHAR) + '
	Filas duplicadas en la tabla de propietarios = ' + CAST(@FilasDuplicadasPropietario AS VARCHAR) + '
	Filas insertadas en la tabla de inquilinos = ' + CAST(@FilasInsertadasInquilino AS VARCHAR) + '
	Filas duplicadas en la tabla de inquilinos = ' + CAST(@FilasDuplicadasInquilino AS VARCHAR));
END
GO