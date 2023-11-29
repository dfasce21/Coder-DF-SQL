use m5automotores;

-- funcion para calculo del valr total entre valores y cantidades de partes y MO
DELIMITER $$
CREATE FUNCTION calculo_de_totales (valor1 DECIMAL, cant1 INT, valor2 DECIMAL, cant2 INT) RETURNS decimal(10,0)
    DETERMINISTIC
BEGIN
RETURN (VALOR1 * CANT1 + VALOR2 * CANT2);
END $$

-- vista para vizualizar los nros de OR con sus respectivos montos totales
DELIMITER ;
CREATE or REPLACE VIEW montos AS
SELECT ot.or_number, s.suc_code, c.dlr_code, ot.open_date, ot.close_date, ts.service_type, ot.cant_parts, ot.hs_mo, ts.cost_mo, i.cost_parts, 
		calculo_de_totales(i.cost_parts, ot.cant_parts, ts.cost_mo, ot.hs_mo) AS total
FROM orden_de_trabajo ot
LEFT JOIN insumos i ON ot.part_id = i.part_id
LEFT JOIN sucursales s ON ot.suc_id = s.suc_id
LEFT JOIN concesionarios c ON s.dlr_id = c.dlr_id
LEFT JOIN tipo_de_servicio ts ON ot.service_type_id = ts.service_type_id;

-- SELECT * FROM m5automotores.montos;

-- funcion para agrupar los concesionarios por volumen de trabajo
DELIMITER $$
CREATE FUNCTION Volumen (valor1 INT) RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(10);
    IF valor1 <= 2 THEN
        SET resultado = 'CHICO';
    ELSEIF valor1 <= 4 THEN
        SET resultado = 'MEDIANO';
    ELSE
        SET resultado = 'GRANDE';
    END IF;
    RETURN resultado;
END $$

-- vista para vizualizar en que grupo se encuentran los concesionarios segun volumen en el ultimo año

DELIMITER ;
CREATE OR REPLACE VIEW Volumen_DLRs AS
SELECT c.*, COUNT(ot.or_number) AS cant_or, Volumen(COUNT(ot.or_number)) AS volumen
FROM concesionarios c
LEFT JOIN sucursales s ON c.dlr_id = s.dlr_id
LEFT JOIN orden_de_trabajo ot ON s.suc_id = ot.suc_id
WHERE YEAR(ot.close_date) = YEAR(CURRENT_DATE)
GROUP BY c.dlr_id;

-- SELECT * FROM m5automotores.Volumen_DLRs;

-- vista para vizualizar cantidad de OT que se cierran por mes

DELIMITER ;
CREATE OR REPLACE VIEW Volumen_OT_LastMonth AS
SELECT CONCAT(MONTH(close_date),"/", YEAR(close_date)) AS MES_AÑO, COUNT(or_number) AS CANTIDAD
FROM orden_de_trabajo
GROUP BY MES_AÑO;

-- SELECT * FROM m5automotores.Volumen_OT_LastMonth;

-- vista para vizualizar que tipo de vehiculo realiza mas manteniminetos/reparaciones en el ultimo año

DELIMITER ;
CREATE OR REPLACE VIEW mant_per_model AS
SELECT m.*, COUNT(ot.or_number) AS cant_or
FROM modelos m
LEFT JOIN vehiculos v ON m.model_id = v.model_id
LEFT JOIN orden_de_trabajo ot ON v.vehicle_id = ot.vehicle_id
LEFT JOIN tipo_de_servicio ts ON ot.service_type_id = ts.service_type_id
WHERE YEAR(ot.close_date) = YEAR(CURRENT_DATE) AND service_type = "mantenimiento"
GROUP BY m.model_id
ORDER BY cant_or DESC;

-- SELECT * FROM m5automotores.mant_per_model;

DELIMITER ;
CREATE OR REPLACE VIEW rep_per_model AS
SELECT m.*, COUNT(ot.or_number) AS cant_or
FROM modelos m
LEFT JOIN vehiculos v ON m.model_id = v.model_id
LEFT JOIN orden_de_trabajo ot ON v.vehicle_id = ot.vehicle_id
LEFT JOIN tipo_de_servicio ts ON ot.service_type_id = ts.service_type_id
WHERE YEAR(ot.close_date) = YEAR(CURRENT_DATE) AND service_type = "reparacion"
GROUP BY m.model_id
ORDER BY cant_or DESC;

-- SELECT * FROM m5automotores.rep_per_model;

-- vista para vizualizar que insumo es el mas utilizado en el ultimo mes

DELIMITER ;
CREATE OR REPLACE VIEW top_insumos AS
SELECT i.*, COUNT(ot.cant_parts) AS cant_parts
FROM insumos i
LEFT JOIN orden_de_trabajo ot ON i.part_id = ot.part_id
WHERE YEAR(ot.close_date) = YEAR(CURRENT_DATE) AND MONTH(ot.close_date) = MONTH(CURRENT_DATE)
GROUP BY i.part_id
ORDER BY cant_parts DESC;

-- SELECT * FROM m5automotores.top_insumos;