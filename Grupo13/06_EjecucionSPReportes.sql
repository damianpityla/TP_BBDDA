/* =========================================================
	06_EjecucionSPReportes.sql - Com2900G13
	Proyecto: Altos de Saint Just
	Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo ejecuta los SP de los reportes

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

EXEC bda.spReporteFlujoCajaSemanal
    @NombreConsorcio = 'Azcuenaga',
    @Mes = 6

------------------------------ Reporte 2 -----------------------------

EXEC bda.sp_ReportePagosPorDeptoMensual 
    @id_consorcio = 3,
    @Anio = 2025,
	@MesDesde = 4,
	@MesHasta = 7;

------------------------------ Reporte 3 -----------------------------

EXEC bda.spReporteRecaudacionPorProcedencia
    @NombreConsorcio = 'Azcuenaga',
    @MesDesde = 4,
    @MesHasta = 7;

------------------------------ Reporte 4 -----------------------------

EXEC bda.spTopMesesIngresosGastos 
    @IdConsorcio = 1,
    @AnioDesde = 2023,
    @AnioHasta = 2025;

------------------------------ Reporte 5 -----------------------------

EXEC bda.spMostrarTOP3Morosos
	@NombreConsorcio = NULL,
	@NombreDeudor = NULL,
	@ApellidoDeudor = NULL;

------------------------------ Reporte 6 -----------------------------

EXEC bda.sp_Reporte6_PagosIntervalos
	@IdConsorcio = 3,
    @FechaDesde = NULL,
    @FechaHasta = NULL
