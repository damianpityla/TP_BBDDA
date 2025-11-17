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
CREATE OR ALTER PROCEDURE bda.spReporte1Expensas
    @NombreConsorcio VARCHAR(80),
    @Mes TINYINT
AS
BEGIN
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
    SELECT
        c.nombre                          AS Consorcio,
        e.mes                             AS Mes,
        uf.numero_unidad                  AS Unidad,
        uf.piso + '-' + uf.depto          AS Piso_Depto,
        p_i.Nombre + ' ' + p_i.Apellido   AS Propietario_Inquilino,
        de.saldo_anterior,
        de.pago_recibido,
        de.deuda,
        de.interes_por_mora,
        de.valor_ordinarias,
        de.valor_extraordinarias,
        de.valor_baulera,
        de.valor_cochera,
        de.total                          AS Total_A_Pagar
    FROM bda.Detalle_Expensa de
    INNER JOIN Propietarios_Inquilinos_UF piuf 
        ON de.id_uf = piuf.ID_UF               
    INNER JOIN Propietarios_Inquilinos p_i 
        ON piuf.CVU_CBU_Propietario = p_i.CVU_CBU
    INNER JOIN bda.Unidad_Funcional uf 
        ON piuf.ID_UF = uf.id_unidad
    INNER JOIN bda.Expensa e 
        ON de.id_expensa = e.id_expensa
    INNER JOIN bda.Consorcio c 
        ON uf.id_consorcio = c.id_consorcio
    WHERE (c.nombre = @NombreConsorcio OR @NombreConsorcio IS NULL)
      AND e.mes = @Mes
    ORDER BY uf.numero_unidad;
END;
GO

------------------------------ Reporte 2 -----------------------------

------------------------------ Reporte 3 -----------------------------

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

------------------------------ Reporte 6 - Estandar -----------------------------

CREATE OR ALTER PROCEDURE bda.sp_Reporte6_PagosIntervalos
(
    @IdConsorcio INT = NULL,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH PagosPorExpensa AS
    (
        SELECT
            uf.id_unidad,
            uf.id_consorcio,
            CONCAT(uf.piso, '-', uf.depto) AS ubicacion,
            p.fecha_pago,
            p.importe,
            p.asociado,
            e.id_expensa
        FROM bda.Pagos p
        INNER JOIN bda.Unidad_Funcional uf 
            ON p.id_unidad = uf.id_unidad
        INNER JOIN bda.Expensa e
            ON e.id_consorcio = uf.id_consorcio
           AND e.mes = MONTH(p.fecha_pago)
           AND p.fecha_pago BETWEEN e.fecha_emision AND e.vencimiento2
        WHERE (@IdConsorcio IS NULL OR uf.id_consorcio = @IdConsorcio)
          AND (@FechaDesde IS NULL OR p.fecha_pago >= @FechaDesde)
          AND (@FechaHasta IS NULL OR p.fecha_pago <= @FechaHasta)
    )

    SELECT
        id_consorcio,
        id_unidad,
        ubicacion,
        fecha_pago AS FechaPago,
        importe AS Importe,
        asociado AS PagoAsociado,
        LEAD(fecha_pago) OVER (PARTITION BY id_unidad ORDER BY fecha_pago) AS FechaPagoSiguiente,
        DATEDIFF(
            DAY,
            fecha_pago,
            LEAD(fecha_pago) OVER (PARTITION BY id_unidad ORDER BY fecha_pago)
        ) AS DiasEntrePagos
    FROM PagosPorExpensa
    ORDER BY id_unidad, fecha_pago;
END;
GO