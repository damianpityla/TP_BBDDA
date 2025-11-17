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