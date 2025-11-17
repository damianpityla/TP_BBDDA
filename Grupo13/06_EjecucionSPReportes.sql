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
exec bda.spReporte1Expensas 
	@NombreConsorcio= 'Azcuenaga',
    @Mes= 6;
------------------------------ Reporte 2 -----------------------------
exec bda.sp_ReportePagosPorDeptoMensual 
    @id_consorcio = 2,
    @Anio= 2025;


------------------------------ Reporte 3 -----------------------------

------------------------------ Reporte 4 -----------------------------
EXEC bda.spTopMesesIngresosGastos 
    @IdConsorcio = 1,
    @AnioDesde = 2023,
    @AnioHasta = 2025;
------------------------------ Reporte 5 -----------------------------

EXEC bda.spMostrarTOP3Morosos
	@NombreConsorcio = 'Azcuenaga'

------------------------------ Reporte 6 -----------------------------

EXEC bda.sp_Reporte6_PagosIntervalos	--Consultar todos los consorcios

EXEC bda.sp_Reporte6_PagosIntervalos	--Consultar consorcio 1 (por ejemplo) en todo 2024
    @IdConsorcio = 1,
    @FechaDesde = '2024-01-01',	
    @FechaHasta = '2024-12-31';			--


EXEC bda.sp_Reporte6_PagosIntervalos	--Filtar por fechas
    @FechaDesde = '2024-01-01',
    @FechaHasta = '2024-06-30';			--

EXEC bda.sp_Reporte6_PagosIntervalos	--Filtar por consorcio sin rango de fechas
    @IdConsorcio = 2;					--
