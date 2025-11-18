/* =========================================================
	05_CreacionIndicesReportes.sql - Com2900G13
	Proyecto: Altos de Saint Just
    Materia: Bases de datos aplicada
    Grupo: 13

	Este archivo crea los indices para optimizar la consulta de reportes

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

CREATE INDEX IX_Pagos_IDUnidad_FechaPago ON bda.Pagos (id_unidad, fecha_pago) INCLUDE (importe);							--JOIN CON TABLA DE UF Y FILTRO POR MES DE PAGO
CREATE INDEX IX_UF_Consorcio_Unidad ON bda.Unidad_Funcional (id_unidad, id_consorcio);										--JOIN CON TABLA DE CONSORCIO
CREATE INDEX IX_Consorcio_Nombre ON bda.Consorcio (nombre) INCLUDE (id_consorcio);											--FILTRO POR NOMBRE DE CONSORCIO
CREATE INDEX IX_GastosOrdinarios_Consorcio_Mes ON bda.Gastos_Ordinarios (id_consorcio, mes) INCLUDE (importe);				--JOIN CON TABLA DE GASTOS ORDINARIOS Y FILTRO POR MES
CREATE INDEX IX_GastosExtraordinarios_Consorcio_Mes ON bda.Gastos_Extraordinarios (id_consorcio, mes) INCLUDE (importe);	--JOIN CON TABLA DE GASTOS EXTRAORDINARIOS Y FILTRO POR MES

------------------------------ Reporte 2  -----------------------------

CREATE INDEX IX_UF_Consorcio_Piso_Depto ON bda.Unidad_Funcional (id_consorcio, piso, depto) INCLUDE (id_unidad);			--FILTRO POR ID CONSORCIO Y ORDENO POR PISO Y DEPTO
--CREATE INDEX IX_Pagos_IDUnidad_FechaPago ON bda.Pagos (id_unidad, fecha_pago) INCLUDE (importe);							--JOIN CON TABLA DE UF Y FILTRO POR MES DE PAGO

------------------------------ Reporte 3  -----------------------------

--CREATE INDEX IX_UF_Consorcio_Unidad ON bda.Unidad_Funcional (id_unidad, id_consorcio);																		--JOIN CON TABLA DE CONSORCIO
--CREATE INDEX IX_Consorcio_Nombre ON bda.Consorcio (nombre) INCLUDE (id_consorcio);																			--FILTRO POR NOMBRE DE CONSORCIO
CREATE INDEX IX_Expensa_Consorcio_Mes ON bda.Expensa (id_consorcio, mes) INCLUDE (id_expensa);																	--JOIN CON TABLA EXPENSA Y FILTRO POR MES
CREATE INDEX IX_DetalleExpensa_IdExpensa ON bda.Detalle_Expensa (id_expensa) INCLUDE (valor_ordinarias, valor_extraordinarias, valor_baulera, valor_cochera);	--JOIN CON TABLA DETALLE_EXPENSA

------------------------------ Reporte 4  -----------------------------

--CREATE INDEX IX_UF_Consorcio_Unidad ON bda.Unidad_Funcional (id_consorcio, id_unidad);										--JOIN CON TABLA DE UF Y FILTRO POR ID_CONSORCIO
--CREATE INDEX IX_GastosOrdinarios_Consorcio_Mes ON bda.Gastos_Ordinarios (id_consorcio, mes) INCLUDE (importe);				--AGRUPO POR MES
--CREATE INDEX IX_GastosExtraordinarios_Consorcio_Mes ON bda.Gastos_Extraordinarios (id_consorcio, mes) INCLUDE (importe);		--AGRUPO POR MES

------------------------------ Reporte 5  -----------------------------

CREATE INDEX IX_DetalleExpensa_IdUF_Deuda ON bda.Detalle_Expensa (id_uf) INCLUDE (deuda);										--JOIN CON TABLA DETALLE_EXPENSA Y ORDER BY POR DEUDA
CREATE INDEX IX_PropietarioEnUF_IdUF ON bda.Propietario_en_UF (id_uf) INCLUDE (CVU_CBU_Propietario);							--JOIN CON PROPIETARIO EN UF
CREATE INDEX IX_InquilinoEnUF_IdUF ON bda.Inquilino_en_UF (id_uf) INCLUDE (CVU_CBU_Inquilino);									--JOIN CON INQUILINO EN UF
CREATE INDEX IX_Propietario_CVU_Nombre_Apellido ON bda.Propietario (CVU_CBU) INCLUDE (Nombre, Apellido, DNI, Email, Telefono);	--JOIN CON PROPIETARIO
CREATE INDEX IX_Inquilino_CVU_Nombre_Apellido ON bda.Inquilino (CVU_CBU) INCLUDE (Nombre, Apellido, DNI, Email, Telefono);		--JOIN CON INQUILINO
CREATE INDEX IX_UF_Unidad_Consorcio ON bda.Unidad_Funcional (id_unidad) INCLUDE (id_consorcio, numero_unidad);					--FILTRO POR NOMBRE DEL CONSORCIO
--CREATE INDEX IX_Consorcio_Nombre ON bda.Consorcio (nombre) INCLUDE (id_consorcio);

------------------------------ Reporte 6  -----------------------------

CREATE INDEX IX_Pagos_CtaOrigen_Fecha ON bda.Pagos (cta_origen, fecha_pago) INCLUDE (importe);									--FILTRO POR FECHA DE PAGO
CREATE INDEX IX_PropietarioEnUF_CVU ON bda.Propietario_en_UF (CVU_CBU_Propietario) INCLUDE (ID_UF);								--JOIN CON PROPIETARIO EN UF
CREATE INDEX IX_InquilinoEnUF_CVU ON bda.Inquilino_en_UF (CVU_CBU_Inquilino) INCLUDE (ID_UF);									--JOIN CON INQUILINO EN UF
CREATE INDEX IX_UF_IdUnidad_Consorcio ON bda.Unidad_Funcional (id_unidad) INCLUDE (id_consorcio, piso, depto);					--JOIN CON UF Y FILTRO POR ID_CONSORCIO