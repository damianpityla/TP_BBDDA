/* =========================================================
	02_CreacionSPModificacion.sql - Com2900G13
	Proyecto: Altos de Saint Just
    Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea los SP para modificar registros

	Alumnos:
		45628269 - Liber Federico Manuel 
		46265307 - Ares Nicolás jesús 
		45754471 - Pityla Damian 
		42587858 - Murillo Joel
		46292592 - Larriba Pedro Ezequiel 
		40464246 - Diaz Ortiz  Lucas Javier 
========================================================= */

CREATE OR ALTER PROCEDURE bda.spModificacionConsorcio
    @IdConsorcio INT,
    @Nombre VARCHAR(80),
    @Direccion VARCHAR(120),
    @CantUF INT,
    @M2Totales INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No existe el consorcio indicado.', 16, 1);
            RETURN;
        END

        IF LEN(@Nombre) = 0 OR LEN(@Nombre) > 80
            RAISERROR('Nombre invalido.', 16, 1);

        IF LEN(@Direccion) = 0 OR LEN(@Direccion) > 120
            RAISERROR('Direccion invalida.', 16, 1);

        IF @CantUF <= 0
            RAISERROR('La cantidad de unidades funcionales debe ser mayor a 0.', 16, 1);

        IF @M2Totales <= 0
            RAISERROR('Los metros cuadrados totales deben ser mayores a 0.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Consorcio
            SET nombre = @Nombre,
                direccion = @Direccion,
                cant_unidades_func = @CantUF,
                m2_totales = @M2Totales
            WHERE id_consorcio = @IdConsorcio;

        COMMIT TRANSACTION;

        PRINT('Consorcio modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionUnidadFuncional
    @IdUF INT,
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
        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
        BEGIN
            RAISERROR('No existe la unidad funcional indicada.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio indicado no existe.', 16, 1);

        IF @NumeroUnidad <= 0
            RAISERROR('Numero de unidad invalido.', 16, 1);

        IF LEN(@Piso) = 0 OR LEN(@Piso) > 2
            RAISERROR('Piso invalido.', 16, 1);

        IF LEN(@Depto) <> 1
            RAISERROR('Depto invalido.', 16, 1);

        IF @M2_UF <= 0
            RAISERROR('Metros cuadrados de la unidad invalidos.', 16, 1);

        IF @Porcentaje <= 0
            RAISERROR('Porcentaje invalido.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Unidad_Funcional
            SET id_consorcio = @IdConsorcio,
                numero_unidad = @NumeroUnidad,
                piso = @Piso,
                depto = @Depto,
                m2_unidad_funcional = @M2_UF,
                porcentaje = @Porcentaje,
                baulera = @Baulera,
                m2_baulera = @M2_Baulera,
                cochera = @Cochera,
                m2_cochera = @M2_Cochera
            WHERE id_unidad = @IdUF;

        COMMIT TRANSACTION;

        PRINT('Unidad funcional modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionBaulera
    @IdBaulera INT,
    @IdUF INT,
    @Importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Baulera WHERE id_baulera = @IdBaulera)
        BEGIN
            RAISERROR('No existe la baulera indicada.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional indicada no existe.', 16, 1);

        IF @Importe <= 0
            RAISERROR('Importe invalido.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Baulera
            SET id_uf = @IdUF,
                importe = @Importe
            WHERE id_baulera = @IdBaulera;

        COMMIT TRANSACTION;

        PRINT('Baulera modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionCochera
    @IdCochera INT,
    @IdUF INT,
    @Importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Cochera WHERE id_cochera = @IdCochera)
        BEGIN
            RAISERROR('No existe la cochera indicada.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional indicada no existe.', 16, 1);

        IF @Importe <= 0
            RAISERROR('Importe invalido.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Cochera
            SET id_uf = @IdUF,
                importe = @Importe
            WHERE id_cochera = @IdCochera;

        COMMIT TRANSACTION;

        PRINT('Cochera modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionPropietario
    @IdPropietario INT,
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
        IF NOT EXISTS (SELECT 1 FROM bda.Propietario WHERE ID_Propietario = @IdPropietario)
        BEGIN
            RAISERROR('No existe el propietario indicado.', 16, 1);
            RETURN;
        END

        IF LEN(@Nombre) = 0 OR LEN(@Nombre) > 30
            RAISERROR('Nombre invalido.', 16, 1);

        IF LEN(@Apellido) = 0 OR LEN(@Apellido) > 30
            RAISERROR('Apellido invalido.', 16, 1);

        IF LEN(@DNI) = 0 OR LEN(@DNI) > 15
            RAISERROR('DNI invalido.', 16, 1);

        IF LEN(@Email) > 60
            RAISERROR('Email demasiado largo.', 16, 1);

        IF LEN(@Telefono) > 15
            RAISERROR('Telefono demasiado largo.', 16, 1);

        IF LEN(@CVU_CBU) = 0 OR LEN(@CVU_CBU) > 22
            RAISERROR('CVU CBU invalido.', 16, 1);

        IF EXISTS (SELECT 1 FROM bda.Propietario WHERE CVU_CBU = @CVU_CBU AND ID_Propietario <> @IdPropietario)
            RAISERROR('El CVU CBU ya esta registrado en otro propietario.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Propietario
            SET Nombre = @Nombre,
                Apellido = @Apellido,
                DNI = @DNI,
                Email = @Email,
                Telefono = @Telefono,
                CVU_CBU = @CVU_CBU
            WHERE ID_Propietario = @IdPropietario;

        COMMIT TRANSACTION;

        PRINT('Propietario modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionInquilino
    @IdInquilino INT,
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
        IF NOT EXISTS (SELECT 1 FROM bda.Inquilino WHERE ID_Inquilino = @IdInquilino)
        BEGIN
            RAISERROR('No existe el inquilino indicado.', 16, 1);
            RETURN;
        END

        IF LEN(@Nombre) = 0 OR LEN(@Nombre) > 30
            RAISERROR('Nombre invalido.', 16, 1);

        IF LEN(@Apellido) = 0 OR LEN(@Apellido) > 30
            RAISERROR('Apellido invalido.', 16, 1);

        IF LEN(@DNI) = 0 OR LEN(@DNI) > 15
            RAISERROR('DNI invalido.', 16, 1);

        IF LEN(@Email) > 60
            RAISERROR('Email demasiado largo.', 16, 1);

        IF LEN(@Telefono) > 15
            RAISERROR('Telefono demasiado largo.', 16, 1);

        IF LEN(@CVU_CBU) = 0 OR LEN(@CVU_CBU) > 22
            RAISERROR('CVU CBU invalido.', 16, 1);

        IF EXISTS (SELECT 1 FROM bda.Inquilino WHERE CVU_CBU = @CVU_CBU AND ID_Inquilino <> @IdInquilino)
            RAISERROR('El CVU CBU ya esta registrado en otro inquilino.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Inquilino
            SET Nombre = @Nombre,
                Apellido = @Apellido,
                DNI = @DNI,
                Email = @Email,
                Telefono = @Telefono,
                CVU_CBU = @CVU_CBU
            WHERE ID_Inquilino = @IdInquilino;

        COMMIT TRANSACTION;

        PRINT('Inquilino modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionPropietarioEnUF
    @Id INT,
    @CVU_CBU_Propietario VARCHAR(22),
    @IdUF INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Propietario_en_UF WHERE ID = @Id)
        BEGIN
            RAISERROR('No existe la relacion propietario en unidad funcional indicada.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Propietario WHERE CVU_CBU = @CVU_CBU_Propietario)
            RAISERROR('El propietario indicado no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional indicada no existe.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Propietario_en_UF
            SET CVU_CBU_Propietario = @CVU_CBU_Propietario,
                ID_UF = @IdUF
            WHERE ID = @Id;

        COMMIT TRANSACTION;

        PRINT('Relacion propietario en unidad funcional modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionInquilinoEnUF
    @Id INT,
    @CVU_CBU_Inquilino VARCHAR(22),
    @IdUF INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Inquilino_en_UF WHERE ID = @Id)
        BEGIN
            RAISERROR('No existe la relacion inquilino en unidad funcional indicada.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Inquilino WHERE CVU_CBU = @CVU_CBU_Inquilino)
            RAISERROR('El inquilino indicado no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional indicada no existe.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Inquilino_en_UF
            SET CVU_CBU_Inquilino = @CVU_CBU_Inquilino,
                ID_UF = @IdUF
            WHERE ID = @Id;

        COMMIT TRANSACTION;

        PRINT('Relacion inquilino en unidad funcional modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionProveedor
    @IdProveedor INT,
    @Servicio VARCHAR(30),
    @Descripcion VARCHAR(100),
    @Cuenta VARCHAR(30),
    @IdConsorcio INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Proveedor WHERE id_proveedor = @IdProveedor)
        BEGIN
            RAISERROR('No existe el proveedor indicado.', 16, 1);
            RETURN;
        END

        IF LEN(@Servicio) = 0 OR LEN(@Servicio) > 30
            RAISERROR('Servicio invalido.', 16, 1);

        IF LEN(@Descripcion) = 0 OR LEN(@Descripcion) > 100
            RAISERROR('Descripcion invalida.', 16, 1);

        IF @Cuenta IS NOT NULL AND LEN(@Cuenta) > 30
            RAISERROR('Cuenta demasiado larga.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio indicado no existe.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Proveedor
            SET servicio = @Servicio,
                descripcion = @Descripcion,
                cuenta = @Cuenta,
                ID_Consorcio = @IdConsorcio
            WHERE id_proveedor = @IdProveedor;

        COMMIT TRANSACTION;

        PRINT('Proveedor modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionExpensa
    @IdExpensa INT,
    @IdConsorcio INT,
    @Mes TINYINT,
    @FechaEmision DATE,
    @Venc1 DATE,
    @Venc2 DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Expensa WHERE id_expensa = @IdExpensa)
        BEGIN
            RAISERROR('No existe la expensa indicada.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio indicado no existe.', 16, 1);

        IF @Mes NOT BETWEEN 1 AND 12
            RAISERROR('Mes invalido.', 16, 1);

        IF @Venc2 <= @Venc1
            RAISERROR('El segundo vencimiento debe ser posterior al primero.', 16, 1);

        IF EXISTS (
            SELECT 1
            FROM bda.Expensa
            WHERE id_consorcio = @IdConsorcio
              AND mes = @Mes
              AND id_expensa <> @IdExpensa
        )
            RAISERROR('Ya existe una expensa para ese consorcio y mes.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Expensa
            SET id_consorcio = @IdConsorcio,
                mes = @Mes,
                fecha_emision = @FechaEmision,
                vencimiento1 = @Venc1,
                vencimiento2 = @Venc2
            WHERE id_expensa = @IdExpensa;

        COMMIT TRANSACTION;

        PRINT('Expensa modificada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionDetalleExpensa
    @IdDetalle INT,
    @IdExpensa INT,
    @IdUF INT,
    @Interes DECIMAL(18,2),
    @ValOrd DECIMAL(18,2),
    @ValExt DECIMAL(18,2),
    @ValBaul DECIMAL(18,2),
    @ValCoch DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Detalle_Expensa WHERE id_detalle = @IdDetalle)
        BEGIN
            RAISERROR('No existe el detalle de expensa indicado.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Expensa WHERE id_expensa = @IdExpensa)
            RAISERROR('La expensa indicada no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
            RAISERROR('La unidad funcional indicada no existe.', 16, 1);


        DECLARE @Total DECIMAL(18,2);
        SET @Total = @Interes + @ValOrd + @ValExt + @ValBaul + @ValCoch;

        BEGIN TRANSACTION;

            UPDATE bda.Detalle_Expensa
            SET id_expensa = @IdExpensa,
                id_uf = @IdUF,
                interes_por_mora = @Interes,
                valor_ordinarias = @ValOrd,
                valor_extraordinarias = @ValExt,
                valor_baulera = @ValBaul,
                valor_cochera = @ValCoch,
                total = @Total
            WHERE id_detalle = @IdDetalle;

        COMMIT TRANSACTION;

        PRINT('Detalle de expensa modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE bda.spModificacionEstadoFinanciero
    @IdEstado      INT,
    @IdExpensa     INT,
    @SaldoAnterior DECIMAL(18,2),
    @IngTermino    DECIMAL(18,2),
    @IngAdeudados  DECIMAL(18,2),
    @IngAdelantados DECIMAL(18,2),
    @EgresosMes    DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Estado_Financiero WHERE id_estado = @IdEstado)
        BEGIN
            RAISERROR('No existe el estado financiero indicado.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Expensa WHERE id_expensa = @IdExpensa)
            RAISERROR('La expensa indicada no existe.', 16, 1);

        IF EXISTS (
            SELECT 1
            FROM bda.Estado_Financiero
            WHERE id_expensa = @IdExpensa
              AND id_estado <> @IdEstado
        )
            RAISERROR('La expensa indicada ya tiene otro estado financiero.', 16, 1);

        DECLARE @IngresosMes DECIMAL(18,2),
                @SaldoCierre DECIMAL(18,2);

        SET @IngresosMes = ISNULL(@IngTermino,0)
                         + ISNULL(@IngAdeudados,0)
                         + ISNULL(@IngAdelantados,0);

        SET @SaldoCierre = ISNULL(@SaldoAnterior,0)
                         + @IngresosMes
                         - ISNULL(@EgresosMes,0);

        BEGIN TRANSACTION;

            UPDATE bda.Estado_Financiero
            SET id_expensa      = @IdExpensa,
                saldo_anterior  = @SaldoAnterior,
                ingresos_mes    = @IngresosMes,
                egresos_mes     = @EgresosMes,
                saldo_cierre    = @SaldoCierre
            WHERE id_estado = @IdEstado;

        COMMIT TRANSACTION;

        PRINT('Estado financiero modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionGastoOrdinario
    @IdGastoOrdinario INT,
    @IdConsorcio INT,
    @Mes TINYINT,
    @TipoGasto VARCHAR(100),
    @Importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Gastos_Ordinarios WHERE id_gasto_ordinario = @IdGastoOrdinario)
        BEGIN
            RAISERROR('No existe el gasto ordinario indicado.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio indicado no existe.', 16, 1);

        IF @Mes NOT BETWEEN 1 AND 12
            RAISERROR('Mes invalido.', 16, 1);

        IF LEN(@TipoGasto) = 0 OR LEN(@TipoGasto) > 100
            RAISERROR('Tipo de gasto invalido.', 16, 1);

        IF @Importe <= 0
            RAISERROR('Importe invalido.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Gastos_Ordinarios
            SET id_consorcio = @IdConsorcio,
                mes = @Mes,
                tipo_gasto = @TipoGasto,
                importe = @Importe
            WHERE id_gasto_ordinario = @IdGastoOrdinario;

        COMMIT TRANSACTION;

        PRINT('Gasto ordinario modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionGastoExtraordinario
    @IdGastoExtraordinario INT,
    @IdConsorcio INT,
    @Mes TINYINT,
    @Descripcion VARCHAR(100),
    @Importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Gastos_Extraordinarios WHERE id_gasto_extraordinario = @IdGastoExtraordinario)
        BEGIN
            RAISERROR('No existe el gasto extraordinario indicado.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
            RAISERROR('El consorcio indicado no existe.', 16, 1);

        IF @Mes NOT BETWEEN 1 AND 12
            RAISERROR('Mes invalido.', 16, 1);

        IF LEN(@Descripcion) = 0 OR LEN(@Descripcion) > 100
            RAISERROR('Descripcion invalida.', 16, 1);

        IF @Importe <= 0
            RAISERROR('Importe invalido.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Gastos_Extraordinarios
            SET id_consorcio = @IdConsorcio,
                mes = @Mes,
                descripcion = @Descripcion,
                importe = @Importe
            WHERE id_gasto_extraordinario = @IdGastoExtraordinario;

        COMMIT TRANSACTION;

        PRINT('Gasto extraordinario modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE bda.spModificacionPago
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
        IF NOT EXISTS (SELECT 1 FROM bda.Pagos WHERE id_pago = @IdPago)
        BEGIN
            RAISERROR('No existe el pago indicado.', 16, 1);
            RETURN;
        END

        IF @Importe <= 0
            RAISERROR('Importe invalido.', 16, 1);

        IF LEN(@CtaOrigen) = 0 OR LEN(@CtaOrigen) > 22
            RAISERROR('Cuenta origen invalida.', 16, 1);

        IF @IdUnidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUnidad)
            RAISERROR('Unidad funcional inexistente.', 16, 1);

        BEGIN TRANSACTION;

            UPDATE bda.Pagos
            SET fecha_pago = @FechaPago,
                cta_origen = @CtaOrigen,
                importe = @Importe,
                asociado = @Asociado,
                id_unidad = @IdUnidad
            WHERE id_pago = @IdPago;

        COMMIT TRANSACTION;

        PRINT('Pago modificado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH;
END
GO