USE traballadores;

SELECT COUNT(*)
FROM empregado
where empDepartamento = 110; -- 3

SELECT COUNT(*)
FROM empregado
where empDepartamento = 111; -- 8

SELECT *
FROM departamento
WHERE depNumero= 110; -- 3 empr

SELECT *
FROM departamento
WHERE depNumero= 111; -- 8 empregados


SELECT * FROM empregado;
SELECT * FROM departamento;

DROP TRIGGER insertarEmpleado;

-- ------------ EL TRIGGER QUE INSERTA
delimiter // -- Los tres triggers irían con el delimitador, no hace falta usar uno para cada trigger
CREATE TRIGGER empregadoAI AFTER INSERT ON empregado
FOR EACH ROW
BEGIN
	UPDATE departamento
    SET depEmpregados = (depEmpregados +1)
    WHERE depNumero = NEW.empDepartamento;
END
//
delimiter ;



INSERT INTO empregado
VALUES (9090,110,410,CURRENT_DATE(),CURRENT_DATE(),1400,30,3,"Rodolfo"),
(9091,110,410,CURRENT_DATE(),CURRENT_DATE(),1400,30,3,"Adolfo");

DELETE FROM empregado 
WHERE empNumero = 9090
OR empNumero = 9091;



-- ------------------------------------------------
-- ------------ EL TRIGGER QUE BORRA
delimiter //
CREATE TRIGGER borrarEmpleado AFTER DELETE ON empregado
FOR EACH ROW
BEGIN
	UPDATE departamento
    SET depEmpregados = (depEmpregados -1)
    WHERE depNumero = OLD.empDepartamento;
END
//
delimiter ;


-- -------------------------------------------------
-- ------------ EL TRIGGER QUE CAMBIA DEPARTAMENTO
delimiter //
CREATE TRIGGER moverEmpleado AFTER UPDATE ON empregado
FOR EACH ROW
BEGIN
	IF NEW.empDepartamento <> OLD.empDepartamento THEN -- El IF este no hace falta
		UPDATE departamento
        SET depEmpregados = depEmpregados - 1
        WHERE depNumero = OLD.empDepartamento;
        UPDATE departamento
        SET depEmpregados = depEmpregados + 1
        WHERE depNumero = NEW.empDepartamento;
	END IF;
END;
//
delimiter ;

UPDATE empregado
SET empDepartamento = 111
WHERE empNumero = 180;



-- ------------------------ crear la tabla CENTRO

CREATE TABLE centro_aud (
	cenNumero INT NOT NULL,
    cenNome CHAR(30) NULL,
    cenEnderezo CHAR(30) NULL,
    aud_dat TIMESTAMP DEFAULT CURRENT_TIMESTAMP() NOT NULL,
    aud_usr VARCHAR(30) NOT NULL,
    aud_ope ENUM ('I','U','D') NOT NULL COMMENT "I=INSERT, U=UPDATE, D=DELETE",
    CONSTRAINT centro_aud_PK 
		PRIMARY KEY (cenNumero, aud_dat, aud_usr),
	CONSTRAINT cenNumero_FK_centro
		FOREIGN KEY (cenNumero) REFERENCES centro(cenNumero));
        
        
SELECT *
FROM centro_aud;

-- DISPARADORES E EVENTOS
-- 
-- DISPARADORES:
-- 
--     1. Executa o código dos exemplos dos apuntamentos e comproba o resultado.
--         a. Crear un disparador para validar a entrada de datos (pax.2).
--         b. Crear un disparador para actualizar atributos derivados (pax. 3).
--         c. Crear un disparador para levar rexistro das operacións realizadas (pax. 3-4).
--         d. Crear un disparador para controlar as restriccións referenciais en táboas non transaccionais (pax. 5).
--         e. Consulta a información dos disparadores creados (pax. 2).
--         f. Borra os disparadores creados (pax. 1).
--            
--     2. Na BD traballadores crea tres disparadores para manter actualizado o campo depEmpregados da táboa departamento. Deberán executarse respectivamente ao engadir un empregado, ao borrar un empregado e ao mover un empregado dun departamento a outro.
--        Proba os disparadores creados usando sentenzas que afecte a varios empregados.
--        
USE traballadores;

-- Están arriba

--     3. Na BD traballadores: 
--        Crea unha táboa centro_aud que: 
--         ◦ Ten todos os campos da táboa centro.
				DESCRIBE centro;
--         ◦ Ten un campo aud_dat de tipo TIMESTAMP, obrigatorio, que toma por defecto o tempo actual (current_timestamp).
--         ◦ Ten un campo aud_usr de tipo VARCHAR(30), obrigatorio.
--         ◦ Ten un campo aud_ope de tipo ENUM cos valores ‘I’, ‘U’, ‘D’, obrigatorio, con comentario ‘I=INSERT, U=UPDATE, D=DELETE’.
--         ◦ A súa PK está formada por cenNumero, aud_data e aud_usr.
--         ◦ Ten unha FK en  cenNumero, que referencia ao mesmo campo da táboa centro.

DROP TABLE centro_aud;

CREATE TABLE centro_aud (
					cenNumero INT NOT NULL,
                    cenNome CHAR(30) NULL,
                    cenEnderezo CHAR(30) NULL,
                    aud_dat TIMESTAMP NOT NULL DEFAULT current_timestamp,
                    aud_usr VARCHAR(30) NOT NULL,
                    aud_ope ENUM('I','U','D') NOT NULL COMMENT 'I=INSERT, U=UPDATE, D=DELETE',
                    CONSTRAINT centro_aud_PK
						PRIMARY KEY (cenNumero, aud_dat, aud_usr),
					CONSTRAINT cenNumero_FK_centro
						FOREIGN KEY (cenNumero) REFERENCES centro(cenNumero));
                        
SELECT * FROM centro_aud;
                    
--       
--       Crea dous disparadores sobre a táboa centro, que se executen antes de modificar e borrar datos da táboa respectivamente, e inserten na táboa centro_aud unha fila cos datos antes da operación.
--       Para obter o usuario actual podes usar current_user.
--       Executa as probas necesarias para comprobar que funciona.
-- 
DROP TRIGGER IF EXISTS centro_BU;
DELIMITER // -- Se pueden meter los triggers dentro del mismo delimitador
CREATE TRIGGER centroAU AFTER UPDATE ON centro
	FOR EACH ROW
		BEGIN
			INSERT INTO centro_aud (cenNumero, cenNome, cenEnderezo, aud_dat, aud_usr, aud_ope)
			VALUES (OLD.cenNumero, OLD.cenNome, OLD.cenEnderezo, CURRENT_TIMESTAMP, CURRENT_USER(), 'U');
		END;
//
DELIMITER ;


DROP TRIGGER IF EXISTS centro_BD;
DELIMITER //
CREATE TRIGGER centroAD AFTER DELETE ON centro
	FOR EACH ROW
		BEGIN
			INSERT INTO centro_aud (cenNumero, cenNome,cenEnderezo,aud_usr,aud_ope)
            VALUES (OLD.cenNumero,OLD.cenNome,OLD.cenEnderezo,CURRENT_USER(),'D');
		END
//
DELIMITER ;


SELECT * FROM centro;
SELECT * FROM centro_aud;

INSERT INTO centro
VALUES (99,'Javier Hernández Chicharito','Maestro Pastrana 4');

UPDATE centro
SET cenNome = 'Guti'
WHERE cenNumero = 99;

DELETE FROM centro
WHERE cenNumero = 99;


--     4. Na BD traballadores crea un disparadores que se executen antes de modificar departamentos e que comprobe que o director asignado pertence a dito departamento, e se non se cumpre mostre un erro.
--        Executa as probas necesarias para comprobar que funciona.
USE traballadores;
SELECT * FROM empregado;
SELECT * FROM departamento;

DROP TRIGGER IF EXISTS departamento_BU;
DELIMITER //
CREATE TRIGGER departamento_BU BEFORE UPDATE ON departamento
	FOR EACH ROW
		BEGIN
			DECLARE vDepartamentoDirector SMALLINT;
            SET vDepartamentoDirector = (SELECT empDepartamento FROM empregado
											WHERE empNumero = NEW.depDirector);
			IF vDepartamentoDirector <> NEW.depNumero THEN
				SIGNAL SQLSTATE '45000' SET message_text = 'El empregado asociado como director no pertenece a ese departamento';
			END IF;
		END
//
DELIMITER ;

UPDATE departamento
SET depDirector = 160
WHERE depNumero = 110;
            

SHOW TRIGGERS;
SHOW CREATE TRIGGER departamento_BU;
-- 
-- 
-- EVENTOS:
-- 
--     1. Executa o código dos exemplos dos apuntamentos e comproba o resultado.
USE tendaBD;

--         a. Consulta o valor da variable de entorno event_scheduler, e se está desactivada actívaa.
SHOW VARIABLES LIKE 'event_scheduler';

--         b. Crea dous eventos que:
--             ▪ O primeiro debe executarse o 1 de xullo ás 0h e reducirá o prezo dos artigos un 10% (p.7)
CREATE EVENT reducir_prezo
ON SCHEDULE AT "2024-07-01 00:00:00" 
DO 
	UPDATE artigos
    SET art_pv = art_pv - (art_pv * 10 / 100);
    

--             ▪ O segundo debe executarse o 1 de agosto ás 0h e subirá o prezo dos artigos un 10% 
CREATE EVENT actualizaPrezo
ON SCHEDULE AT "2024-08-01 00:00:00" 
DO
	UPDATE artigos
	SET art_pv = art_pv + (art_pv * 10 / 100);

--               (este non está implementado nos apuntes, debes facelo ti) 
--         c. Crea unha táboa comprasPrevistas nas que se garde o cálculo de compras que deben facerse cada semana, e crea un evento  que se execute semanalmente e inserte os datos das compras previstas para cada semana (pax. 7). 
CREATE TABLE comprasPrevistas(
 data TIMESTAMP DEFAULT current_timestamp,
 artigo CHAR(8),
 unidades_vendidas INTEGER NOT NULL,
 stock INTEGER NOT NULL,
 prevision_compra INTEGER NOT NULL,
 PRIMARY KEY (data, artigo),
 FOREIGN KEY (artigo) REFERENCES artigos(art_codigo)
);

-- Evento calcula compras semanalmente
delimiter //
CREATE EVENT calculaComprasSemanal
 ON SCHEDULE EVERY 1 WEEK
 STARTS '2022-05-14 21:41:00' -- Next sunday
 DO 
BEGIN
 INSERT INTO comprasPrevistas(artigo, unidades_vendidas, stock, prevision_compra)
 SELECT art_codigo, SUM(dev_cantidade), art_stock,
 (CASE
WHEN SUM(dev_cantidade) > art_stock THEN SUM(dev_cantidade) * 2
ELSE SUM(dev_cantidade)
END)
 FROM artigos A
 JOIN detalle_vendas D ON D.dev_artigo = A.art_codigo
 JOIN vendas V ON V.ven_id = D.dev_venda
 WHERE V.ven_data > DATE_ADD(curdate(), INTERVAL -1 WEEK)
 GROUP BY art_codigo;
 END;
//
delimiter ; 
							


--         d. Cambia o calendario de execución do evento actualizaPrezo (pax.8).
ALTER EVENT actualizaPrezo
 ON SCHEDULE EVERY 1 DAY
 STARTS '2025-11-01 00:00:00'
 ENDS '2026-12-31 00:00:00';


 

--         e. Cambia o nome e a BD na que está do evento actualizaPrezo (pax.8).
-- ALTER EVENT tendaBD.actualizaPrezo
-- RENAME TO traballadores.rebaixaPrezo;


--         f. Deshabilita o evento  actualizaPrezo (pax. 8).
ALTER EVENT traballadores.rebaixaPrezo
 DISABLE
 COMMENT 'Deshabilitado por Mendez o 12/12/2015';

--         g. Consulta os eventos existentes na BD  (pax. 9).
SHOW EVENTS;

--         h. Borra algún dos eventos creados (pax. 8)
DROP EVENT actualiza_prezo;

--           
--     2. Na BD tendaBD crea un evento que incremente o prezo de venta dos artigos un 1% cada 2 meses, empezando o 1 de xullo deste ano.
--       Por defecto está activo 
USE tenda_BD;

delimiter //  
CREATE EVENT incremento_2_meses
	ON SCHEDULE EVERY 2 MONTH
		STARTS str_to_date("2024-07-01 00:00:00", "%Y-%m-%d %H:%i:%s") -- con la función te aseguras que funcione en todas las BD
DO
BEGIN
	UPDATE artigos
    SET art_pv = art_pv + (art_pv *1/100);
END; -- No son obligatorios el begin y el end porque solo hay una sentencia dentro; si hubiese dos o más, sí lo sería.
//
delimiter ;


--     3. Modifica o evento creado na actividade anterior para que deixe de executarse o 1 de decembro do mesmo ano.
delimiter //
ALTER EVENT incremento_2_meses
	ON SCHEDULE EVERY 2 MONTH 
		STARTS "2024-07-01 00:00:00"
		ENDS '2024-12-12 00:00:00'; -- habría que ponerle el formato de datas al starts y al ends para que funcione siempre
//
delimiter ;

--        
--     4. Modifica o evento creado na actividade anterior para desactivalo.
ALTER EVENT incremento_2_meses 
	DISABLE
    COMMENT "Desactivado por tal y cuál";


--        
--     5. Na BD tendaBD crea un evento sen activar que se execute o 10 de xuño ás 2h e faga:
--         ◦ Estableza a data actual como data de baixa e como data de última actualización, para aqueles artigos sen data de baixa dos que non se vendeu ningunha unidade no último ano.
--         ◦ Estableza a data actual como data de baixa e como data de última actualización, para aqueles cliente sen data de baixa que non mercaron nada no último ano.
delimiter //
CREATE EVENT fechas_baja
	ON SCHEDULE AT "2024-07-02 02:00:00" -- poner la función de datas
DISABLE
DO
BEGIN
	UPDATE artigos
    SET art_baixa = CURRENT_TIMESTAMP(),
		art_ultima_actualizacion = CURRENT_TIMESTAMP()
    WHERE art_codigo NOT IN (SELECT dev_artigo
								FROM detalle_vendas
                                WHERE dev_venda = ANY (SELECT ven_id
														FROM vendas
                                                        WHERE ven_data < (SUBDATE(CURRENT_DATE(), INTERVAL 1 YEAR))))
	AND art_baixa IS NULL;
                                                        
	UPDATE artigos
    SET clt_baixa = CURRENT_TIMESTAMP(),
		clt_ultima_actualizacion = CURRENT_TIMESTAMP()
	WHERE clt_baixa IS NULL 
    AND clt_id NOT IN (SELECT ven_cliente
						FROM clientes 
                        WHERE ven_data IN (SELECT ven_id
														FROM vendas
                                                        WHERE ven_data < (SUBDATE(CURRENT_DATE(), INTERVAL 1 YEAR))));
END;
//
delimiter ;



    



--        
--     6. Modifica o evento creado na actividade anterior para activalo e cambia a súa data de execución para o 12 de xuño ás 20h.
--        
ALTER EVENT fechas_baja
ON SCHEDULE AT "2024-06-12 20:00:00" -- Falta la fucnion de fecha str_todate(2024-05-24, %Y...etc etc ) :)
	ENABLE
    COMMENT "Activado porque sí";



show events;
show create event nombre_evetno;




