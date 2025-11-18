/* =========================================================
    09_EjecucionSPCifradoYDescifrado.sql - Com2900G13
    Proyecto: Altos de Saint Just
    Materia: Bases de Datos Aplicada
    Grupo: 13

    Este SP ejecuta los SP de cifrado y descifrado

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

------------------------------ CIFRADO DE DATOS SENSIBLES -----------------------------

EXEC bda.spCifrarDatosSensibles;
SELECT * FROM bda.Inquilino;

------------------------------ DESCIFRADO DE DATOS SENSIBLES -----------------------------

SELECT * FROM bda.vwPropietarioDescifrado;
SELECT * FROM bda.vwInquilinoDescifrado;
SELECT * FROM bda.vwPagosDescifrados;