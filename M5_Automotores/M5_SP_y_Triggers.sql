use m5automotores;

-- STORED PROCEDURES
-- SP para insercion de ordenes de trabajo con datos correctos
DELIMITER $$

CREATE PROCEDURE sp_insert_or (
    IN client_id INT,
    IN part_id INT,
    IN suc_id INT,
    IN vin_value CHAR(17),
    IN service_type_id INT,
    IN or_number INT,
    IN open_date DATE,
    IN close_date DATE,
    IN service_description VARCHAR(300),
    IN cant_parts INT,
    IN hs_mo DECIMAL
)
BEGIN
    DECLARE vin_id INT;
    DECLARE err_message VARCHAR(255);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
		BEGIN
		-- ERROR, WARNING
		ROLLBACK;
	END;
  START TRANSACTION;
    -- Verificar si los parámetros obligatorios están presentes y no son nulos
    IF (client_id IS NULL OR suc_id IS NULL OR vin_value IS NULL OR part_id IS NULL OR client_id = 0 OR suc_id = 0 OR vin_value = '' OR part_id = 0) THEN
        SET err_message = 'client_id, suc_id, vin_value, or part_id no pueden ser nulos o cero';
        SELECT err_message;
    ELSE
        -- Verificar si los IDs existen en las tablas correspondientes
        IF NOT EXISTS (SELECT client_id FROM clientes WHERE client_id = client_id) THEN
            SET err_message = CONCAT('client_id: ', client_id, ' no existe');
            SELECT err_message;
        ELSEIF NOT EXISTS (SELECT suc_id FROM sucursales WHERE suc_id = suc_id) THEN
            SET err_message = CONCAT('suc_id: ', suc_id, ' no existe');
            SELECT err_message;
        ELSEIF NOT EXISTS (SELECT vin FROM vehiculos WHERE vin = vin_value) THEN
            SET err_message = CONCAT('vin: ', vin_value, ' no existe');
            SELECT err_message;
        ELSEIF NOT EXISTS (SELECT part_id FROM insumos WHERE part_id = part_id) THEN
            SET err_message = CONCAT('part_id: ', part_id, ' no existe');
            SELECT err_message;
        ELSE
            -- Obtener el ID del vehículo
            SELECT vehicle_id INTO vin_id FROM vehiculos WHERE vin = vin_value;
            -- Insertar el registro en la tabla orden_de_trabajo
            INSERT INTO orden_de_trabajo (client_id, part_id, suc_id, vehicle_id, service_type_id, or_number, open_date, close_date, service_description, cant_parts, hs_mo)
            VALUES (client_id, part_id, suc_id, vin_id, service_type_id, or_number, open_date, close_date, service_description, cant_parts, hs_mo);
            -- Devolver el resultado
            SELECT * FROM orden_de_trabajo ORDER BY or_id DESC;
        END IF;
    END IF;
	COMMIT;
END $$

DELIMITER ;

-- SP para insercion de concesionarios con datos correctos
DELIMITER $$

CREATE PROCEDURE sp_insert_dlr (
    IN DLR_CODE CHAR(3),
    IN CONCESIONARIO VARCHAR(50)
)
BEGIN
    DECLARE err_message VARCHAR(255);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
		BEGIN
		-- ERROR, WARNING
		ROLLBACK;
	END;
  START TRANSACTION;
    -- Verificar si los parámetros obligatorios están presentes y no son nulos
    IF (dlr_code IS NULL OR concesionario IS NULL) THEN
        SET err_message = 'dlr_code o concesionario no pueden ser nulo';
        SELECT err_message;
	ELSE
		-- Insertar el registro en la tabla orden_de_trabajo
		INSERT INTO concesionarios (dlr_code, concesionario)
		VALUES (dlr_code, concesionario);
		-- Devolver el resultado
		SELECT * FROM concesionarios ORDER BY dlr_id DESC;
    END IF;
	COMMIT;
END $$

DELIMITER ;

-- para testear
-- SELECT * FROM orden_de_trabajo;
-- SELECT * FROM control_ot;
-- SELECT * FROM vehiculos;

-- CALL sp_insert_or (11, 5, 11, 'U83Q25Y99D6536727', 2, 11235486, '2023-10-21', '2023-10-22', 'reparacion de chapa y pintura', 3, 4);

-- TRIGGERS
-- trigger para completar control_ot
CREATE TRIGGER tr_insert_ot
AFTER INSERT ON orden_de_trabajo
FOR EACH ROW
INSERT INTO control_ot (or_id, fecha_insercion)
VALUES (NEW.or_id, CURRENT_TIMESTAMP());

-- triggers para completar la tabla de auditoria (faltaria agregar los triggers de las demas tablas)
CREATE TRIGGER tr_insert_dlrs
AFTER INSERT ON concesionarios
FOR EACH ROW
INSERT INTO audits (entity, entity_id, operation, insert_dt, created_by)
VALUES ('DLRs', NEW.dlr_id, 'insert', CURRENT_TIMESTAMP(), USER());

CREATE TRIGGER tr_update_dlrs
AFTER UPDATE ON concesionarios
FOR EACH ROW
INSERT INTO audits (entity, entity_id, operation, insert_dt, created_by)
VALUES ('DLRs', NEW.dlr_id, 'update', CURRENT_TIMESTAMP(), USER());

CREATE TRIGGER tr_delete_dlrs
AFTER DELETE ON concesionarios
FOR EACH ROW
INSERT INTO audits (entity, entity_id, operation, insert_dt, created_by)
VALUES ('DLRs', OLD.dlr_id, 'delete', CURRENT_TIMESTAMP(), USER());