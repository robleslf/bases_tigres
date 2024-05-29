-- Ejercicio 1
DROP PROCEDURE numero;

delimiter //
CREATE PROCEDURE numero()
BEGIN
DECLARE vCodigo INT DEFAULT 0;
-- SET vCodigo = 5;

IF vCodigo < 0 THEN
SELECT "negativo";

ELSEIF vCodigo = 0 THEN
SELECT "cero";

ELSE 
	SELECT "positivo";
    
END IF;
END;
//
delimiter ;

CALL numero();


-- 2

delimiter //
CREATE PROCEDURE matrimonio()
BEGIN
	DECLARE vCodigo VARCHAR(1) DEFAULT "C";
    CASE  vCodigo 
    WHEN "S" THEN
    SELECT "Soltero";
    WHEN "C" THEN
    SELECT "Vergudo";
    WHEN "D" THEN
    SELECT "Doritos";
    WHEN "V" THEN
    SELECT "Volvo";
    WHEN "U" THEN
    SELECT "UNICEF";
    WHEN 'P' THEN 
    SELECT 'Patatafrita';
    ELSE 
    SELECT 'Estado civil no especificado';
END CASE;
END;
//
delimiter ;

CALL matrimonio;


-- 3
DROP PROCEDURE IF EXISTS comparador;

delimiter //
CREATE PROCEDURE comparador()
BEGIN
DECLARE vNumeroInicio INT DEFAULT 0;
DECLARE vNumeroFinal INT;
DECLARE contadorPares INT;
SET contadorPares = 0;
SET vNumeroFinal = 14; 

patata: WHILE (vNumeroInicio <= vNumeroFinal) do
	IF vNumeroInicio % 2 = 0 THEN
		SET contadorPares = contadorPares + 1;
	END IF;
    SET vNumeroInicio = vNumeroInicio + 1;
    END WHILE patata;
    
    SELECT CONCAT("El número de números pares es ",contadorPares);
END;
//
delimiter ;
	
CALL comparador;


-- 4
DROP PROCEDURE IF EXISTS elRepeat;

delimiter //
CREATE PROCEDURE elRepeat()
BEGIN
DECLARE numeroIntentos INT DEFAULT 0;
DECLARE numeroNuestro INT;
DECLARE numeroAleatorio INT;
SET numeroNuestro = 14;
repeat
	BEGIN
		SET numeroAleatorio = FLOOR(1 + RAND() * 99);
		SET numeroIntentos = numeroIntentos + 1;
	END;
UNTIL numeroNuestro = numeroAleatorio
END repeat;

SELECT CONCAT("numeroIntentos: ", numeroIntentos);
END;
//
delimiter ;

CALL elRepeat();







