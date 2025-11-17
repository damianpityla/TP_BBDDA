/* =========================================================
	 - Com2900G13
	Proyecto: Altos de Saint Just
    Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea los Roles de la base de datos

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

CREATE ROLE rol_admin_general;
CREATE ROLE rol_admin_bancario;
CREATE ROLE rol_admin_operativo;
CREATE ROLE rol_sistemas;

-- ADMIN GENERAL
GRANT UPDATE, INSERT, SELECT ON bda.Unidad_Funcional TO rol_admin_general;
GRANT EXECUTE ON SCHEMA::bda TO rol_admin_general;

-- ADMIN BANCARIO
GRANT INSERT, SELECT ON bda.Pagos TO rol_admin_bancario;
GRANT EXECUTE ON bda.spImportarPagosConsorcios TO rol_admin_bancario;


GRANT EXECUTE ON bda.spReporteFlujoCajaSemanal TO rol_admin_bancario;
GRANT EXECUTE ON bda.sp_ReportePagosPorDeptoMensual TO rol_admin_bancario;
GRANT EXECUTE ON bda.spReporteRecaudacionPorProcedencia TO rol_admin_bancario;
GRANT EXECUTE ON bda.spTopMesesIngresosGastos TO rol_admin_bancario;
GRANT EXECUTE ON bda.spMostrarTOP3Morosos TO rol_admin_bancario;
GRANT EXECUTE ON bda.sp_Reporte6_PagosIntervalos TO rol_admin_bancario;

-- ADMIN OPERATIVO
GRANT UPDATE, INSERT, SELECT ON bda.Unidad_Funcional TO rol_admin_operativo;
GRANT EXECUTE ON SCHEMA::bda TO rol_admin_operativo;

-- SISTEMAS
GRANT EXECUTE ON bda.spReporteFlujoCajaSemanal TO rol_sistemas;
GRANT EXECUTE ON bda.sp_ReportePagosPorDeptoMensual TO rol_sistemas;
GRANT EXECUTE ON bda.spReporteRecaudacionPorProcedencia TO rol_sistemas;
GRANT EXECUTE ON bda.spTopMesesIngresosGastos TO rol_sistemas;
GRANT EXECUTE ON bda.spMostrarTOP3Morosos TO rol_sistemas;
GRANT EXECUTE ON bda.sp_Reporte6_PagosIntervalos TO rol_sistemas;

DENY UPDATE, INSERT, DELETE ON SCHEMA::bda TO rol_sistemas;