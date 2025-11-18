/* =========================================================
	05_CreacionSPReportes.sql - Com2900G13
	Proyecto: Altos de Saint Just
	Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea los SP de los reportes

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

------------------------------ Reporte 1 -----------------------------
CREATE OR ALTER PROCEDURE bda.spReporteFlujoCajaSemanal
    @NombreConsorcio VARCHAR(80),
    @Mes TINYINT
AS
BEGIN
    SET NOCOUNT ON;


    ;WITH PagosMes AS (
        SELECT p.id_pago,p.fecha_pago, p.importe,DATEPART(WEEK, p.fecha_pago) AS semana
        FROM bda.Pagos p
        INNER JOIN bda.Unidad_Funcional uf 
            ON p.id_unidad = uf.id_unidad
        INNER JOIN bda.Consorcio c 
            ON uf.id_consorcio = c.id_consorcio
        WHERE c.nombre COLLATE Latin1_General_CI_AI = @NombreConsorcio COLLATE Latin1_General_CI_AI
          AND MONTH(p.fecha_pago) = @Mes
    ),


    Gastos AS (
        SELECT 
            COALESCE(SUM(gao.importe), 0) AS gasto_ordinario,
            COALESCE(SUM(gae.importe), 0) AS gasto_extraordinario,
            COALESCE(SUM(gao.importe), 0) +
            COALESCE(SUM(gae.importe), 0) AS gasto_total
        FROM bda.Gastos_Ordinarios gao
        INNER JOIN bda.Consorcio c
            ON gao.id_consorcio = c.id_consorcio
        LEFT JOIN bda.Gastos_Extraordinarios gae
            ON gae.id_consorcio = gao.id_consorcio
           AND gae.mes = gao.mes
        WHERE c.nombre COLLATE Latin1_General_CI_AI = @NombreConsorcio COLLATE Latin1_General_CI_AI
          AND gao.mes = @Mes - 1         -- mes anterior
    ),

    PagosRepartidos AS (
        SELECT p.id_pago,p.semana,p.fecha_pago,p.importe,
            CASE 
                WHEN g.gasto_total = 0 THEN p.importe
                ELSE p.importe * (g.gasto_ordinario * 1.0 / g.gasto_total)
            END AS pago_ordinario,
            CASE 
                WHEN g.gasto_total = 0 THEN 0
                ELSE p.importe * (g.gasto_extraordinario * 1.0 / g.gasto_total)
            END AS pago_extraordinario
        FROM PagosMes p
        CROSS JOIN Gastos g
    ),


    Semanas AS (
        SELECT semana,SUM(pago_ordinario) AS total_ordinario,SUM(pago_extraordinario) AS total_extraordinario,
            SUM(pago_ordinario + pago_extraordinario) AS total_semana
        FROM PagosRepartidos
        GROUP BY semana
    )

    SELECT
        @NombreConsorcio AS consorcio,
        @Mes AS mes,
        semana AS semana,
        total_ordinario AS recaudacion_ordinaria,
        total_extraordinario AS recaudacion_extraordinaria,
        total_semana     AS total_semana,
        AVG(total_semana) OVER () AS promedio_periodo,
        SUM(total_semana) OVER (
            ORDER BY semana
            ROWS UNBOUNDED PRECEDING
        ) AS acumulado_progresivo
    FROM Semanas
    ORDER BY semana;
END;
GO
------------------------------ Reporte 2 -----------------------------
CREATE OR ALTER PROCEDURE bda.sp_ReportePagosPorDeptoMensual
(
    @id_consorcio INT,
    @anio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ColumnasParaPivot NVARCHAR(MAX);
    DECLARE @ColumnasParaSelect NVARCHAR(MAX);
    DECLARE @SQLQuery NVARCHAR(MAX);

    SELECT 
        @ColumnasParaPivot = STUFF((
            SELECT
                ',' + QUOTENAME(CAST(id_unidad AS VARCHAR(10)))
            FROM bda.Unidad_Funcional
            WHERE id_consorcio = @id_consorcio
            ORDER BY 
                CASE 
                    WHEN piso = 'PB' THEN 0 
                    ELSE TRY_CAST(piso AS INT) 
                END,
                depto
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    SELECT 
        @ColumnasParaSelect = STUFF((
            SELECT
                ', ISNULL(' 
                + QUOTENAME(CAST(id_unidad AS VARCHAR(10))) 
                + ', 0) AS ' 
                + QUOTENAME(piso + depto)
            FROM bda.Unidad_Funcional
            WHERE id_consorcio = @id_consorcio
            ORDER BY 
                CASE 
                    WHEN piso = 'PB' THEN 0 
                    ELSE TRY_CAST(piso AS INT) 
                END,
                depto
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    IF @ColumnasParaPivot IS NULL
    BEGIN
        PRINT 'No se encontraron Unidades Funcionales para el Consorcio ID: ' + CAST(@id_consorcio AS VARCHAR);
        RETURN;
    END;

    SET @SQLQuery = N'

    -- CTE de meses
    WITH TodosLosMeses AS (
        SELECT 1 AS MesNumero, ''Enero'' AS MesNombre UNION ALL
        SELECT 2, ''Febrero'' UNION ALL
        SELECT 3, ''Marzo'' UNION ALL
        SELECT 4, ''Abril'' UNION ALL
        SELECT 5, ''Mayo'' UNION ALL
        SELECT 6, ''Junio'' UNION ALL
        SELECT 7, ''Julio'' UNION ALL
        SELECT 8, ''Agosto'' UNION ALL
        SELECT 9, ''Septiembre'' UNION ALL
        SELECT 10, ''Octubre'' UNION ALL
        SELECT 11, ''Noviembre'' UNION ALL
        SELECT 12, ''Diciembre''
    ),

    PagosDelAnio AS (
        SELECT
            MONTH(p.fecha_pago) AS mes_pago,
            u.id_unidad,
            p.importe
        FROM bda.Pagos p
        JOIN bda.Unidad_Funcional u ON p.id_unidad = u.id_unidad
        WHERE
            u.id_consorcio = @ParamConsorcio
            AND YEAR(p.fecha_pago) = @ParamAnio
    ),

    BaseData AS (
        SELECT
            M.MesNombre,
            M.MesNumero,
            P.id_unidad,
            P.importe
        FROM TodosLosMeses M
        LEFT JOIN PagosDelAnio P
            ON M.MesNumero = P.mes_pago
    )

    SELECT
        MesNombre,
        ' + @ColumnasParaSelect + N'
    FROM BaseData
    PIVOT (
        SUM(importe)
        FOR id_unidad IN (' + @ColumnasParaPivot + N')
    ) AS Cruzado
    ORDER BY MesNumero;
    ';


    EXEC sp_executesql
        @SQLQuery,
        N'@ParamConsorcio INT, @ParamAnio INT',
        @ParamConsorcio = @id_consorcio,
        @ParamAnio = @anio;

END;
GO


------------------------------ Reporte 3 -----------------------------
CREATE OR ALTER PROCEDURE bda.spReporteRecaudacionPorProcedencia
    @NombreConsorcio VARCHAR(80),
    @MesDesde        TINYINT,
    @MesHasta        TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH PagosPorMes AS (
        SELECT MONTH(p.fecha_pago) AS mes, SUM(p.importe)      AS TotalPagos
        FROM bda.Pagos p
        INNER JOIN bda.Unidad_Funcional uf
            ON p.id_unidad = uf.id_unidad
        INNER JOIN bda.Consorcio c
            ON uf.id_consorcio = c.id_consorcio
        WHERE c.nombre COLLATE Latin1_General_CI_AI = @NombreConsorcio COLLATE Latin1_General_CI_AI
          AND MONTH(p.fecha_pago) BETWEEN @MesDesde AND @MesHasta
        GROUP BY MONTH(p.fecha_pago)
    ),


    DeudaPorMes AS (
        SELECT
            e.mes,
            SUM(de.valor_ordinarias) AS DeudaOrdinarias,
            SUM(de.valor_extraordinarias) AS DeudaExtraordinarias,SUM(de.valor_baulera) AS DeudaBaulera,SUM(de.valor_cochera) AS DeudaCochera,
            SUM(de.valor_ordinarias + de.valor_extraordinarias+ de.valor_baulera+ de.valor_cochera) AS DeudaTotal
        FROM bda.Detalle_Expensa de
        INNER JOIN bda.Expensa e
            ON de.id_expensa = e.id_expensa
        INNER JOIN bda.Consorcio c
            ON e.id_consorcio = c.id_consorcio
        WHERE c.nombre COLLATE Latin1_General_CI_AI = @NombreConsorcio COLLATE Latin1_General_CI_AI
          AND e.mes BETWEEN @MesDesde AND @MesHasta
        GROUP BY e.mes
    ),


    Proporciones AS (
        SELECT mes,DeudaOrdinarias,DeudaExtraordinarias,DeudaBaulera,DeudaCochera,DeudaTotal,
            CASE WHEN DeudaTotal = 0 THEN 0 ELSE DeudaOrdinarias      / DeudaTotal END AS PropOrd,
            CASE WHEN DeudaTotal = 0 THEN 0 ELSE DeudaExtraordinarias / DeudaTotal END AS PropExt,
            CASE WHEN DeudaTotal = 0 THEN 0 ELSE DeudaBaulera         / DeudaTotal END AS PropBau,
            CASE WHEN DeudaTotal = 0 THEN 0 ELSE DeudaCochera         / DeudaTotal END AS PropCoch
        FROM DeudaPorMes
    )

    SELECT
        @NombreConsorcio AS Consorcio,
        pg.mes,
        -- si no hay proporciones, todo el pago va como Ordinario
        CAST(
            CASE WHEN pr.DeudaTotal IS NULL OR pr.DeudaTotal = 0
                 THEN pg.TotalPagos
                 ELSE pg.TotalPagos * ISNULL(pr.PropOrd, 0)
            END AS DECIMAL(18,2)
        ) AS Ordinarias,
        CAST(
            CASE WHEN pr.DeudaTotal IS NULL OR pr.DeudaTotal = 0
                 THEN 0
                 ELSE pg.TotalPagos * ISNULL(pr.PropExt, 0)
            END AS DECIMAL(18,2)
        ) AS Extraordinarias,
        CAST(
            CASE WHEN pr.DeudaTotal IS NULL OR pr.DeudaTotal = 0
                 THEN 0
                 ELSE pg.TotalPagos * ISNULL(pr.PropBau, 0)
            END AS DECIMAL(18,2)
        ) AS Baulera,
        CAST(
            CASE WHEN pr.DeudaTotal IS NULL OR pr.DeudaTotal = 0
                 THEN 0
                 ELSE pg.TotalPagos * ISNULL(pr.PropCoch, 0)
            END AS DECIMAL(18,2)
        ) AS Cochera,
        CAST(pg.TotalPagos AS DECIMAL(18,2)) AS Total
    FROM PagosPorMes pg
    LEFT JOIN Proporciones pr
           ON pr.mes = pg.mes
    ORDER BY pg.mes;
END;
GO

------------------------------ Reporte 4 -----------------------------
CREATE OR ALTER PROCEDURE bda.spTopMesesIngresosGastos
    @IdConsorcio INT,       -- filtrar por consorcio
    @AnioDesde INT,         -- año inicial para filtrar ingresos
    @AnioHasta INT          -- año final para filtrar ingresos
AS
BEGIN
    SET NOCOUNT ON;

    -- Si existe una tabla temporal previa, la elimino
    IF OBJECT_ID('tempdb..#Ingresos') IS NOT NULL DROP TABLE #Ingresos;

    -- Creo la tabla temporal que almacenará ingresos agrupados por año y mes
    CREATE TABLE #Ingresos (
        Anio INT,
        Mes TINYINT,
        TotalIngresos DECIMAL(20,2)
    );

    -- Inserto los ingresos agrupados por año/mes para ese consorcio y rango de años
    INSERT INTO #Ingresos (Anio, Mes, TotalIngresos)
    SELECT
        YEAR(p.fecha_pago) AS Anio,                 -- Año del pago
        MONTH(p.fecha_pago) AS Mes,                 -- Mes del pago
        SUM(p.importe) AS TotalIngresos             -- Suma total de ingresos del mes
    FROM bda.Pagos p
    INNER JOIN bda.Unidad_Funcional uf 
        ON uf.id_unidad = p.id_unidad               -- Relaciona pagos con una unidad funcional
    WHERE uf.id_consorcio = @IdConsorcio            -- Filtra por consorcio
      AND YEAR(p.fecha_pago) BETWEEN @AnioDesde AND @AnioHasta  -- Aplica filtro de años
    GROUP BY YEAR(p.fecha_pago), MONTH(p.fecha_pago);           -- Agrupa ingresos mensualizados


    IF OBJECT_ID('tempdb..#GastosTotales') IS NOT NULL DROP TABLE #GastosTotales;

    -- Creo la tabla temporal que almacenará los gastos totales por mes
    -- Luego sumo gastos ordinarios y gastos extraordinarios por mes

    CREATE TABLE #GastosTotales (
        Mes TINYINT,
        TotalGastos DECIMAL(20,2)
    );

    INSERT INTO #GastosTotales (Mes, TotalGastos)
    SELECT 
        COALESCE(o.Mes, e.Mes) AS Mes,   -- Si un mes existe solo en O o solo en E, elijo el que no sea NULL
        COALESCE(o.MontoOrdinario, 0) +  -- Si no hay gastos ordinarios en ese mes, pongo 0
        COALESCE(e.MontoExtraordinario, 0) AS TotalGastos   -- Igual para extraordinarios
    FROM
        (
            -- Subconsulta 'o': agrupa gastos ordinarios por mes
            SELECT mes AS Mes, SUM(importe) AS MontoOrdinario
            FROM bda.Gastos_Ordinarios
            WHERE id_consorcio = @IdConsorcio
            GROUP BY mes
        ) o
    FULL JOIN
        (
            -- Subconsulta 'e': agrupa gastos extraordinarios por mes
            SELECT mes AS Mes, SUM(importe) AS MontoExtraordinario
            FROM bda.Gastos_Extraordinarios
            WHERE id_consorcio = @IdConsorcio
            GROUP BY mes
        ) e
    ON o.Mes = e.Mes; -- Full join asegura que entran todos los meses (haya O, E, o ambos)

    -- Los 5 meses con mayores ingresos dentro del rango de años
    SELECT TOP 5 
        Anio,
        Mes,
        TotalIngresos
    FROM #Ingresos
    ORDER BY TotalIngresos DESC;

    -- Los 5 meses con mayores gastos
    SELECT TOP 5 
        Mes,
        TotalGastos
    FROM #GastosTotales
    ORDER BY TotalGastos DESC;


    DROP TABLE #Ingresos;         -- Elimino tabla temporal de ingresos
    DROP TABLE #GastosTotales;    -- Elimino tabla temporal de gastos

END;
GO

------------------------------ Reporte 5 -----------------------------

CREATE OR ALTER PROCEDURE bda.spMostrarTOP3Morosos
	@NombreConsorcio VARCHAR(80)
AS
	SET NOCOUNT ON;

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
	SELECT TOP 3 p_i.Nombre,p_i.Apellido,p_i.DNI,p_i.Email,p_i.Telefono,piuf.CVU_CBU_Propietario,de.deuda,c.nombre,uf.numero_unidad FROM bda.Detalle_Expensa de
	INNER JOIN Propietarios_Inquilinos_UF piuf ON de.id_uf = piuf.id_uf
	INNER JOIN Propietarios_Inquilinos p_i ON piuf.CVU_CBU_Propietario = p_i.CVU_CBU
	INNER JOIN bda.Unidad_Funcional uf ON piuf.id_uf = uf.id_unidad
	INNER JOIN bda.Consorcio c ON uf.id_consorcio = c.id_consorcio
	WHERE (c.nombre = @NombreConsorcio OR @NombreConsorcio IS NULL) --Esta linea permite el filtrado opcional
	ORDER BY deuda DESC
GO

------------------------------ Reporte 6 -----------------------------

CREATE OR ALTER PROCEDURE bda.sp_Reporte6_PagosIntervalos
(
    @IdConsorcio INT = NULL,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH PagosConUF AS
    (
        SELECT
            uf.id_unidad,
            uf.piso,
            uf.depto,
            uf.id_consorcio,
            p.fecha_pago,
            p.importe
        FROM bda.Pagos p
        JOIN bda.Propietario_en_UF pu
             ON pu.CVU_CBU_Propietario = p.cta_origen
        JOIN bda.Unidad_Funcional uf
             ON uf.id_unidad = pu.ID_UF
        WHERE 
            (@IdConsorcio IS NULL OR uf.id_consorcio = @IdConsorcio)
            AND (@FechaDesde IS NULL OR p.fecha_pago >= @FechaDesde)
            AND (@FechaHasta IS NULL OR p.fecha_pago <= @FechaHasta)
    )

    SELECT
        id_unidad AS UnidadFuncional,
        CONCAT(piso, '-', depto) AS Ubicacion,
        fecha_pago AS FechaPago,
        importe AS Importe,
        LEAD(fecha_pago) OVER (PARTITION BY id_unidad ORDER BY fecha_pago)
            AS FechaPagoSiguiente,
        DATEDIFF(
            DAY,
            fecha_pago,
            LEAD(fecha_pago) OVER (PARTITION BY id_unidad ORDER BY fecha_pago)
        ) AS DiasEntrePagos
    FROM PagosConUF
    ORDER BY id_unidad, fecha_pago;
END;
GO
