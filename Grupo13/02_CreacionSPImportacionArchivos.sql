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
        nombre_consorcio NVARCHAR(100),
        nroUnidadFuncional NVARCHAR(20),
        piso NVARCHAR(20),
        departamento NVARCHAR(20),
        coeficiente NVARCHAR(20),
        m2_unidad_funcional NVARCHAR(20),
        baulera NVARCHAR(10),
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
	    m2_unidad_funcional,
	    porcentaje,
	    baulera,
		m2_baulera,
		cochera,
		m2_cochera
	)
	SELECT 
	    c.id_consorcio,
	    TRY_CAST(REPLACE(REPLACE(t1.nroUnidadFuncional, ' ', ''), CHAR(160), '') AS INT),
	    t1.piso,
	    t1.departamento,
		t1.m2_unidad_funcional,
	    CAST(REPLACE(t1.coeficiente, ',', '.') AS DECIMAL(4,1)),
	    CASE WHEN UPPER(t1.baulera) = 'SI' THEN 1 ELSE 0 END,
		t1.m2_baulera,
	    CASE WHEN UPPER(t1.cochera) = 'SI' THEN 1 ELSE 0 END,
		t1.m2_cochera
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

------------------------------ SP para cargas las bauleras y cocheras correspondientes a cada unidad funcional -----------------------------

CREATE OR ALTER PROCEDURE bda.spCargarBaulerasCocheras
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @FilasInsertadasBaulera INT,
			@FilasDuplicadasBaulera INT,
			@FilasInsertadasCochera INT,
			@FilasDuplicadasCochera INT

	INSERT INTO bda.Baulera(
		id_uf,
		importe
	)
	SELECT id_unidad,(m2_baulera*10000) AS importe FROM bda.Unidad_Funcional uf
	WHERE (m2_baulera*10000) > 0
	AND NOT EXISTS(SELECT id_uf FROM bda.Baulera b WHERE uf.id_unidad = b.id_uf)

    SET @FilasInsertadasBaulera = @@ROWCOUNT;
    SET @FilasDuplicadasBaulera = (SELECT COUNT(*) FROM bda.Baulera) - @FilasInsertadasBaulera

	INSERT INTO bda.Cochera(
		id_uf,
		importe
	)
	SELECT id_unidad,(m2_cochera*10000) AS importe FROM bda.Unidad_Funcional uf
	WHERE (m2_cochera*10000) > 0 
	AND NOT EXISTS(SELECT id_uf FROM bda.Cochera c WHERE uf.id_unidad = c.id_uf)

	SET @FilasInsertadasCochera = @@ROWCOUNT;
    SET @FilasDuplicadasCochera = (SELECT COUNT(*) FROM bda.Cochera) - @FilasInsertadasCochera

    PRINT('Se han cargado las bauleras y cocheras correspondientes a cada unidad funcional
	Filas insertadas en la tabla de bauleras = ' + CAST(@FilasInsertadasBaulera AS VARCHAR) + '
	Filas duplicadas en la tabla de bauleras = ' + CAST(@FilasDuplicadasBaulera AS VARCHAR) + '
	Filas insertadas en la tabla de cocheras = ' + CAST(@FilasInsertadasCochera AS VARCHAR) + '
	Filas duplicadas en la tabla de cocheras = ' + CAST(@FilasDuplicadasCochera AS VARCHAR));
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

	DECLARE @SQL NVARCHAR(MAX) = '';

	SET @SQL = '
	BULK INSERT #tmpPagos
	FROM ''' + @RutaArchivo + '''
	WITH(
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''ACP'',
		FIRSTROW = 2
	)';

	EXEC sp_executesql @SQL;
	--USAMOS SQL DINAMICO PARA INSERTAR LA VARIABLE DE LA RUTA DEL ARCHIVO EN EL BULK INSERT

	DELETE FROM #tmpPagos WHERE id_pago IN (SELECT MAX(id_pago) FROM #tmpPagos);
	--HAY UN REGISTRO EN EL .CSV QUE MARCA EL FIN DE ARCHIVO

	WITH PropietariosInquilinosUF(ID,CVU_CBU,ID_UF) AS(
		SELECT * FROM bda.Propietario_en_UF
		UNION
		SELECT * FROM bda.Inquilino_en_UF
	)
	INSERT INTO bda.Pagos (id_pago,fecha_pago,cta_origen,importe,asociado,id_unidad)
	SELECT 
		id_pago,
		CONVERT(date, fecha_pago, 103),
		cta_origen,
		REPLACE(REPLACE(importe, '$', ''), '.', ''),
		CASE
			WHEN cta_origen IS NULL THEN 0 ELSE 1
		END AS asociado,
		ID_UF FROM #tmpPagos t1
	INNER JOIN PropietariosInquilinosUF piuf ON t1.cta_origen COLLATE Latin1_General_CI_AI = piuf.CVU_CBU COLLATE Latin1_General_CI_AI
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

	INSERT INTO bda.Propietario_en_UF(CVU_CBU_Propietario,ID_UF)
	SELECT CVU_CBU,id_unidad FROM #tmpPropietarioInquilinoUF t1
	INNER JOIN bda.Consorcio c ON t1.Nombre_Consorcio COLLATE Latin1_General_CI_AI = c.nombre COLLATE Latin1_General_CI_AI
	INNER JOIN bda.Unidad_Funcional uf ON c.id_consorcio = uf.id_consorcio AND t1.NroUF = uf.numero_unidad
	WHERE NOT EXISTS(SELECT CVU_CBU_Propietario FROM bda.Propietario_en_UF t2 WHERE t1.CVU_CBU COLLATE Latin1_General_CI_AI = t2.CVU_CBU_Propietario COLLATE Latin1_General_CI_AI)
    AND EXISTS(SELECT CVU_CBU FROM bda.Propietario WHERE CVU_CBU COLLATE Latin1_General_CI_AI = t1.CVU_CBU COLLATE Latin1_General_CI_AI)

	SET @FilasInsertadasPropietarioUF = @@ROWCOUNT
	SET @FilasDuplicadasPropietarioUF = (SELECT COUNT(*) FROM bda.Propietario_en_UF) - @FilasInsertadasPropietarioUF

	INSERT INTO bda.Inquilino_en_UF(CVU_CBU_Inquilino,ID_UF)
	SELECT CVU_CBU,id_unidad FROM #tmpPropietarioInquilinoUF t1
	INNER JOIN bda.Consorcio c ON t1.Nombre_Consorcio COLLATE Latin1_General_CI_AI = c.nombre COLLATE Latin1_General_CI_AI
	INNER JOIN bda.Unidad_Funcional uf ON c.id_consorcio = uf.id_consorcio AND t1.NroUF = uf.numero_unidad
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

------------------------------ Funcion para normalizar numeros -----------------------------------

CREATE OR ALTER FUNCTION bda.fn_NormalizarImporte (@valor NVARCHAR(100))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @resultado DECIMAL(18,2);
    DECLARE @texto NVARCHAR(100);
    IF @valor IS NULL OR LTRIM(RTRIM(@valor)) = '' RETURN 0;
    -- limpiar símbolos no numericos
    SET @texto = REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@valor)), ' ', ''), '$', ''), '"', ''), CHAR(160), '');

    DECLARE @len INT = LEN(@texto);
    DECLARE @i INT = @len;
    DECLARE @decimalPos INT = 0;
    DECLARE @ch NCHAR(1);

    -- recorrer de derecha a izquierda para encontrar el ultimo separador
    WHILE @i > 0
    BEGIN
        SET @ch = SUBSTRING(@texto, @i, 1);
        IF @ch = ',' OR @ch = '.'
        BEGIN
            SET @decimalPos = @i;
            BREAK;
        END;
        SET @i -= 1;
    END;

    -- eliminar todos los separadores
    SET @texto = REPLACE(REPLACE(@texto, '.', ''), ',', '');

    -- si habia un separador, insertarlo antes de los ultimos dos digitos
    IF @decimalPos > 0 AND LEN(@texto) > 2
        SET @texto = STUFF(@texto, LEN(@texto) - 1, 0, '.');

    SET @resultado = TRY_CAST(@texto AS DECIMAL(18,2));
    RETURN ISNULL(@resultado, 0);
END;
GO


------------------------------ SP para importar el detalle de los gastos por mes -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarDetalleYGastos
	@RutaArchivo NVARCHAR(256),
	@Anio SMALLINT = 2025 --ya que los datos no vienen con año
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @JSON NVARCHAR(MAX),
			@SQL NVARCHAR(MAX),
			@FilasInsertadas INT,
			@FilasDuplicadas INT;
	
	IF OBJECT_ID('tempdb..#tmpJson') IS NOT NULL DROP TABLE #tmpJson;
	CREATE TABLE #tmpJson (BulkColumn NVARCHAR(MAX)); --creo tabla para meter el json como texto plano
	SET @SQL = '
	INSERT INTO #tmpJson (BulkColumn)
	SELECT BulkColumn
	FROM OPENROWSET(
	    BULK ''' + @RutaArchivo + ''',
	    SINGLE_CLOB
	) AS j;';
	
	EXEC sp_executesql @SQL;

	-- Pasar el texto del archivo a la variable
	SELECT TOP(1) @JSON = BulkColumn FROM #tmpJson;

	IF OBJECT_ID('tempdb..#tmpCarga') IS NOT NULL DROP TABLE #tmpCarga;
	CREATE TABLE #tmpCarga(
		nombreConsorcio NVARCHAR(255),
        mes NVARCHAR(60),
        bancarios NVARCHAR(60),
        limpieza NVARCHAR(60),
        administracion NVARCHAR(60),
        seguros NVARCHAR(60),
        gastosGenerales NVARCHAR(60),
        sAgua NVARCHAR(60),
        sLuz NVARCHAR(60),
        sInternet NVARCHAR(60)
	)--cargamos en la tabla temporal
		INSERT INTO #tmpCarga(nombreConsorcio,mes,bancarios,limpieza,administracion,seguros,gastosGenerales,sAgua,sLuz,sInternet)
	SELECT 
		nombreConsorcio,
		mes,
		bda.fn_NormalizarImporte(bancarios),
		bda.fn_NormalizarImporte(limpieza),
		bda.fn_NormalizarImporte(administracion),
		bda.fn_NormalizarImporte(seguros),
		bda.fn_NormalizarImporte(gastosGenerales),
		bda.fn_NormalizarImporte(sAgua),
		bda.fn_NormalizarImporte(sLuz),
		bda.fn_NormalizarImporte(sInternet)
	FROM OPENJSON(@JSON)
	WITH (
		nombreConsorcio NVARCHAR(255) '$."Nombre del consorcio"',
		mes NVARCHAR(60) '$.Mes',
		bancarios NVARCHAR(60) '$.BANCARIOS',
		limpieza NVARCHAR(60) '$.LIMPIEZA',
		administracion NVARCHAR(60) '$.ADMINISTRACION',
		seguros NVARCHAR(60) '$.SEGUROS',
		gastosGenerales NVARCHAR(60) '$."GASTOS GENERALES"',
		sAgua NVARCHAR(60) '$."SERVICIOS PUBLICOS-Agua"',
		sLuz NVARCHAR(60) '$."SERVICIOS PUBLICOS-Luz"',
		sInternet NVARCHAR(60) '$."SERVICIOS PUBLICOS-Internet"'
	);
	INSERT INTO bda.Gastos_Ordinarios (id_consorcio, mes, id_proveedor, tipo_gasto, nro_factura, importe)
	SELECT 
		c.id_consorcio,
		CASE 
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'enero%' THEN 1
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'febrero%' THEN 2
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'marzo%' THEN 3
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'abril%' THEN 4
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'mayo%' THEN 5
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'junio%' THEN 6
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'julio%' THEN 7
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'agosto%' THEN 8
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'septiembre%' THEN 9
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'octubre%' THEN 10
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'noviembre%' THEN 11
			WHEN LTRIM(RTRIM(LOWER(t.mes))) LIKE 'diciembre%' THEN 12
			ELSE NULL
		END AS mes,
		NULL AS id_proveedor,
		v.tipo_gasto,
		NULL AS nro_factura,
		v.importe
	FROM #tmpCarga t
	JOIN bda.Consorcio c 
		ON c.nombre COLLATE Latin1_General_CI_AI = t.nombreConsorcio COLLATE Latin1_General_CI_AI
	CROSS APPLY (VALUES
		(N'BANCARIOS', bda.fn_NormalizarImporte(t.bancarios)),
		(N'LIMPIEZA', bda.fn_NormalizarImporte(t.limpieza)),
		(N'ADMINISTRACION', bda.fn_NormalizarImporte(t.administracion)),
		(N'SEGUROS', bda.fn_NormalizarImporte(t.seguros)),
		(N'GASTOS GENERALES', bda.fn_NormalizarImporte(t.gastosGenerales)),
		(N'SERVICIOS PUBLICOS-Agua', bda.fn_NormalizarImporte(t.sAgua)),
		(N'SERVICIOS PUBLICOS-Luz', bda.fn_NormalizarImporte(t.sLuz)),
		(N'SERVICIOS PUBLICOS-Internet', bda.fn_NormalizarImporte(t.sInternet))
	) AS v(tipo_gasto, importe)
	WHERE v.importe IS NOT NULL AND v.importe > 0;

	SET @FilasInsertadas = @@ROWCOUNT
	SET @FilasDuplicadas = (SELECT COUNT(*) FROM #tmpCarga) - @FilasInsertadas

	PRINT('Se ha importado el archivo de gastos ordinarios de cada consorcio
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END;
GO

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

    SET @FilasInsertadas = @@ROWCOUNT
	SET @FilasDuplicadas = (SELECT COUNT(*) FROM #tmpProveedores) - @FilasInsertadas

	PRINT('Se ha importado el archivo de datos los proveedores
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END;
GO

------------------------------ SP para generar las expensas -----------------------------

CREATE OR ALTER PROCEDURE bda.spGenerarExpensas
	@Mes TINYINT,
	@FechaEmision DATE,
	@FechaVencimiento1 DATE,
	@FechaVencimiento2 DATE
AS
BEGIN
	INSERT INTO bda.Expensa
	SELECT DISTINCT(c.id_consorcio),@Mes,@FechaEmision,@FechaVencimiento1,@FechaVencimiento2 FROM bda.Consorcio c
	INNER JOIN bda.Gastos_Ordinarios gao ON c.id_consorcio = gao.id_consorcio;

	WITH Gastos_Ordinarios(id,importe) AS(
		SELECT id_consorcio, sum(importe)
		FROM bda.Gastos_Ordinarios 
		WHERE mes = 4
		GROUP BY id_consorcio
	)
	INSERT INTO bda.Detalle_Expensa(id_expensa,id_uf,valor_ordinarias,valor_extraordinarias,valor_baulera,valor_cochera)
	SELECT e.id_expensa,uf.id_unidad,(gao.importe*(uf.porcentaje/100)),ISNULL((gae.importe*(uf.porcentaje/100)),0),ISNULL(b.importe,0),ISNULL(c.importe,0)
	FROM bda.Expensa e
	INNER JOIN bda.Unidad_Funcional uf ON e.id_consorcio = uf.id_consorcio
	INNER JOIN Gastos_Ordinarios gao ON uf.id_consorcio = gao.id
	FULL JOIN bda.Baulera b ON uf.id_unidad = b.id_uf
	FULL JOIN bda.Cochera c ON uf.id_unidad = c.id_uf
	FULL JOIN bda.Gastos_Extraordinarios gae ON gae.id_consorcio = uf.id_consorcio
END
GO

------------------------------ VIEW que muestra la expensa generada por consorcio -----------------------------

CREATE OR ALTER VIEW bda.vExpensaGenerada AS
	WITH Propietarios_Inquilinos_UF AS(
		SELECT * FROM bda.Propietario_en_UF
		UNION
		SELECT * FROM bda.Inquilino_en_UF
	),
	Propietarios_Inquilinos AS(
		SELECT * FROM bda.Propietario
		UNION
		SELECT * FROM bda.Inquilino
	)
	SELECT 
		uf.id_unidad AS Uf,
		CAST(uf.porcentaje AS DECIMAL(3,2)) AS '%', 
		uf.piso + '-' + uf.depto AS 'Piso-Depto.',
		p_i.Nombre + ' ' + p_i.Apellido AS 'Propietario/Inquilino',
		de.valor_ordinarias AS Gastos_Ordinarios,
		de.valor_baulera AS Baulera,
		de.valor_cochera AS Cochera,
		de.valor_extraordinarias AS Gastos_Extraordinarios,
		de.valor_ordinarias + de.valor_baulera + de.valor_cochera + de.valor_extraordinarias AS Total_A_Pagar
	FROM Propietarios_Inquilinos_UF piuf
	INNER JOIN Propietarios_Inquilinos p_i ON piuf.CVU_CBU_Propietario = p_i.CVU_CBU
	INNER JOIN bda.Unidad_Funcional uf ON piuf.ID_UF = uf.id_unidad
	INNER JOIN bda.Detalle_Expensa de ON uf.id_unidad = de.id_uf