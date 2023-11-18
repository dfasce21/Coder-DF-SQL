use m5automotores;

SET AUTOCOMMIT = 0;

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

-- transacciones sueltas
START TRANSACTION;
CALL sp_insert_dlr ('ATN', 'Autonort');
INSERT INTO concesionarios VALUES ('CEL', 'Celentano');
INSERT INTO concesionarios VALUES ('AGO', 'Autosiglo');
DELETE FROM concesionarios WHERE dlr_code='ATN';
SAVEPOINT sp1;
INSERT INTO concesionarios VALUES ('TSU', 'Tsuyoi');
INSERT INTO concesionarios VALUES ('MIL', 'Milanesio');
DELETE FROM concesionarios WHERE dlr_code='AGO';
ROLLBACK TO sp1;
COMMIT;

-- en este caso, quedarian agregados los concesionarios CEL y AGO 
-- ya que ATN se borra y los otros nunca se commitean por el rollback sp1