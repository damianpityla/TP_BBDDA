/* =========================================================
	07_CreacionRoles.sql - Com2900G13
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


--CREACION DE ROLES--
IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals 
    WHERE type = 'R' AND name = 'rol_admin_general'
)
    CREATE ROLE rol_admin_general;

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals 
    WHERE type = 'R' AND name = 'rol_admin_bancario'
)
    CREATE ROLE rol_admin_bancario;

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals 
    WHERE type = 'R' AND name = 'rol_admin_operativo'
)
    CREATE ROLE rol_admin_operativo;

IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals 
    WHERE type = 'R' AND name = 'rol_sistemas'
)
    CREATE ROLE rol_sistemas;
GO


--ASIGNACION DE PERMISOS A CADA ROL--

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


	/* PARA BORRAR ROLES:

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin_general')
    DROP ROLE rol_admin_general;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin_bancario')
    DROP ROLE rol_admin_bancario;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin_operativo')
    DROP ROLE rol_admin_operativo;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_sistemas')
    DROP ROLE rol_sistemas;
	*/

-- VER ROLES
SELECT name, type_desc 
FROM sys.database_principals
WHERE type = 'R'
ORDER BY name;



--- VER PERMISOS DE CADA ROL
SELECT 
    dp.name AS Principal,
    perm.permission_name,
    perm.state_desc,
    perm.class_desc,
    OBJECT_NAME(perm.major_id) AS Objeto
FROM sys.database_permissions perm
JOIN sys.database_principals dp ON perm.grantee_principal_id = dp.principal_id
where dp.name in(
        'rol_admin_general',
        'rol_admin_bancario',
        'rol_admin_operativo',
        'rol_sistemas'
     )
ORDER BY dp.name;