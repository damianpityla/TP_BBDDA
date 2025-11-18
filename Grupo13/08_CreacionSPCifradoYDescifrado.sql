/* =========================================================
    08_CreacionSPCifradoYDescifrado.sql - Com2900G13
    Proyecto: Altos de Saint Just
    Materia: Bases de Datos Aplicada
    Grupo: 13

    Contenido:
    1) Alteracion de tablas para agregar columnas cifradas
    2) SP para cifrar datos existentes y limpiar texto plano
    3) Triggers para cifrar nuevas inserciones/actualizaciones
    4) Ajuste del Reporte 5 (TOP morosos) para mostrar datos
       desencriptados y legibles

    NOTA: No se modifican SP existentes, cumpliendo la consigna.

    Alumnos:
		45628269 - Liber Federico Manuel 
		46265307 - Ares Nicolás jesús 
		45754471 - Pityla Damian 
		42587858 - Murillo Joel
		46292592 - Larriba Pedro Ezequiel 
		40464246 - Diaz Ortiz  Lucas Javier 
========================================================= */

USE Com2900G13;
GO

------------------------------------------------------------
-- 1) ALTERACION DE TABLAS - agregar columnas cifradas
------------------------------------------------------------

-- PROPIETARIO
IF COL_LENGTH('bda.Propietario', 'DNI_enc') IS NULL
BEGIN
    ALTER TABLE bda.Propietario
    ADD DNI_enc VARBINARY(MAX),
        Email_enc VARBINARY(MAX),
        Telefono_enc VARBINARY(MAX),
        CVU_CBU_enc VARBINARY(MAX);
END;

-- INQUILINO
IF COL_LENGTH('bda.Inquilino', 'DNI_enc') IS NULL
BEGIN
    ALTER TABLE bda.Inquilino
    ADD DNI_enc VARBINARY(MAX),
        Email_enc VARBINARY(MAX),
        Telefono_enc VARBINARY(MAX),
        CVU_CBU_enc VARBINARY(MAX);
END;

-- PAGOS
IF COL_LENGTH('bda.Pagos', 'cta_origen_enc') IS NULL
BEGIN
    ALTER TABLE bda.Pagos
    ADD cta_origen_enc VARBINARY(MAX);
END;
GO

CREATE OR ALTER PROCEDURE bda.spCifrarDatosSensibles
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @passphrase NVARCHAR(128) = 'AltosDeSaintJust#2024';

    -- PROPIETARIO
    UPDATE bda.Propietario
    SET DNI_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), DNI)),
        Email_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(100), Email)),
        Telefono_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(30), Telefono)),
        CVU_CBU_enc  = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), CVU_CBU));

    UPDATE bda.Propietario
    SET DNI = NULL,
        Email = NULL,
        Telefono = NULL;
        -- NO tocamos CVU_CBU por el FK

    -- INQUILINO
    UPDATE bda.Inquilino
    SET DNI_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), DNI)),
        Email_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(100), Email)),
        Telefono_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(30), Telefono)),
        CVU_CBU_enc  = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), CVU_CBU));

    UPDATE bda.Inquilino
    SET DNI = NULL,
        Email = NULL,
        Telefono = NULL;
        -- NO tocamos CVU_CBU por el FK

    -- PAGOS
    UPDATE bda.Pagos
    SET cta_origen_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), cta_origen));
	

    PRINT 'Datos cifrados correctamente.';
END;
GO

-- TRIGGERS PARA CIFRAR AUTOMATICAMENTE DATOS NUEVOS

--TRIGGER PROPIETARIO
CREATE OR ALTER TRIGGER bda.trgCifrarPropietario
ON bda.Propietario
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @passphrase NVARCHAR(128) = 'AltosDeSaintJust#2024';

    UPDATE P
    SET DNI_enc      = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), I.DNI)),
        Email_enc    = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(100), I.Email)),
        Telefono_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(30), I.Telefono)),
        CVU_CBU_enc  = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), I.CVU_CBU)),
        DNI = NULL,
        Email = NULL,
        Telefono = NULL
        -- NO seteamos CVU_CBU = NULL para no romper el FK
    FROM bda.Propietario P
    INNER JOIN inserted I ON P.ID_Propietario = I.ID_Propietario;
END;
GO

--TRIGGER INQUILINO 
CREATE OR ALTER TRIGGER bda.trgCifrarInquilino
ON bda.Inquilino
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @passphrase NVARCHAR(128) = 'AltosDeSaintJust#2024';

    UPDATE Iq
    SET DNI_enc      = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), I.DNI)),
        Email_enc    = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(100), I.Email)),
        Telefono_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(30), I.Telefono)),
        CVU_CBU_enc  = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), I.CVU_CBU)),
        DNI = NULL,
        Email = NULL,
        Telefono = NULL
        -- CVU_CBU se mantiene para no romper FKs
    FROM bda.Inquilino Iq
    INNER JOIN inserted I ON Iq.ID_Inquilino = I.ID_Inquilino;
END;
GO


--TRIGGER PAGOS

CREATE OR ALTER TRIGGER bda.trgCifrarPagos
ON bda.Pagos
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @passphrase NVARCHAR(128) = 'AltosDeSaintJust#2024';

    UPDATE P
    SET 
        cta_origen_enc = ENCRYPTBYPASSPHRASE(@passphrase, CONVERT(VARCHAR(50), I.cta_origen)),
        cta_origen = NULL
    FROM bda.Pagos P
    INNER JOIN inserted I ON P.id_pago = I.id_pago;
END;
GO

select * from bda.Inquilino

CREATE OR ALTER VIEW bda.vwPropietarioDescifrado
AS
SELECT
    ID_Propietario,
    Nombre,
    Apellido,
    CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', DNI_enc))      AS DNI,
    CONVERT(VARCHAR(60), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', Email_enc))    AS Email,
    CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', Telefono_enc)) AS Telefono,
    CVU_CBU,        -- queda el valor original (se mantiene por el FK)
    CVU_CBU_enc     -- por si querés inspeccionar el cifrado
FROM bda.Propietario;
GO

CREATE OR ALTER VIEW bda.vwInquilinoDescifrado
AS
SELECT
    ID_Inquilino,
    Nombre,
    Apellido,
    CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', DNI_enc))      AS DNI,
    CONVERT(VARCHAR(60), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', Email_enc))    AS Email,
    CONVERT(VARCHAR(20), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', Telefono_enc)) AS Telefono,
    CVU_CBU,
    CVU_CBU_enc
FROM bda.Inquilino;
GO

CREATE OR ALTER VIEW bda.vwPagosDescifrados
AS
SELECT
    id_pago,
    fecha_pago,
    importe,
    asociado,
    id_unidad,
    CONVERT(VARCHAR(50), DECRYPTBYPASSPHRASE('AltosDeSaintJust#2024', cta_origen_enc)) AS cta_origen_descifrada,
    cta_origen         -- el valor original sigue existiendo porque es NOT NULL
FROM bda.Pagos;
GO

SELECT * FROM bda.vwPropietarioDescifrado;
SELECT * FROM bda.vwInquilinoDescifrado;
SELECT * FROM bda.vwPagosDescifrados;