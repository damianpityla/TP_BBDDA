/* =========================================================
	02_CreacionSPAlta.sql - Com2900G13
	Proyecto: Altos de Saint Just
    Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea los SP para dar de alta registros

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

CREATE OR ALTER PROCEDURE bda.spAltaGastoExtraordinario
	@IdConsorcio INT,
	@Mes TINYINT,
	@Descripcion VARCHAR(100),
	@Importe DECIMAL(18,2)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No existe el ID de consorcio ingresado.', 16, 1);
            RETURN;
        END

		IF @Mes <= 0 OR @Mes > 12
		BEGIN
			RAISERROR('El mes ingresado no es válido (debe ser 1-12).', 16, 1);
            RETURN;
		END

		IF @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-Z ]%' OR LEN(@Descripcion) > 100
		BEGIN
			RAISERROR('La descripción no es válida (solo letras y espacios, máximo 100 caracteres).', 16, 1);
            RETURN;
		END

		IF @Importe <= 0
		BEGIN
			RAISERROR('El importe debe ser mayor a 0.', 16, 1);
            RETURN;
		END

		BEGIN TRANSACTION;
            INSERT INTO bda.Gastos_Extraordinarios(id_consorcio, mes, descripcion, importe)
            VALUES (@IdConsorcio, @Mes, @Descripcion, @Importe);
        COMMIT TRANSACTION;

		PRINT('El gasto extraordinario ha sido insertado correctamente.');
	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaGastosOrdinarios
	@IdConsorcio INT,
	@Mes TINYINT,
	@ImporteBancario DECIMAL(18,2),
	@ImporteLimpieza DECIMAL(18,2),
	@ImporteAdministracion DECIMAL(18,2),
	@ImporteSeguros DECIMAL(18,2),
	@ImporteGastosGenerales DECIMAL(18,2),
	@ImporteAgua DECIMAL(18,2),
	@ImporteLuz DECIMAL(18,2)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No existe el ID de consorcio ingresado.', 16, 1);
            RETURN;
        END

		IF @Mes <= 0 OR @Mes > 12
		BEGIN
			RAISERROR('El mes ingresado no es válido (debe ser 1-12).', 16, 1);
            RETURN;
		END

		BEGIN TRANSACTION;

        INSERT INTO bda.Gastos_Ordinarios(id_consorcio, mes, tipo_gasto, importe)
        SELECT @IdConsorcio,@Mes,TipoGasto,Importe
        FROM(
			VALUES
				('Bancario',@ImporteBancario),
				('Limpieza',@ImporteLimpieza),
				('Administración',@ImporteAdministracion),
				('Seguros',@ImporteSeguros),
				('Gastos Generales',@ImporteGastosGenerales),
				('Agua',@ImporteAgua),
				('Luz',@ImporteLuz)
        ) AS G(TipoGasto,Importe)
        WHERE Importe > 0;

        COMMIT TRANSACTION;

		PRINT('Los gastos ordinarios han sido insertados correctamente.');
	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaConsorcio
    @Nombre VARCHAR(80),
    @Direccion VARCHAR(120),
    @CantUF INT,
    @M2Totales INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validaciones
        IF LEN(@Nombre) = 0 OR LEN(@Nombre) > 80
            RAISERROR('El nombre del consorcio es inválido (longitud 1-80).', 16, 1);

        IF LEN(@Direccion) = 0 OR LEN(@Direccion) > 120
            RAISERROR('La dirección es inválida (longitud 1-120).', 16, 1);

        IF @CantUF <= 0
            RAISERROR('La cantidad de unidades funcionales debe ser mayor a 0.', 16, 1);

        IF @M2Totales <= 0
            RAISERROR('Los metros cuadrados totales deben ser mayores a 0.', 16, 1);

        -- Inserción
        BEGIN TRANSACTION;

            INSERT INTO bda.Consorcio (nombre, direccion, cant_unidades_func, m2_totales)
            VALUES (@Nombre, @Direccion, @CantUF, @M2Totales);

        COMMIT TRANSACTION;

        PRINT('El consorcio ha sido insertado correctamente.');
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaUnidadFuncional
    @IdConsorcio INT,
    @NumeroUnidad TINYINT,
    @Piso VARCHAR(2),
    @Depto CHAR(1),
    @M2_UF TINYINT,
    @Porcentaje DECIMAL(4,1),
    @Baulera BIT,
    @M2_Baulera TINYINT,
    @Cochera BIT,
    @M2_Cochera TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio no existe.', 16, 1);

        IF @NumeroUnidad <= 0
            RAISERROR('Número de unidad inválido.', 16, 1);

        IF LEN(@Piso) = 0 OR LEN(@Piso) > 2
            RAISERROR('Piso inválido.', 16, 1);

        IF LEN(@Depto) <> 1
            RAISERROR('Depto inválido.', 16, 1);

        IF @M2_UF <= 0
            RAISERROR('Los m2 de la unidad deben ser mayores a 0.', 16, 1);

        IF @Porcentaje <= 0
            RAISERROR('El porcentaje debe ser mayor a 0.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Unidad_Funcional
                (id_consorcio, numero_unidad, piso, depto, m2_unidad_funcional, porcentaje, baulera, m2_baulera, cochera, m2_cochera)
            VALUES
                (@IdConsorcio, @NumeroUnidad, @Piso, @Depto, @M2_UF, @Porcentaje, @Baulera, @M2_Baulera, @Cochera, @M2_Cochera);

        COMMIT TRANSACTION;

        PRINT('Unidad funcional insertada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaBaulera
    @IdUF INT,
    @Importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional no existe.', 16, 1);

        IF @Importe <= 0
            RAISERROR('Importe inválido.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Baulera(id_uf, importe)
            VALUES (@IdUF, @Importe);

        COMMIT TRANSACTION;

        PRINT('Baulera insertada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaCochera
    @IdUF INT,
    @Importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional no existe.', 16, 1);

        IF @Importe <= 0
            RAISERROR('Importe inválido.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Cochera(id_uf, importe)
            VALUES (@IdUF, @Importe);

        COMMIT TRANSACTION;

        PRINT('Cochera insertada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaPropietario
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @DNI VARCHAR(15),
    @Email VARCHAR(60),
    @Telefono VARCHAR(15),
    @CVU_CBU VARCHAR(22)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validaciones básicas
        IF LEN(@Nombre) = 0 OR LEN(@Nombre) > 30
            RAISERROR('Nombre inválido.', 16, 1);

        IF LEN(@Apellido) = 0 OR LEN(@Apellido) > 30
            RAISERROR('Apellido inválido.', 16, 1);

        IF LEN(@DNI) = 0 OR LEN(@DNI) > 15
            RAISERROR('DNI inválido.', 16, 1);

        IF LEN(@Email) > 60
            RAISERROR('Email demasiado largo.', 16, 1);

        IF LEN(@Telefono) > 15
            RAISERROR('Teléfono demasiado largo.', 16, 1);

        IF LEN(@CVU_CBU) = 0 OR LEN(@CVU_CBU) > 22
            RAISERROR('CVU/CBU inválido.', 16, 1);

        IF EXISTS (SELECT 1 FROM bda.Propietario WHERE CVU_CBU = @CVU_CBU)
            RAISERROR('El CVU/CBU ya está registrado.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Propietario (Nombre, Apellido, DNI, Email, Telefono, CVU_CBU)
            VALUES (@Nombre, @Apellido, @DNI, @Email, @Telefono, @CVU_CBU);

        COMMIT TRANSACTION;

        PRINT('Propietario insertado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaInquilino
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @DNI VARCHAR(15),
    @Email VARCHAR(60),
    @Telefono VARCHAR(15),
    @CVU_CBU VARCHAR(22)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF LEN(@Nombre) = 0 OR LEN(@Nombre) > 30
            RAISERROR('Nombre inválido.', 16, 1);

        IF LEN(@Apellido) = 0 OR LEN(@Apellido) > 30
            RAISERROR('Apellido inválido.', 16, 1);

        IF LEN(@DNI) = 0 OR LEN(@DNI) > 15
            RAISERROR('DNI inválido.', 16, 1);

        IF LEN(@Email) > 60
            RAISERROR('Email demasiado largo.', 16, 1);

        IF LEN(@Telefono) > 15
            RAISERROR('Teléfono demasiado largo.', 16, 1);

        IF LEN(@CVU_CBU) = 0 OR LEN(@CVU_CBU) > 22
            RAISERROR('CVU/CBU inválido.', 16, 1);

        IF EXISTS (SELECT 1 FROM bda.Inquilino WHERE CVU_CBU = @CVU_CBU)
            RAISERROR('El CVU/CBU ya está registrado.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Inquilino (Nombre, Apellido, DNI, Email, Telefono, CVU_CBU)
            VALUES (@Nombre, @Apellido, @DNI, @Email, @Telefono, @CVU_CBU);

        COMMIT TRANSACTION;

        PRINT('Inquilino insertado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaPropietarioEnUF
    @CVU_CBU_Propietario VARCHAR(22),
    @IdConsorcio INT,
    @NumeroUF INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdUF INT;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Propietario WHERE CVU_CBU = @CVU_CBU_Propietario)
            RAISERROR('El propietario no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_consorcio = @IdConsorcio AND numero_unidad = @NumeroUF)
            RAISERROR('La unidad funcional no existe.', 16, 1);

        BEGIN TRANSACTION;

            SELECT @IdUF = id_unidad FROM bda.Unidad_Funcional WHERE id_consorcio = @IdConsorcio AND numero_unidad = @NumeroUF
            INSERT INTO bda.Propietario_en_UF (CVU_CBU_Propietario, ID_UF)
            VALUES (@CVU_CBU_Propietario, @IdUF);

        COMMIT TRANSACTION;

        PRINT('Propietario asignado correctamente a la UF.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaInquilinoEnUF
    @CVU_CBU_Inquilino VARCHAR(22),
    @IdConsorcio INT,
    @NumeroUF INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdUF INT;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Inquilino WHERE CVU_CBU = @CVU_CBU_Inquilino)
            RAISERROR('El inquilino no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_consorcio = @IdConsorcio AND numero_unidad = @NumeroUF)
            RAISERROR('La unidad funcional no existe.', 16, 1);

        BEGIN TRANSACTION;

            SELECT @IdUF = id_unidad FROM bda.Unidad_Funcional WHERE id_consorcio = @IdConsorcio AND numero_unidad = @NumeroUF
            INSERT INTO bda.Inquilino_en_UF (CVU_CBU_Inquilino, ID_UF)
            VALUES (@CVU_CBU_Inquilino, @IdUF);

        COMMIT TRANSACTION;

        PRINT('Inquilino asignado correctamente a la UF.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE bda.spAltaProveedor
    @Servicio VARCHAR(30),
    @Descripcion VARCHAR(100),
    @Cuenta VARCHAR(30),
    @IdConsorcio INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF LEN(@Servicio) = 0 OR LEN(@Servicio) > 30
            RAISERROR('Servicio inválido.', 16, 1);

        IF LEN(@Descripcion) = 0 OR LEN(@Descripcion) > 100
            RAISERROR('Descripción inválida.', 16, 1);

        IF LEN(@Cuenta) > 30
            RAISERROR('Cuenta demasiado larga.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio ingresado no existe.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Proveedor(servicio, descripcion, cuenta, ID_Consorcio)
            VALUES (@Servicio, @Descripcion, @Cuenta, @IdConsorcio);

        COMMIT TRANSACTION;

        PRINT('Proveedor insertado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE bda.spAltaPago
    @IdPago INT,
    @FechaPago DATE,
    @CtaOrigen VARCHAR(22),
    @Importe DECIMAL(18,2),
    @Asociado BIT,
    @IdUnidad INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Importe <= 0
            RAISERROR('El importe debe ser mayor a 0.', 16, 1);

        IF LEN(@CtaOrigen) = 0 OR LEN(@CtaOrigen) > 22
            RAISERROR('Cuenta origen inválida.', 16, 1);

        IF @IdUnidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUnidad)
            RAISERROR('Unidad funcional inexistente.', 16, 1);

        BEGIN TRANSACTION;

            INSERT INTO bda.Pagos(id_pago, fecha_pago, cta_origen, importe, asociado, id_unidad)
            VALUES (@IdPago, @FechaPago, @CtaOrigen, @Importe, @Asociado, @IdUnidad);

        COMMIT TRANSACTION;

        PRINT('Pago insertado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO