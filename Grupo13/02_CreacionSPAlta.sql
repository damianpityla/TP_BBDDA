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