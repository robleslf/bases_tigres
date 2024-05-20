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
                    aud_ope ENUM('I','U','D') COMMENT 'I=INSERT, U=UPDATE, D=DELETE',
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
DELIMITER //
CREATE TRIGGER centro_BU BEFORE UPDATE ON centro
	FOR EACH ROW
		BEGIN
			INSERT INTO centro_aud (cenNumero, cenNome, cenEnderezo, aud_dat, aud_usr, aud_ope)
			VALUES (OLD.cenNumero, OLD.cenNome, OLD.cenEnderezo, CURRENT_TIMESTAMP, CURRENT_USER(), 'U');
		END;
//
DELIMITER ;


DROP TRIGGER IF EXISTS centro_BD;
DELIMITER //
CREATE TRIGGER centro_BD BEFORE DELETE ON centro
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
            

-- 
-- 
-- EVENTOS:
-- 
--     1. Executa o código dos exemplos dos apuntamentos e comproba o resultado.
--         a. Consulta o valor da variable de entorno event_scheduler, e se está desactivada actívaa.
--         b. Crea dous eventos que:
--             ▪ O primeiro debe executarse o 1 de xullo ás 0h e reducirá o prezo dos artigos un 10% (p.7)
--             ▪ O segundo debe executarse o 1 de agosto ás 0h e subirá o prezo dos artigos un 10% 
--               (este non está implementado nos apuntes, debes facelo ti) 
--         c. Crea unha táboa comprasPrevistas nas que se garde o cálculo de compras que deben facerse cada semana, e crea un evento  que se execute semanalmente e inserte os datos das compras previstas para cada semana (pax. 7). 
--         d. Cambia o calendario de execución do evento actualizaPrezo (pax.8).
--         e. Cambia o nome e a BD na que está do evento actualizaPrezo (pax.8).
--         f. Deshabilita o evento  actualizaPrezo (pax. 8).
--         g. Consulta os eventos existentes na BD  (pax. 9).
--         h. Borra algún dos eventos creados (pax. 8)
--           
--     2. Na BD tendaBD crea un evento que incremente o prezo de venta dos artigos un 1% cada 2 meses, empezando o 1 de xullo deste ano.
--        
--     3. Modifica o evento creado na actividade anterior para que deixe de executarse o 1 de decembro do mesmo ano.
--        
--     4. Modifica o evento creado na actividade anterior para desactivalo.
--        
--     5. Na BD tendaBD crea un evento sen activar que se execute o 10 de xuño ás 2h e faga:
--         ◦ Estableza a data actual como data de baixa e como data de última actualización, para aqueles artigos sen data de baixa dos que non se vendeu ningunha unidade no último ano.
--         ◦ Estableza a data actual como data de baixa e como data de última actualización, para aqueles cliente sen data de baixa que non mercaron nada no último ano.
--        
--     6. Modifica o evento creado na actividade anterior para activalo e cambia a súa data de execución para o 12 de xuño ás 20h.
--        