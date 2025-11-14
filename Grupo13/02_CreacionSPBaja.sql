/* =========================================================
	02_CreacionSPBaja.sql - Com2900G13
	Proyecto: Altos de Saint Just
    Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea los SP para dar de de baja registros

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

------------------------


CREATE OR ALTER PROCEDURE bda.spBajaConsorcio
    @IdConsorcio INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Consorcio WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No existe el consorcio indicado.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No se puede borrar el consorcio porque tiene unidades funcionales asociadas.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Proveedor WHERE ID_Consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No se puede borrar el consorcio porque tiene proveedores asociados.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Expensa WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No se puede borrar el consorcio porque tiene expensas asociadas.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Gastos_Ordinarios WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No se puede borrar el consorcio porque tiene gastos ordinarios asociados.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Gastos_Extraordinarios WHERE id_consorcio = @IdConsorcio)
        BEGIN
            RAISERROR('No se puede borrar el consorcio porque tiene gastos extraordinarios asociados.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Consorcio
            WHERE id_consorcio = @IdConsorcio;

        COMMIT TRANSACTION;

        PRINT('Consorcio eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaUnidadFuncional
    @IdUF INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Unidad_Funcional WHERE id_unidad = @IdUF)
        BEGIN
            RAISERROR('No existe la unidad funcional indicada.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Baulera WHERE id_uf = @IdUF)
        BEGIN
            RAISERROR('No se puede borrar la unidad funcional porque tiene bauleras asociadas.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Cochera WHERE id_uf = @IdUF)
        BEGIN
            RAISERROR('No se puede borrar la unidad funcional porque tiene cocheras asociadas.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Propietario_en_UF WHERE ID_UF = @IdUF)
        BEGIN
            RAISERROR('No se puede borrar la unidad funcional porque tiene propietarios asociados.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Inquilino_en_UF WHERE ID_UF = @IdUF)
        BEGIN
            RAISERROR('No se puede borrar la unidad funcional porque tiene inquilinos asociados.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Pagos WHERE id_unidad = @IdUF)
        BEGIN
            RAISERROR('No se puede borrar la unidad funcional porque tiene pagos asociados.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Detalle_Expensa WHERE id_uf = @IdUF)
        BEGIN
            RAISERROR('No se puede borrar la unidad funcional porque tiene detalles de expensa asociados.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Unidad_Funcional
            WHERE id_unidad = @IdUF;

        COMMIT TRANSACTION;

        PRINT('Unidad funcional eliminada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE bda.spBajaBaulera
    @IdBaulera INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Baulera WHERE id_baulera = @IdBaulera)
        BEGIN
            RAISERROR('No existe la baulera indicada.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Baulera
            WHERE id_baulera = @IdBaulera;

        COMMIT TRANSACTION;

        PRINT('Baulera eliminada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE bda.spBajaCochera
    @IdCochera INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Cochera WHERE id_cochera = @IdCochera)
        BEGIN
            RAISERROR('No existe la cochera indicada.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Cochera
            WHERE id_cochera = @IdCochera;

        COMMIT TRANSACTION;

        PRINT('Cochera eliminada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaPropietario
    @IdPropietario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Propietario WHERE ID_Propietario = @IdPropietario)
        BEGIN
            RAISERROR('No existe el propietario indicado.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Propietario_en_UF WHERE CVU_CBU_Propietario = (SELECT CVU_CBU FROM bda.Propietario WHERE ID_Propietario = @IdPropietario))
        BEGIN
            RAISERROR('No se puede borrar el propietario porque esta asociado a una unidad funcional.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Propietario
            WHERE ID_Propietario = @IdPropietario;

        COMMIT TRANSACTION;

        PRINT('Propietario eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaInquilino
    @IdInquilino INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Inquilino WHERE ID_Inquilino = @IdInquilino)
        BEGIN
            RAISERROR('No existe el inquilino indicado.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Inquilino_en_UF WHERE CVU_CBU_Inquilino = (SELECT CVU_CBU FROM bda.Inquilino WHERE ID_Inquilino = @IdInquilino))
        BEGIN
            RAISERROR('No se puede borrar el inquilino porque esta asociado a una unidad funcional.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Inquilino
            WHERE ID_Inquilino = @IdInquilino;

        COMMIT TRANSACTION;

        PRINT('Inquilino eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaPropietarioEnUF
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Propietario_en_UF WHERE ID = @Id)
        BEGIN
            RAISERROR('No existe la relacion propietario en unidad funcional indicada.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Propietario_en_UF
            WHERE ID = @Id;

        COMMIT TRANSACTION;

        PRINT('Relacion propietario en unidad funcional eliminada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaInquilinoEnUF
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Inquilino_en_UF WHERE ID = @Id)
        BEGIN
            RAISERROR('No existe la relacion inquilino en unidad funcional indicada.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Inquilino_en_UF
            WHERE ID = @Id;

        COMMIT TRANSACTION;

        PRINT('Relacion inquilino en unidad funcional eliminada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaProveedor
    @IdProveedor INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Proveedor WHERE id_proveedor = @IdProveedor)
        BEGIN
            RAISERROR('No existe el proveedor indicado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Proveedor
            WHERE id_proveedor = @IdProveedor;

        COMMIT TRANSACTION;

        PRINT('Proveedor eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaExpensa
    @IdExpensa INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Expensa WHERE id_expensa = @IdExpensa)
        BEGIN
            RAISERROR('No existe la expensa indicada.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Detalle_Expensa WHERE id_expensa = @IdExpensa)
        BEGIN
            RAISERROR('No se puede borrar la expensa porque tiene detalles asociados.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Estado_Financiero WHERE id_expensa = @IdExpensa)
        BEGIN
            RAISERROR('No se puede borrar la expensa porque tiene estado financiero asociado.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Pagos WHERE id_expensa = @IdExpensa)
        BEGIN
            RAISERROR('No se puede borrar la expensa porque tiene pagos asociados.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Expensa
            WHERE id_expensa = @IdExpensa;

        COMMIT TRANSACTION;

        PRINT('Expensa eliminada correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaDetalleExpensa
    @IdDetalle INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Detalle_Expensa WHERE id_detalle = @IdDetalle)
        BEGIN
            RAISERROR('No existe el detalle de expensa indicado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Detalle_Expensa
            WHERE id_detalle = @IdDetalle;

        COMMIT TRANSACTION;

        PRINT('Detalle de expensa eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO




CREATE OR ALTER PROCEDURE bda.spBajaEstadoFinanciero
    @IdEstado INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Estado_Financiero WHERE id_estado = @IdEstado)
        BEGIN
            RAISERROR('No existe el estado financiero indicado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Estado_Financiero
            WHERE id_estado = @IdEstado;

        COMMIT TRANSACTION;

        PRINT('Estado financiero eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaGastoOrdinario
    @IdGastoOrdinario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Gastos_Ordinarios WHERE id_gasto_ordinario = @IdGastoOrdinario)
        BEGIN
            RAISERROR('No existe el gasto ordinario indicado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Gastos_Ordinarios
            WHERE id_gasto_ordinario = @IdGastoOrdinario;

        COMMIT TRANSACTION;

        PRINT('Gasto ordinario eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE bda.spBajaGastoExtraordinario
    @IdGastoExtraordinario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Gastos_Extraordinarios WHERE id_gasto_extraordinario = @IdGastoExtraordinario)
        BEGIN
            RAISERROR('No existe el gasto extraordinario indicado.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Gastos_Extraordinarios
            WHERE id_gasto_extraordinario = @IdGastoExtraordinario;

        COMMIT TRANSACTION;

        PRINT('Gasto extraordinario eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO





CREATE OR ALTER PROCEDURE bda.spBajaPago
    @IdPago INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM bda.Pagos WHERE id_pago = @IdPago)
        BEGIN
            RAISERROR('No existe el pago indicado.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM bda.Detalle_Expensa WHERE id_pago = @IdPago)
        BEGIN
            RAISERROR('No se puede borrar el pago porque esta asociado a un detalle de expensa.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            DELETE FROM bda.Pagos
            WHERE id_pago = @IdPago;

        COMMIT TRANSACTION;

        PRINT('Pago eliminado correctamente.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT('Error: ' + ERROR_MESSAGE());
    END CATCH
END
GO