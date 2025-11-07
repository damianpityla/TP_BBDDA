/* =========================================================
	01_CreacionTablas.sql - Com2900G13
	Proyecto: Altos de Saint Just
	Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea tablas, PK/FK y restricciones segun DER.

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

-- Consorcio
IF OBJECT_ID('bda.Consorcio') IS NOT NULL DROP TABLE bda.Consorcio;
CREATE TABLE bda.Consorcio (
  id_consorcio INT IDENTITY(1,1) PRIMARY KEY,
  nombre NVARCHAR(200) NOT NULL,
  direccion NVARCHAR(200) NOT NULL,
  cant_unidades_func INT NOT NULL,
  m2_totales INT NOT NULL
);

-- Unidad_Funcional
IF OBJECT_ID('bda.Unidad_Funcional') IS NOT NULL DROP TABLE bda.Unidad_Funcional;
CREATE TABLE bda.Unidad_Funcional (
	id_unidad INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	id_consorcio INT NOT NULL,
	numero_unidad TINYINT NOT NULL,
	piso VARCHAR(2) NOT NULL,
	depto CHAR(1) NOT NULL,
	m2_unidad_funcional TINYINT NOT NULL,
	porcentaje DECIMAL(4,1) NOT NULL,
	baulera BIT NOT NULL,
	m2_baulera TINYINT NOT NULL,
	cochera BIT NOT NULL,
	m2_cochera TINYINT NOT NULL,
	CONSTRAINT FK_UF_Consorcio FOREIGN KEY (id_consorcio) REFERENCES bda.Consorcio(id_consorcio)
);
CREATE INDEX IX_UF_Consorcio ON bda.Unidad_Funcional(id_consorcio);

-- Baulera
IF OBJECT_ID('bda.Baulera') IS NOT NULL DROP TABLE bda.Baulera;
CREATE TABLE bda.Baulera (
	id_baulera INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	id_uf INT NOT NULL,
	importe INT NOT NULL
	CONSTRAINT FK_Baulera_UF FOREIGN KEY (id_uf) REFERENCES bda.Unidad_Funcional(id_unidad),
);
CREATE NONCLUSTERED INDEX IX_Baulera_UF ON bda.Baulera(id_uf);

-- Cochera
IF OBJECT_ID('bda.Cochera') IS NOT NULL DROP TABLE bda.Cochera;
CREATE TABLE bda.Cochera (
	id_cochera INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	id_uf INT NOT NULL,
	importe INT NOT NULL
	CONSTRAINT FK_Cochera_UF FOREIGN KEY (id_uf) REFERENCES bda.Unidad_Funcional(id_unidad)
);
CREATE NONCLUSTERED INDEX IX_Cochera_UF ON bda.Cochera(id_uf);

--Propietario
IF OBJECT_ID('bda.Propietario') IS NOT NULL DROP TABLE bda.Propietario;
CREATE TABLE bda.Propietario (
	ID_Propietario INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(30),
	Apellido VARCHAR(30),
	DNI VARCHAR(15),
	Email VARCHAR(60),
	Telefono VARCHAR(15),
	CVU_CBU VARCHAR(22) UNIQUE
);

--Inquilino
IF OBJECT_ID('bda.Inquilino') IS NOT NULL DROP TABLE bda.Inquilino;
CREATE TABLE bda.Inquilino (
	ID_Inquilino INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(30),
	Apellido VARCHAR(30),
	DNI VARCHAR(15),
	Email VARCHAR(60),
	Telefono VARCHAR(15),
	CVU_CBU VARCHAR(22) UNIQUE
);

--propietario_en_UF
IF OBJECT_ID('bda.Propietario_en_UF') IS NOT NULL DROP TABLE bda.Propietario_en_UF;
CREATE TABLE bda.Propietario_en_UF (
	ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	CVU_CBU_Propietario VARCHAR(22) NOT NULL,
	ID_UF INT NOT NULL,
	CONSTRAINT FK_PeUF_P FOREIGN KEY (CVU_CBU_Propietario) REFERENCES bda.Propietario(CVU_CBU),
	CONSTRAINT FK_PeUF_UF  FOREIGN KEY (ID_UF)  REFERENCES bda.Unidad_Funcional(id_unidad)
);

--inquilino_en_UF
IF OBJECT_ID('bda.Inquilino_en_UF') IS NOT NULL DROP TABLE bda.Inquilino_en_UF;
CREATE TABLE bda.Inquilino_en_UF (
	ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	CVU_CBU_Inquilino VARCHAR(22) NOT NULL,
	ID_UF INT NOT NULL,
	CONSTRAINT FK_IeUF_I FOREIGN KEY (CVU_CBU_Inquilino) REFERENCES bda.Inquilino(CVU_CBU),
	CONSTRAINT FK_IeUF_UF  FOREIGN KEY (ID_UF)  REFERENCES bda.Unidad_Funcional(id_unidad)
);

--proveedor
IF OBJECT_ID('bda.Proveedor') IS NOT NULL DROP TABLE bda.Proveedor;
CREATE TABLE bda.Proveedor (
	id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
	servicio VARCHAR(30) NOT NULL,
	descripcion VARCHAR(100) NOT NULL,
	cuenta VARCHAR(30),
	ID_Consorcio INT,
	CONSTRAINT FK_Proveedor_Consorcio FOREIGN KEY (ID_Consorcio) REFERENCES bda.Consorcio(id_consorcio)
);

--expensa
IF OBJECT_ID('bda.Expensa') IS NOT NULL DROP TABLE bda.Expensa;
CREATE TABLE bda.Expensa (
	id_expensa INT IDENTITY(1,1) PRIMARY KEY,
	id_consorcio INT NOT NULL,
	mes TINYINT NOT NULL CHECK (mes BETWEEN 1 AND 12),
	fecha_emision DATE NOT NULL,
	vencimiento1 DATE NOT NULL,
	vencimiento2 DATE NOT NULL,
	CONSTRAINT FK_Expensa_Consorcio FOREIGN KEY (id_consorcio) REFERENCES bda.Consorcio(id_consorcio),
	CONSTRAINT CK_Expensa_Vencs CHECK (vencimiento2 > vencimiento1),
	CONSTRAINT UQ_Expensa UNIQUE (id_consorcio, mes)
);
CREATE INDEX IX_Expensa_Consorcio ON bda.Expensa(id_consorcio);

-- Detalle_Expensa
IF OBJECT_ID('bda.Detalle_Expensa') IS NOT NULL DROP TABLE bda.Detalle_Expensa;
CREATE TABLE bda.Detalle_Expensa (
	id_detalle INT IDENTITY(1,1) PRIMARY KEY,
	id_expensa INT NOT NULL,
	id_uf INT NOT NULL,
	valor_ordinarias DECIMAL(18,2) NOT NULL,
	valor_extraordinarias DECIMAL(18,2) NOT NULL,
	valor_baulera INT NOT NULL,
	valor_cochera INT NOT NULL,
	CONSTRAINT FK_Det_Exp FOREIGN KEY (id_expensa) REFERENCES bda.Expensa(id_expensa),
	CONSTRAINT FK_Det_UF  FOREIGN KEY (id_uf) REFERENCES bda.Unidad_Funcional(id_unidad),
);

-- Estado Financiero
IF OBJECT_ID('bda.Estado_Financiero') IS NOT NULL DROP TABLE bda.Estado_Financiero;
CREATE TABLE bda.Estado_Financiero (
  id_estado INT IDENTITY(1,1) PRIMARY KEY,
  id_expensa INT NOT NULL UNIQUE,
  saldo_anterior DECIMAL(18,2) NOT NULL DEFAULT 0,
  ingresos_termino DECIMAL(18,2) NOT NULL DEFAULT 0,
  ingresos_adeudados DECIMAL(18,2) NOT NULL DEFAULT 0,
  ingresos_adelantados DECIMAL(18,2) NOT NULL DEFAULT 0,
  egresos_mes DECIMAL(18,2) NOT NULL DEFAULT 0,
  saldo_cierre AS (saldo_anterior + ingresos_termino + ingresos_adeudados + ingresos_adelantados - egresos_mes) PERSISTED,
  CONSTRAINT FK_EF_Expensa FOREIGN KEY (id_expensa) REFERENCES bda.Expensa(id_expensa)
);

-- Gastos Ordinarios
IF OBJECT_ID('bda.Gastos_Ordinarios') IS NOT NULL DROP TABLE bda.Gastos_Ordinarios;
CREATE TABLE bda.Gastos_Ordinarios (
  id_gasto_ordinario INT IDENTITY(1,1) PRIMARY KEY,
  id_consorcio INT NOT NULL,
  id_proveedor INT NULL,
  mes TINYINT NOT NULL CHECK (mes BETWEEN 1 AND 12),
  tipo_gasto NVARCHAR(100) NOT NULL,   -- banco/limpieza/admin/seguros/etc.
  nro_factura NVARCHAR(50) NULL,
  importe DECIMAL(18,2) NOT NULL,
  CONSTRAINT FK_GO_consorcio FOREIGN KEY (id_consorcio) REFERENCES bda.Consorcio(id_consorcio),
  CONSTRAINT FK_GO_Proveedor FOREIGN KEY (id_proveedor) REFERENCES bda.Proveedor(id_proveedor)
);

-- Gastos Extraordinarios
IF OBJECT_ID('bda.Gastos_Extraordinarios') IS NOT NULL DROP TABLE bda.Gastos_Extraordinarios;
CREATE TABLE bda.Gastos_Extraordinarios (
	id_gasto_extraordinario INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	id_consorcio INT NOT NULL,
	--id_proveedor INT NOT NULL,
	descripcion VARCHAR(100) NOT NULL,
	importe DECIMAL(18,2) NOT NULL,
	--paga_en_cuotas BIT NOT NULL DEFAULT(0),
	--nro_de_cuotas SMALLINT NULL CHECK (nro_de_cuotas IS NULL OR (nro_de_cuotas BETWEEN 1 AND 120)),
	CONSTRAINT FK_GE_UF FOREIGN KEY (id_consorcio) REFERENCES bda.Consorcio(id_consorcio),
	--CONSTRAINT FK_GE_Proveedor FOREIGN KEY (id_proveedor) REFERENCES bda.Proveedor(id_proveedor)
);

-- Pagos
IF OBJECT_ID('bda.Pagos') IS NOT NULL DROP TABLE bda.Pagos;
CREATE TABLE bda.Pagos (
	id_pago INT PRIMARY KEY NOT NULL,
	fecha_pago DATE NOT NULL,
	cta_origen VARCHAR(22) NOT NULL, -- CVU/CBU
	importe DECIMAL(18,2) NOT NULL CHECK (importe >= 0),
	asociado BIT NULL DEFAULT(0),
	id_unidad INT NULL,
	id_expensa INT NULL,
	CONSTRAINT FK_Pagos_UF FOREIGN KEY (id_unidad) REFERENCES bda.Unidad_Funcional(id_unidad),
	CONSTRAINT FK_Pagos_Expensa FOREIGN KEY (id_expensa) REFERENCES bda.Expensa(id_expensa)
);
CREATE INDEX IX_Pagos_Asociacion  ON bda.Pagos(asociado, id_unidad, id_expensa);
CREATE INDEX IX_Pagos_CuentaFecha ON bda.Pagos(cta_origen, fecha_pago);