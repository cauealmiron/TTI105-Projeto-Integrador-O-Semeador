DROP DATABASE IF EXISTS memorialegre;
CREATE DATABASE memorialegre;
USE memorialegre;

CREATE TABLE jogadores(
	idJogador INT AUTO_INCREMENT,
    nomeJogador VARCHAR(30) NOT NULL,
    PRIMARY KEY (idJogador)
);
    
CREATE TABLE highscores(
    idHighscore INT AUTO_INCREMENT,
    idJogador INT,
    highscore_2 INT,
    highscore_5 INT,
    highscore_7 INT,
    PRIMARY KEY (idHighscore),
    FOREIGN KEY (idJogador) REFERENCES jogadores(idJogador)
);

-- *************** POPULAÇÃO TESTE ***************

INSERT INTO jogadores (nomeJogador) VALUES
('Jogador 1'),
('Jogador 2'),
('Jogador 3'),
('Jogador 4'),
('Jogador 5'),
('Jogador 6'),
('Jogador 7'),
('Jogador 8'),
('Jogador 9'),
('Jogador 10'),
('Jogador 11'),
('Jogador 12'),
('Jogador 13'),
('Jogador 14'),
('Jogador 15');

INSERT INTO highscores (idJogador, highscore_2, highscore_5, highscore_7) VALUES
(1, 100, 200, 300),
(2, 100, 250, 350),
(3, 120, 220, 320),
(4, 180, 280, 380),
(5, 130, 230, 330),
(6, 110, 210, 310),
(7, 170, 270, 370),
(8, 140, 240, 340),
(9, 190, 290, 390),
(10, 160, 260, 360),
(11, 105, 205, 305),
(12, 115, 215, 315),
(13, 125, 225, 325),
(14, 135, 235, 335),
(15, 145, 245, 345);

-- Stored procedure, manter apenas o top 10
DELIMITER $$

CREATE PROCEDURE limpar_highscores()
BEGIN
    -- Remover as tabelas temporárias
    DROP TEMPORARY TABLE IF EXISTS top_highscore_2;
    DROP TEMPORARY TABLE IF EXISTS top_highscore_5;
    DROP TEMPORARY TABLE IF EXISTS top_highscore_7;

    -- Criar uma tabela temporária para cada top 10
    CREATE TEMPORARY TABLE top_highscore_2 AS
    SELECT idHighscore FROM highscores WHERE highscore_2 IS NOT NULL ORDER BY highscore_2 DESC LIMIT 10;

    CREATE TEMPORARY TABLE top_highscore_5 AS
    SELECT idHighscore FROM highscores WHERE highscore_5 IS NOT NULL ORDER BY highscore_5 DESC LIMIT 10;

    CREATE TEMPORARY TABLE top_highscore_7 AS
    SELECT idHighscore FROM highscores WHERE highscore_7 IS NOT NULL ORDER BY highscore_7 DESC LIMIT 10;

    -- Excluir todos os registros que não estão em nenhum dos top 10
    DELETE FROM highscores 
    WHERE idHighscore NOT IN (
        SELECT idHighscore FROM top_highscore_2
    ) AND idHighscore NOT IN (
        SELECT idHighscore FROM top_highscore_5
    ) AND idHighscore NOT IN (
        SELECT idHighscore FROM top_highscore_7);

	DELETE FROM jogadores
	WHERE 
		idJogador NOT IN (
			SELECT idJogador FROM highscores);

    -- Remover as tabelas temporárias
    DROP TEMPORARY TABLE IF EXISTS top_highscore_2;
    DROP TEMPORARY TABLE IF EXISTS top_highscore_5;
    DROP TEMPORARY TABLE IF EXISTS top_highscore_7;

END$$
DELIMITER ;

-- Scheduled event limpeza diaria
CREATE EVENT EventoLimparHighscores
ON SCHEDULE EVERY 1 DAY
DO
    CALL limpar_highscores();


-- Ativar o evento
ALTER EVENT EventoLimparHighscores ENABLE;

-- TESTE

SET SQL_SAFE_UPDATES = 0;  -- Desativar o modo seguro
CALL limpar_highscores();  -- Chamar a procedure que realiza a operação
SET SQL_SAFE_UPDATES = 1;  -- Reativar o modo seguro

SELECT
    jogadores.nomeJogador,
    highscores.highscore_2,
    highscores.highscore_5,
    highscores.highscore_7
FROM
    jogadores
LEFT JOIN
    highscores
ON
    jogadores.idJogador = highscores.idJogador;
    
SELECT * FROM jogadores;
