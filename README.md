# TP_BBDDA

CREATE TABLE Consorcio (
    id_consorcio INT IDENTITY (1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(50),
    cuit VARCHAR(15),
    telefono VARCHAR(20)
);


