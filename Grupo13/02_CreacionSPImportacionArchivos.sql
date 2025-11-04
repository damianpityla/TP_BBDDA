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
        id_unidad,
        id_consorcio,
        piso,
        depto,
        porcentaje,
        superficie,
        tiene_baulera,
        tiene_cochera
    )
    SELECT 
        CASE 
            WHEN t1.nroUnidadFuncional LIKE '%[0-9]%' 
            THEN CAST(REPLACE(REPLACE(t1.nroUnidadFuncional, ' ', ''), CHAR(160), '') AS INT)
            ELSE NULL 
        END AS id_unidad,
        c.id_consorcio,  -- Se obtiene dinámicamente
        t1.Piso,
        t1.departamento,
        CAST(REPLACE(t1.coeficiente, ',', '.') AS DECIMAL(6,4)),
        CASE 
            WHEN t1.m2_unidad_funcional LIKE '%[0-9]%' 
            THEN CAST(REPLACE(REPLACE(t1.m2_unidad_funcional, ' ', ''), CHAR(160), '') AS DECIMAL(10,2))
            ELSE 0 
        END AS superficie,
        CASE WHEN UPPER(t1.bauleras) = 'SI' THEN 1 ELSE 0 END AS tiene_baulera,
        CASE WHEN UPPER(t1.cochera) = 'SI' THEN 1 ELSE 0 END AS tiene_cochera
    FROM #tmpUFxCONS t1
    INNER JOIN bda.Consorcio c ON c.nombre COLLATE Latin1_General_CI_AI = t1.Nombre_consorcio COLLATE Latin1_General_CI_AI
    WHERE NOT EXISTS (
        SELECT 1 
        FROM bda.Unidad_Funcional t2 
        WHERE t2.id_unidad = 
            TRY_CAST(REPLACE(REPLACE(t1.nroUnidadFuncional, ' ', ''), CHAR(160), '') AS INT)
          AND t2.id_consorcio = c.id_consorcio
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

------------------------------ Funcion para normalizar el importe -----------------------------

CREATE OR ALTER FUNCTION bda.fn_NormalizarImporte (@valor NVARCHAR(100))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @resultado DECIMAL(18,2);
    DECLARE @texto NVARCHAR(100);
    --Si viene NULL devolver 0
    IF @valor IS NULL OR LTRIM(RTRIM(@valor)) = ''
        RETURN 0;
    -- Quitar espacios, signo $, etc.
    SET @texto = REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@valor)), ' ', ''), '$', ''), '"', ''), CHAR(160), '');

    -- Reemplazar separadores de miles y decimales
    -- Detectar cuál es el separador decimal
    IF (CHARINDEX(',', @texto) > 0 AND CHARINDEX('.', @texto) > 0)
    BEGIN
        -- Si hay ambos, asumir que el último separador es el decimal
        IF CHARINDEX('.', REVERSE(@texto)) < CHARINDEX(',', REVERSE(@texto))
            SET @texto = REPLACE(REPLACE(@texto, '.', ''), ',', '.');
        ELSE
            SET @texto = REPLACE(REPLACE(@texto, ',', ''), '.', '.');
    END
    ELSE IF CHARINDEX(',', @texto) > 0
        SET @texto = REPLACE(@texto, ',', '.');
    ELSE
        SET @texto = REPLACE(@texto, '.', '.');  -- ya correcto

    -- Convertir a número (si falla, devuelve 0)
    SET @resultado = TRY_CAST(@texto AS DECIMAL(18,2));

    RETURN ISNULL(@resultado, 0);
END;
GO

------------------------------ SP para importar el detalle de los gastos por mes -----------------------------

CREATE OR ALTER PROCEDURE bda.spImportarDetalleYGastos
	@RutaArchivo NVARCHAR(256),
	@Anio SMALLINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @JSON NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX) = '';

	--Crear tabla temporal para leer el JSON
	IF OBJECT_ID('tempdb..#tmpJson') IS NOT NULL DROP TABLE #tmpJson;
	CREATE TABLE #tmpJson (BulkColumn NVARCHAR(MAX));

	--SQL dinámico con la ruta
	SET @SQL = '
	INSERT INTO #tmpJson (BulkColumn)
	SELECT BulkColumn
	FROM OPENROWSET(
		BULK ''' + @RutaArchivo + ''',
		SINGLE_CLOB
	) AS j;';

	EXEC sp_executesql @SQL;

	-- Pasar el JSON a variable
	SELECT TOP(1) @JSON = BulkColumn FROM #tmpJson;

	IF @JSON IS NULL OR LEN(@JSON) = 0
	BEGIN
		PRINT 'El archivo JSON está vacío o la ruta es incorrecta.';
		RETURN;
	END;

    ;WITH DatosBrutos AS (
        SELECT 
            JSON_VALUE(value, '$."Nombre del consorcio"') AS Consorcio,
            LTRIM(RTRIM(LOWER(JSON_VALUE(value, '$.Mes')))) AS MesTxt,
            JSON_VALUE(value, '$.BANCARIOS') AS sBancarios,
            JSON_VALUE(value, '$.LIMPIEZA') AS sLimpieza,
            JSON_VALUE(value, '$.ADMINISTRACION') AS sAdministracion,
            JSON_VALUE(value, '$.SEGUROS') AS sSeguros,
            JSON_VALUE(value, '$."GASTOS GENERALES"') AS sGastosGrales,
            JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Agua"') AS sAgua,
            JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Luz"') AS sLuz
        FROM OPENJSON(@JSON)
    ),
    DatosMes AS (
        SELECT
            Consorcio,
            CASE 
                WHEN MesTxt LIKE 'enero%' THEN 1
                WHEN MesTxt LIKE 'febrero%' THEN 2
                WHEN MesTxt LIKE 'marzo%' THEN 3
                WHEN MesTxt LIKE 'abril%' THEN 4
                WHEN MesTxt LIKE 'mayo%' THEN 5
                WHEN MesTxt LIKE 'junio%' THEN 6
                WHEN MesTxt LIKE 'julio%' THEN 7
                WHEN MesTxt LIKE 'agosto%' THEN 8
                WHEN MesTxt LIKE 'septiembre%' THEN 9
                WHEN MesTxt LIKE 'setiembre%' THEN 9
                WHEN MesTxt LIKE 'octubre%' THEN 10
                WHEN MesTxt LIKE 'noviembre%' THEN 11
                WHEN MesTxt LIKE 'diciembre%' THEN 12
                ELSE NULL
            END AS Mes,
            sBancarios, sLimpieza, sAdministracion, sSeguros, sGastosGrales, sAgua, sLuz
        FROM DatosBrutos
    ),
    Datos AS (
        SELECT 
            d.Consorcio,
            d.Mes,
            bda.fn_NormalizarImporte(d.sBancarios) AS Bancarios,
            bda.fn_NormalizarImporte(d.sLimpieza) AS Limpieza,
            bda.fn_NormalizarImporte(d.sAdministracion) AS Administracion,
            bda.fn_NormalizarImporte(d.sSeguros) AS Seguros,
            bda.fn_NormalizarImporte(d.sGastosGrales) AS GastosGenerales,
            bda.fn_NormalizarImporte(d.sAgua) AS Agua,
            bda.fn_NormalizarImporte(d.sLuz) AS Luz
        FROM DatosMes d
        WHERE d.Consorcio IS NOT NULL AND d.Mes BETWEEN 1 AND 12
    )
    INSERT INTO bda.Expensa (id_consorcio, mes, anio, fecha_emision, vencimiento1, vencimiento2)
    SELECT c.id_consorcio, d.Mes, @Anio,
           DATEFROMPARTS(@Anio, d.Mes, 1),
           DATEFROMPARTS(@Anio, d.Mes, 10),
           DATEFROMPARTS(@Anio, d.Mes, 20)
    FROM Datos d
    JOIN bda.Consorcio c ON c.nombre = d.Consorcio
    WHERE NOT EXISTS (
        SELECT 1 FROM bda.Expensa e
        WHERE e.id_consorcio = c.id_consorcio AND e.mes = d.Mes AND e.anio = @Anio
    );

    ;WITH DatosBrutos AS (
        SELECT 
            JSON_VALUE(value, '$."Nombre del consorcio"') AS Consorcio,
            LTRIM(RTRIM(LOWER(JSON_VALUE(value, '$.Mes')))) AS MesTxt,
            JSON_VALUE(value, '$.BANCARIOS') AS sBancarios,
            JSON_VALUE(value, '$.LIMPIEZA') AS sLimpieza,
            JSON_VALUE(value, '$.ADMINISTRACION') AS sAdministracion,
            JSON_VALUE(value, '$.SEGUROS') AS sSeguros,
            JSON_VALUE(value, '$."GASTOS GENERALES"') AS sGastosGrales,
            JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Agua"') AS sAgua,
            JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Luz"') AS sLuz
        FROM OPENJSON(@JSON)
    ),
    DatosMes AS (
        SELECT
            Consorcio,
            CASE 
                WHEN MesTxt LIKE 'enero%' THEN 1
                WHEN MesTxt LIKE 'febrero%' THEN 2
                WHEN MesTxt LIKE 'marzo%' THEN 3
                WHEN MesTxt LIKE 'abril%' THEN 4
                WHEN MesTxt LIKE 'mayo%' THEN 5
                WHEN MesTxt LIKE 'junio%' THEN 6
                WHEN MesTxt LIKE 'julio%' THEN 7
                WHEN MesTxt LIKE 'agosto%' THEN 8
                WHEN MesTxt LIKE 'septiembre%' THEN 9
                WHEN MesTxt LIKE 'setiembre%' THEN 9
                WHEN MesTxt LIKE 'octubre%' THEN 10
                WHEN MesTxt LIKE 'noviembre%' THEN 11
                WHEN MesTxt LIKE 'diciembre%' THEN 12
                ELSE NULL
            END AS Mes,
            sBancarios, sLimpieza, sAdministracion, sSeguros, sGastosGrales, sAgua, sLuz
        FROM DatosBrutos
    ),
    Datos AS (
        SELECT 
            d.Consorcio,
            d.Mes,
            bda.fn_NormalizarImporte(d.sBancarios) AS Bancarios,
            bda.fn_NormalizarImporte(d.sLimpieza) AS Limpieza,
            bda.fn_NormalizarImporte(d.sAdministracion) AS Administracion,
            bda.fn_NormalizarImporte(d.sSeguros) AS Seguros,
            bda.fn_NormalizarImporte(d.sGastosGrales) AS GastosGenerales,
            bda.fn_NormalizarImporte(d.sAgua) AS Agua,
            bda.fn_NormalizarImporte(d.sLuz) AS Luz
        FROM DatosMes d
        WHERE d.Consorcio IS NOT NULL AND d.Mes BETWEEN 1 AND 12
    )
    INSERT INTO bda.Detalle_Expensa (id_expensa, id_uf, saldo_anterior, valor_ordinarias, valor_extraordinarias)
    SELECT e.id_expensa, uf.id_unidad, 0, 0, 0
    FROM Datos d
    JOIN bda.Consorcio c ON c.nombre = d.Consorcio
    JOIN bda.Expensa e ON e.id_consorcio = c.id_consorcio AND e.mes = d.Mes AND e.anio = @Anio
    JOIN bda.Unidad_Funcional uf ON uf.id_consorcio = c.id_consorcio
    WHERE NOT EXISTS (
        SELECT 1 FROM bda.Detalle_Expensa de
        WHERE de.id_expensa = e.id_expensa AND de.id_uf = uf.id_unidad
    );

    ;WITH DatosBrutos AS (
        SELECT 
            JSON_VALUE(value, '$."Nombre del consorcio"') AS Consorcio,
            LTRIM(RTRIM(LOWER(JSON_VALUE(value, '$.Mes')))) AS MesTxt,
            JSON_VALUE(value, '$.BANCARIOS') AS sBancarios,
            JSON_VALUE(value, '$.LIMPIEZA') AS sLimpieza,
            JSON_VALUE(value, '$.ADMINISTRACION') AS sAdministracion,
            JSON_VALUE(value, '$.SEGUROS') AS sSeguros,
            JSON_VALUE(value, '$."GASTOS GENERALES"') AS sGastosGrales,
            JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Agua"') AS sAgua,
            JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Luz"') AS sLuz
        FROM OPENJSON(@JSON)
    ),
    DatosMes AS (
        SELECT
            Consorcio,
            CASE 
                WHEN MesTxt LIKE 'enero%' THEN 1
                WHEN MesTxt LIKE 'febrero%' THEN 2
                WHEN MesTxt LIKE 'marzo%' THEN 3
                WHEN MesTxt LIKE 'abril%' THEN 4
                WHEN MesTxt LIKE 'mayo%' THEN 5
                WHEN MesTxt LIKE 'junio%' THEN 6
                WHEN MesTxt LIKE 'julio%' THEN 7
                WHEN MesTxt LIKE 'agosto%' THEN 8
                WHEN MesTxt LIKE 'septiembre%' THEN 9
                WHEN MesTxt LIKE 'setiembre%' THEN 9
                WHEN MesTxt LIKE 'octubre%' THEN 10
                WHEN MesTxt LIKE 'noviembre%' THEN 11
                WHEN MesTxt LIKE 'diciembre%' THEN 12
                ELSE NULL
            END AS Mes,
            sBancarios, sLimpieza, sAdministracion, sSeguros, sGastosGrales, sAgua, sLuz
        FROM DatosBrutos
    ),
    Datos AS (
        SELECT 
            d.Consorcio,
            d.Mes,
            bda.fn_NormalizarImporte(d.sBancarios) AS Bancarios,
            bda.fn_NormalizarImporte(d.sLimpieza) AS Limpieza,
            bda.fn_NormalizarImporte(d.sAdministracion) AS Administracion,
            bda.fn_NormalizarImporte(d.sSeguros) AS Seguros,
            bda.fn_NormalizarImporte(d.sGastosGrales) AS GastosGenerales,
            bda.fn_NormalizarImporte(d.sAgua) AS Agua,
            bda.fn_NormalizarImporte(d.sLuz) AS Luz
        FROM DatosMes d
        WHERE d.Consorcio IS NOT NULL AND d.Mes BETWEEN 1 AND 12
    ),
    Rubros AS (
        SELECT
            d.Consorcio, d.Mes, r.Rubro, r.Monto
        FROM Datos d
        CROSS APPLY (VALUES
            (N'BANCARIOS',               d.Bancarios),
            (N'LIMPIEZA',                d.Limpieza),
            (N'ADMINISTRACION',          d.Administracion),
            (N'SEGUROS',                 d.Seguros),
            (N'GASTOS GENERALES',        d.GastosGenerales),
            (N'SERVICIOS PUBLICOS-Agua', d.Agua),
            (N'SERVICIOS PUBLICOS-Luz',  d.Luz)
        ) AS r(Rubro, Monto)
        WHERE r.Monto IS NOT NULL AND r.Monto <> 0
    )
    INSERT INTO bda.Gastos_Ordinarios (id_detalle, id_proveedor, tipo_gasto, nro_factura, importe)
    SELECT 
        de.id_detalle,
        NULL,
        r.Rubro,
        NULL,
        ROUND(r.Monto * (uf.porcentaje / 100.0), 2)
    FROM Rubros r
    JOIN bda.Consorcio c ON c.nombre = r.Consorcio
    JOIN bda.Expensa e   ON e.id_consorcio = c.id_consorcio AND e.mes = r.Mes AND e.anio = @Anio
    JOIN bda.Unidad_Funcional uf ON uf.id_consorcio = c.id_consorcio
    JOIN bda.Detalle_Expensa de  ON de.id_expensa = e.id_expensa AND de.id_uf = uf.id_unidad;
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
    WHERE NOT EXISTS (SELECT nombre FROM bda.Consorcio t1 where t1.nombre COLLATE Latin1_General_CI_AI = t2.Nombre_Consorcio COLLATE Latin1_General_CI_AI)

    SET @FilasInsertadas = @@ROWCOUNT
	SET @FilasDuplicadas = (SELECT COUNT(*) FROM #tmpDatosConsorcios) - @FilasInsertadas

	PRINT('Se ha importado el archivo de datos de los consorcios
	Filas insertadas = ' + CAST(@FilasInsertadas AS VARCHAR) + '
	Filas duplicadas = ' + CAST(@FilasDuplicadas AS VARCHAR));
END;
GO

------------------------------ SP para importar los datos de los proveedores -----------------------------

/*

Parte de Joel

*/