CREATE SCHEMA M5AUTOMOTORES;
USE M5AUTOMOTORES;

CREATE TABLE CLIENTES(
	CLIENT_ID INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    NOMBRE VARCHAR(20) NOT NULL,
    APELLIDO VARCHAR(30) NOT NULL,
    DNI INT NOT NULL UNIQUE,
	TELEFONO VARCHAR(30) UNIQUE,
    MAIL VARCHAR(50) UNIQUE
);
    
CREATE TABLE MODELOS(
	MODEL_ID INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    MODELO VARCHAR(30) NOT NULL,
    VERSION VARCHAR(50)
);
    
CREATE TABLE VEHICULOS(
	VEHICLE_ID INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    PATENTE VARCHAR(20) NOT NULL UNIQUE,
    VIN CHAR(17) NOT NULL UNIQUE,
    PROD_DATE DATE,
    MODEL_ID INT NOT NULL,
	FOREIGN KEY (MODEL_ID) REFERENCES MODELOS (MODEL_ID)
);
    
CREATE TABLE CONCESIONARIOS(
	DLR_ID INT NOT NULL UNIQUE PRIMARY KEY,
    DLR_CODE CHAR(3) NOT NULL UNIQUE,
    CONCESIONARIO VARCHAR(50) NOT NULL
);

CREATE TABLE SUCURSALES(
	SUC_ID INT NOT NULL UNIQUE PRIMARY KEY,
    SUC_CODE CHAR(5) NOT NULL UNIQUE,
    SUCURSAL VARCHAR(20) NOT NULL,
    DIRECCION VARCHAR(50),
    DLR_ID INT NOT NULL,
	FOREIGN KEY (DLR_ID) REFERENCES CONCESIONARIOS (DLR_ID)
);

CREATE TABLE INSUMOS(
	PART_ID INT NOT NULL UNIQUE PRIMARY KEY,
    PART_CODE CHAR(10) NOT NULL UNIQUE,
    PART VARCHAR(30),
    COST_PARTS DECIMAL NOT NULL
);

CREATE TABLE TIPO_DE_SERVICIO(
	SERVICE_TYPE_ID INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    SERVICE_TYPE VARCHAR(30) NOT NULL UNIQUE,
    COST_MO DECIMAL NOT NULL
);

CREATE TABLE ORDEN_DE_TRABAJO(
	OR_ID INT NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    CLIENT_ID INT NOT NULL,
    PART_ID INT NOT NULL,
    SUC_ID INT NOT NULL,
	VEHICLE_ID INT NOT NULL,
	SERVICE_TYPE_ID INT NOT NULL,
    OR_NUMBER INT NOT NULL,
    OPEN_DATE DATE NOT NULL,
    CLOSE_DATE DATE NOT NULL,
    SERVICE_DESCRIPTION VARCHAR(300),
    CANT_PARTS INT NOT NULL,
    HS_MO DECIMAL NOT NULL,
    FOREIGN KEY (PART_ID) REFERENCES INSUMOS (PART_ID),
    FOREIGN KEY (SUC_ID) REFERENCES SUCURSALES (SUC_ID),
    FOREIGN KEY (VEHICLE_ID) REFERENCES VEHICULOS (VEHICLE_ID),
    FOREIGN KEY (SERVICE_TYPE_ID) REFERENCES TIPO_DE_SERVICIO (SERVICE_TYPE_ID),
	FOREIGN KEY (CLIENT_ID) REFERENCES CLIENTES (CLIENT_ID)
);