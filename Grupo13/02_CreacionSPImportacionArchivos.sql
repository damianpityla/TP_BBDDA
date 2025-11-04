/* =========================================================
	02_CreacionSPImportacionArchivos.sql - Com2900G13
	Proyecto: Altos de Saint Just
    Materia: Bases de datos aplicada
    Grupo: 13

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

------------------------------ SP para importar unidades funcionales -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarUnidadesFuncionales
    @RutaArchivo NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FilasInsertadas INT,
            @FilasDuplicadas INT;

    -- TABLA TEMPORAL PARA CARGAR EL ARCHIVO
    CREATE TABLE #tmpUFxCONS( 
        Nombre_consorcio NVARCHAR(100),
        nroUnidadFuncional NVARCHAR(20),
        Piso NVARCHAR(20),
        departamento NVARCHAR(20),
        coeficiente NVARCHAR(20),
        m2_unidad_funcional NVARCHAR(20),
        bauleras NVARCHAR(10),
        cochera NVARCHAR(10),
        m2_baulera NVARCHAR(20),
        m2_cochera NVARCHAR(20)
    );

    DECLARE @SQL NVARCHAR(MAX) = '';

    SET @SQL = '
    BULK INSERT #tmpUFxCONS
    FROM ''' + @RutaArchivo + '''
    WITH(
        FIELDTERMINATOR = ''\t'',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001'',
        FIRSTROW = 2
    )';

    EXEC sp_executesql @SQL;

    -- Eliminamos filas vacías
    DELETE FROM #tmpUFxCONS WHERE nroUnidadFuncional IS NULL;

    -- Insertamos en Unidad_Funcional validando que el consorcio exista
	INSERT INTO bda.Unidad_Funcional(
	    id_consorcio,
	    numero_unidad,
	    piso,
	    depto,
	    porcentaje,
	    superficie,
	    tiene_baulera,
	    tiene_cochera
	)
	SELECT 
	    c.id_consorcio,
	    TRY_CAST(REPLACE(REPLACE(t1.nroUnidadFuncional, ' ', ''), CHAR(160), '') AS INT),
	    t1.Piso,
	    t1.departamento,
	    CAST(REPLACE(t1.coeficiente, ',', '.') AS DECIMAL(6,4)),
	    CASE 
	        WHEN t1.m2_unidad_funcional LIKE '%[0-9]%' 
	        THEN CAST(REPLACE(REPLACE(t1.m2_unidad_funcional, ' ', ''), CHAR(160), '') AS DECIMAL(10,2))
	        ELSE 0 
	    END,
	    CASE WHEN UPPER(t1.bauleras) = 'SI' THEN 1 ELSE 0 END,
	    CASE WHEN UPPER(t1.cochera) = 'SI' THEN 1 ELSE 0 END
	FROM #tmpUFxCONS t1
	JOIN bda.Consorcio c 
	  ON c.nombre COLLATE Latin1_General_CI_AI = t1.Nombre_consorcio COLLATE Latin1_General_CI_AI
	WHERE NOT EXISTS (
	    SELECT 1 
	    FROM bda.Unidad_Funcional t2
	    WHERE t2.id_consorcio = c.id_consorcio
	      AND t2.numero_unidad = TRY_CAST(REPLACE(REPLACE(t1.nroUnidadFuncional, ' ', ''), CHAR(160), '') AS INT)
	);

    SET @FilasInsertadas = @@ROWCOUNT;

    SET @FilasDuplicadas = (
        SELECT COUNT(*) 
        FROM #tmpUFxCONS t1
        INNER JOIN bda.Consorcio c 
		ON c.nombre COLLATE Latin1_General_CI_AI = t1.Nombre_consorcio COLLATE Latin1_General_CI_AI) - @FilasInsertadas;

    PRINT('Se ha importado el archivo de unidades funcionales por consorcio
    Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
    Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END;
GO

------------------------------ SP para importar los pagos correspondientes a cada unidad funcional -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarPagosConsorcios
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

	PRINT('Se ha importado el archivo de pagos por consorcio
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END
GO

------------------------------ SP para importar los datos de los inquilinos y los propietarios -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarPropietariosInquilinos
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

	PRINT('Se ha importado el archivo de inquilinos y propietarios
	Filas insertadas en la tabla de propietarios = ' + CAST(@FilasInsertadasPropietario AS VARCHAR) + '
	Filas duplicadas en la tabla de propietarios = ' + CAST(@FilasDuplicadasPropietario AS VARCHAR) + '
	Filas insertadas en la tabla de inquilinos = ' + CAST(@FilasInsertadasInquilino AS VARCHAR) + '
	Filas duplicadas en la tabla de inquilinos = ' + CAST(@FilasDuplicadasInquilino AS VARCHAR));
END
GO

------------------------------ SP para importar los datos de los inquilinos y los propietarios en cada unidad funcional -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarPropietariosInquilinosUF
	@RutaArchivo NVARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @FilasInsertadasPropietarioUF INT,
			@FilasDuplicadasPropietarioUF INT,
			@FilasInsertadasInquilinoUF INT,
			@FilasDuplicadasInquilinoUF INT

	CREATE TABLE #tmpPropietarioInquilinoUF( 
		CVU_CBU VARCHAR(22),
        Nombre_Consorcio VARCHAR(20),
        NroUF TINYINT,
        Piso VARCHAR(2),
        Departamento CHAR(1)
	)

	DECLARE @SQL NVARCHAR(MAX) = ''

	SET @SQL = '
	BULK INSERT #tmpPropietarioInquilinoUF
	FROM''' + @RutaArchivo + '''
	WITH(
		FIELDTERMINATOR = ''|'',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''ACP'',
		FIRSTROW = 2
	)'

	EXEC sp_executesql @SQL;

	DELETE FROM #tmpPropietarioInquilinoUF WHERE CVU_CBU IS NULL

	INSERT INTO bda.Propietario_en_UF(CVU_CBU_Propietario,Nombre_Consorcio,NroUF,Piso,Departamento)
	SELECT CVU_CBU,Nombre_Consorcio,NroUF,Piso,Departamento FROM #tmpPropietarioInquilinoUF t1
	WHERE NOT EXISTS(SELECT CVU_CBU_Propietario FROM bda.Propietario_en_UF t2 WHERE t1.CVU_CBU COLLATE Latin1_General_CI_AI = t2.CVU_CBU_Propietario COLLATE Latin1_General_CI_AI)
    AND EXISTS(SELECT CVU_CBU FROM bda.Propietario WHERE CVU_CBU COLLATE Latin1_General_CI_AI = t1.CVU_CBU COLLATE Latin1_General_CI_AI)

	SET @FilasInsertadasPropietarioUF = @@ROWCOUNT
	SET @FilasDuplicadasPropietarioUF = (SELECT COUNT(*) FROM bda.Propietario_en_UF) - @FilasInsertadasPropietarioUF

	INSERT INTO bda.Inquilino_en_UF(CVU_CBU_Inquilino,Nombre_Consorcio,NroUF,Piso,Departamento)
	SELECT CVU_CBU,Nombre_Consorcio,NroUF,Piso,Departamento FROM #tmpPropietarioInquilinoUF t1
	WHERE NOT EXISTS(SELECT CVU_CBU_Inquilino FROM bda.Inquilino_en_UF t2 WHERE t1.CVU_CBU COLLATE Latin1_General_CI_AI = t2.CVU_CBU_Inquilino COLLATE Latin1_General_CI_AI)
	AND EXISTS(SELECT CVU_CBU FROM bda.Inquilino WHERE CVU_CBU COLLATE Latin1_General_CI_AI = t1.CVU_CBU COLLATE Latin1_General_CI_AI)

	SET @FilasInsertadasInquilinoUF = @@ROWCOUNT
	SET @FilasDuplicadasInquilinoUF = (SELECT COUNT(*) FROM bda.Inquilino) - @FilasInsertadasInquilinoUF

	PRINT('Se ha importado el archivo de inquilinos y propietarios
	Filas insertadas en la tabla de propietarios por unidad funcional = ' + CAST(@FilasInsertadasPropietarioUF AS VARCHAR) + '
	Filas duplicadas en la tabla de propietarios por unidad funcional = ' + CAST(@FilasDuplicadasPropietarioUF AS VARCHAR) + '
	Filas insertadas en la tabla de inquilinos por unidad funcional = ' + CAST(@FilasInsertadasInquilinoUF AS VARCHAR) + '
	Filas duplicadas en la tabla de inquilinos por unidad funcional = ' + CAST(@FilasDuplicadasInquilinoUF AS VARCHAR));
END
GO

------------------------------ SP para importar el detalle de los gastos por mes -----------------------------

-- FALTA TERMINAR

------------------------------ SP para importar los datos de los consorcios -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarDatosConsorcios
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FilasInsertadas INT,
			@FilasDuplicadas INT;

    --TABLA TEMPORAL
    CREATE TABLE #tmpDatosConsorcios(
        Consorcio VARCHAR(15),
        Nombre_Consorcio VARCHAR(20),
        Domicilio VARCHAR(20),
        Unidades_Funcionales INT,
        m2_Totales INT
    );

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL ='
    INSERT INTO #tmpDatosConsorcios
    SELECT
        [Consorcio],
        [Nombre del consorcio],
        [Domicilio],
        [Cant unidades funcionales],
        [m2 totales]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.16.0'',
        ''Excel 12.0 Xml; HDR=YES;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [' + @NombreHoja + ']'');';

    EXEC sp_executesql @SQL;

    INSERT INTO bda.Consorcio(nombre, direccion, cant_unidades_func, m2_totales)
    SELECT Nombre_Consorcio, Domicilio, Unidades_Funcionales, m2_Totales FROM #TmpDatosConsorcios t2
    WHERE NOT EXISTS (SELECT nombre FROM bda.Consorcio t1 WHERE t1.nombre COLLATE Latin1_General_CI_AI = t2.Nombre_Consorcio COLLATE Latin1_General_CI_AI)

    SET @FilasInsertadas = @@ROWCOUNT
	SET @FilasDuplicadas = (SELECT COUNT(*) FROM #tmpDatosConsorcios) - @FilasInsertadas

	PRINT('Se ha importado el archivo de datos de los consorcios
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END;
GO

------------------------------ SP para importar los datos de los proveedores -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarDatosProveedores
    @RutaArchivo NVARCHAR(256),
    @NombreHoja NVARCHAR(256),
    @RangoCeldas NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FilasInsertadas INT,
			@FilasDuplicadas INT;

    CREATE TABLE #tmpProveedores(
        servicio VARCHAR(30) NOT NULL,
	    descripcion VARCHAR(100) NOT NULL,
	    cuenta VARCHAR(30),
	    nombre_consorcio VARCHAR(30)
    );

    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        INSERT INTO #tmpProveedores(servicio,descripcion,cuenta,nombre_consorcio)
        SELECT *
        FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.16.0'',
        ''Excel 12.0 Xml; HDR=YES;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [' + @NombreHoja + @RangoCeldas + ']'');';

    EXEC sp_executesql @SQL;

    INSERT INTO bda.Proveedor(servicio,descripcion,cuenta,ID_Consorcio)
        SELECT t.servicio,t.descripcion,t.cuenta,c.id_consorcio FROM #tmpProveedores t
        INNER JOIN bda.Consorcio c ON c.nombre COLLATE Latin1_General_CI_AI = t.nombre_consorcio COLLATE Latin1_General_CI_AI

    SET @FilasInsertadas = @@ROWCOUNT
	SET @FilasDuplicadas = (SELECT COUNT(*) FROM #tmpProveedores) - @FilasInsertadas

	PRINT('Se ha importado el archivo de datos los proveedores
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END;
GO

/*
SELECT 
    CASE 
        WHEN servicio LIKE 'Serv. Limpieza' 
        THEN cuenta
        ELSE descripcion
    END AS Nombre,
    CASE
        WHEN Nombre_Proveedor LIKE 'Serv. Limpieza'
        THEN Null
        ELSE  LTRIM(REPLACE(NroCuenta, 'cuenta', '')) 
    END AS Nro_Cuenta
    FROM #TmpProveedores t
    WHERE NOT EXISTS (
        SELECT 1
        FROM bda.Proveedor p
        WHERE p.nombre COLLATE Latin1_General_CI_AI = t.Nombre_Proveedor COLLATE Latin1_General_CI_AI
    );
*/