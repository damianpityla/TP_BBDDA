/* =========================================================
	04_Pruebas.sql - Com2900G13
	Proyecto: Altos de Saint Just
	Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo ejecuta las pruebas

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

------------------------------ BAULERAS Y COCHERAS -----------------------------

EXEC bda.spCargarBaulerasCocheras 

SELECT * FROM bda.Baulera
SELECT * FROM bda.Cochera

--DBCC CHECKIDENT ('bda.Baulera', RESEED, 0);
--DELETE FROM bda.Baulera

--DBCC CHECKIDENT ('bda.Cochera', RESEED, 0);
--DELETE FROM bda.Cochera

------------------------------ ALTA DE GASTOS EXTRAORDINARIOS -----------------------------

EXEC bda.spAltaGastoExtraordinario
	@IdConsorcio = 1,
	@Mes = 4,
	@Descripcion = 'INSTALACION CAMARAS DE SEGURIDAD PRIMER PISO',
	@Importe = 380000

EXEC bda.spAltaGastoExtraordinario
	@IdConsorcio = 1,
	@Mes = 5,
	@Descripcion = 'INSTALACION CAMARAS DE SEGURIDAD SEGUNDO PISO',
	@Importe = 570000

SELECT * FROM bda.Gastos_Extraordinarios

--DELETE FROM bda.Gastos_Extraordinarios
--DBCC CHECKIDENT ('bda.Gastos_Extraordinarios', RESEED, 0);

------------------------------ ALTA DE GASTOS ORDINARIOS DEL MES 7 -----------------------------

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 1,
	@Mes = 7,
	@ImporteBancario = 23000,
	@ImporteLimpieza = 130000,
	@ImporteAdministracion = 220000,
	@ImporteSeguros = 35000,
	@ImporteGastosGenerales = 10000,
	@ImporteAgua = 520000,
	@ImporteLuz = 560000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 2,
	@Mes = 7,
	@ImporteBancario = 24000,
	@ImporteLimpieza = 140000,
	@ImporteAdministracion = 240000,
	@ImporteSeguros = 34000,
	@ImporteGastosGenerales = 0,
	@ImporteAgua = 530000,
	@ImporteLuz = 570000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 3,
	@Mes = 7,
	@ImporteBancario = 25000,
	@ImporteLimpieza = 150000,
	@ImporteAdministracion = 240000,
	@ImporteSeguros = 37000,
	@ImporteGastosGenerales = 11000,
	@ImporteAgua = 540000,
	@ImporteLuz = 580000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 4,
	@Mes = 7,
	@ImporteBancario = 26000,
	@ImporteLimpieza = 160000,
	@ImporteAdministracion = 250000,
	@ImporteSeguros = 38000,
	@ImporteGastosGenerales = 12000,
	@ImporteAgua = 550000,
	@ImporteLuz = 590000

EXEC bda.spAltaGastosOrdinarios
	@IdConsorcio = 5,
	@Mes = 7,
	@ImporteBancario = 27000,
	@ImporteLimpieza = 170000,
	@ImporteAdministracion = 260000,
	@ImporteSeguros = 39000,
	@ImporteGastosGenerales = 13000,
	@ImporteAgua = 560000,
	@ImporteLuz = 600000

SELECT * FROM bda.Gastos_Ordinarios WHERE mes = 7

--DELETE FROM bda.Gastos_Ordinarios WHERE mes = 7

---------------------------- PRUEBAS SP ALTA ----------------------------
PRINT '--- PRUEBAS CONSORCIO ---';

EXEC bda.spAltaConsorcio 
    @Nombre = 'Azcuenaga',
    @Direccion = 'Av. Rivadavia 3500',
    @CantUF = 12,
    @M2Totales = 1800;

EXEC bda.spAltaConsorcio 
    @Nombre = '',
    @Direccion = 'Calle Siempreviva 123',
    @CantUF = 12,
    @M2Totales = 1800;

EXEC bda.spAltaConsorcio 
    @Nombre = 'Test',
    @Direccion = 'Calle Falsa 123',
    @CantUF = 12,
    @M2Totales = -5;



PRINT '--- PRUEBAS UNIDAD FUNCIONAL ---';

EXEC bda.spAltaUnidadFuncional
    @IdConsorcio = 1,
    @NumeroUnidad = 1,
    @Piso = '1',
    @Depto = 'A',
    @M2_UF = 45,
    @Porcentaje = 2.5,
    @Baulera = 1,
    @M2_Baulera = 3,
    @Cochera = 1,
    @M2_Cochera = 12;

EXEC bda.spAltaUnidadFuncional
    @IdConsorcio = 999,
    @NumeroUnidad = 1,
    @Piso = '1',
    @Depto = 'A',
    @M2_UF = 45,
    @Porcentaje = 2.5,
    @Baulera = 0,
    @M2_Baulera = 0,
    @Cochera = 0,
    @M2_Cochera = 0;



PRINT '--- PRUEBAS PROPIETARIO ---';

EXEC bda.spAltaPropietario
    @Nombre = 'Juan',
    @Apellido = 'Gomez',
    @DNI = '30111222',
    @Email = 'juan@test.com',
    @Telefono = '1122334455',
    @CVU_CBU = '0001234500001234500011';

EXEC bda.spAltaPropietario
    @Nombre = 'Luis',
    @Apellido = 'Martinez',
    @DNI = '29123123',
    @Email = 'luis@test.com',
    @Telefono = '1188776655',
    @CVU_CBU = '0001234500001234500011';



PRINT '--- PRUEBAS INQUILINO ---';

EXEC bda.spAltaInquilino
    @Nombre = 'Carla',
    @Apellido = 'Lopez',
    @DNI = '32123444',
    @Email = 'carla@mail.com',
    @Telefono = '1122112211',
    @CVU_CBU = '1000000000000000000001';

EXEC bda.spAltaInquilino
    @Nombre = 'Mara',
    @Apellido = 'Diaz',
    @DNI = '32000000',
    @Email = 'mara@mail.com',
    @Telefono = '1188112211',
    @CVU_CBU = '';



PRINT '--- PRUEBAS PROPIETARIO EN UF ---';

EXEC bda.spAltaPropietarioEnUF
    @CVU_CBU_Propietario = '0001234500001234500011',
    @IdUF = 1;

EXEC bda.spAltaPropietarioEnUF
    @CVU_CBU_Propietario = '0001234500001234500011',
    @IdUF = 999;



PRINT '--- PRUEBAS INQUILINO EN UF ---';

EXEC bda.spAltaInquilinoEnUF
    @CVU_CBU_Inquilino = '1000000000000000000001',
    @IdUF = 1;

EXEC bda.spAltaInquilinoEnUF
    @CVU_CBU_Inquilino = '2220000000000000000000',
    @IdUF = 1;



PRINT '--- PRUEBAS PROVEEDOR ---';

EXEC bda.spAltaProveedor
    @Servicio = 'Limpieza',
    @Descripcion = 'Servicio mensual de limpieza',
    @Cuenta = '12345',
    @IdConsorcio = 1;

EXEC bda.spAltaProveedor
    @Servicio = 'Limpieza',
    @Descripcion = 'Servicio mensual',
    @Cuenta = NULL,
    @IdConsorcio = 999;



PRINT '--- PRUEBAS EXPENSA ---';

EXEC bda.spAltaExpensa
    @IdConsorcio = 1,
    @Mes = 4,
    @FechaEmision = '2024-04-01',
    @Venc1 = '2024-04-10',
    @Venc2 = '2024-04-20';

EXEC bda.spAltaExpensa
    @IdConsorcio = 1,
    @Mes = 5,
    @FechaEmision = '2024-05-01',
    @Venc1 = '2024-05-10',
    @Venc2 = '2024-05-05';



PRINT '--- PRUEBAS PAGO ---';

EXEC bda.spAltaPago
    @IdPago = 1,
    @FechaPago = '2024-04-03',
    @CtaOrigen = '0011223344556677889900',
    @Importe = 15000,
    @Asociado = 0,
    @IdUnidad = 1,
    @IdExpensa = 1;

EXEC bda.spAltaPago
    @IdPago = 2,
    @FechaPago = '2024-04-03',
    @CtaOrigen = '0011223344556677889900',
    @Importe = -2000,
    @Asociado = 0,
    @IdUnidad = 1,
    @IdExpensa = 1;



PRINT '--- PRUEBAS DETALLE EXPENSA ---';

EXEC bda.spAltaDetalleExpensa
    @IdExpensa = 1,
    @IdUF = 1,
    @IdPago = 1,
    @Interes = 0,
    @ValOrd = 15000,
    @ValExt = 0,
    @ValBaul = 500,
    @ValCoch = 1200;

EXEC bda.spAltaDetalleExpensa
    @IdExpensa = 1,
    @IdUF = 1,
    @IdPago = 999,
    @Interes = 0,
    @ValOrd = 15000,
    @ValExt = 0,
    @ValBaul = 500,
    @ValCoch = 1200;



PRINT '--- PRUEBAS ESTADO FINANCIERO ---';

EXEC bda.spAltaEstadoFinanciero
    @IdExpensa = 1,
    @SaldoAnterior = 10000,
    @IngTermino = 15000,
    @IngAdeudados = 3000,
    @IngAdelantados = 2000,
    @EgresosMes = 8000;

EXEC bda.spAltaEstadoFinanciero
    @IdExpensa = 1,
    @SaldoAnterior = 0,
    @IngTermino = 0,
    @IngAdeudados = 0,
    @IngAdelantados = 0,
    @EgresosMes = 0;



PRINT '--- PRUEBAS GASTOS ORDINARIOS ---';

EXEC bda.spAltaGastoOrdinario
    @IdConsorcio = 1,
    @Mes = 4,
    @TipoGasto = 'Luz',
    @Importe = 50000;

EXEC bda.spAltaGastoOrdinario
    @IdConsorcio = 1,
    @Mes = 13,
    @TipoGasto = 'Luz',
    @Importe = 50000;



PRINT '--- PRUEBAS GASTOS EXTRAORDINARIOS ---';

EXEC bda.spAltaGastoExtraordinario
    @IdConsorcio = 1,
    @Mes = 4,
    @Descripcion = 'Reparacion ascensor',
    @Importe = 340000;

EXEC bda.spAltaGastoExtraordinario
    @IdConsorcio = 1,
    @Mes = 4,
    @Descripcion = 'Reparacion ascensor',
    @Importe = 0;

------------------------------ GENERACION DE EXPENSAS -----------------------------

EXEC bda.spMostrarExpensaGenerada @NombreConsorcio = 'Azcuenaga';
EXEC bda.spMostrarExpensaGenerada @NombreConsorcio = 'Alzaga';
EXEC bda.spMostrarExpensaGenerada @NombreConsorcio = 'Alberdi';
EXEC bda.spMostrarExpensaGenerada @NombreConsorcio = 'Unzue';
EXEC bda.spMostrarExpensaGenerada @NombreConsorcio = 'Pereyra Iraola';

SELECT * FROM bda.Estado_Financiero

-- MES DE ABRIL

EXEC bda.spGenerarExpensas
	@Mes = 4

-- MES DE MAYO

EXEC bda.spGenerarExpensas
	@Mes = 5

-- MES DE JUNIO

EXEC bda.spGenerarExpensas
	@Mes = 6

-- MES DE JULIO

EXEC bda.spGenerarExpensas
	@Mes = 7

/*
SELECT * FROM bda.Expensa
SELECT * FROM bda.Detalle_Expensa ORDER BY id_expensa,id_uf

DBCC CHECKIDENT ('bda.Detalle_Expensa', RESEED, 0);
DELETE FROM bda.Detalle_Expensa

DBCC CHECKIDENT ('bda.Estado_Financiero', RESEED, 0);
DELETE FROM bda.Estado_Financiero

DBCC CHECKIDENT ('bda.Expensa', RESEED, 0);
DELETE FROM bda.Expensa
*/