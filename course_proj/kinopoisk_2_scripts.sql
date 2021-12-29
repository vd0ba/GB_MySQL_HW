USE kinopoisk_2;

-- 1) JOIN запросы
-- Список фильмов по жанрам
SELECT m.name AS 'Фильм' , m.release_year AS 'Год выпуска' , g.name AS 'Жанр' FROM movies m
	JOIN genre g ON g.id = m.genre_id 
ORDER BY g.name ;

-- средняя оценка для каждого фильма
SELECT 
	m.name as 'Фильм',
	ROUND(AVG(film_rating),2) as 'Оценка'
FROM rating r 
	JOIN movies m ON r.movie_id = m.movie_id
GROUP BY m.movie_id;

-- фильм и актер
SELECT m.name as 'Фильм',
	CONCAT(p.name, ' ', p.surname) as 'Актер'
FROM film_group fg
	JOIN  movies m 
		ON fg.movie_id = m.movie_id 
	JOIN  people p 
		ON fg.people_id = p.people_id 
	JOIN  professions prof
		ON fg.professions_id = prof.id 
WHERE prof.id = 1;

-- 2) UNION (+ вложенный запрос)
-- подборка фильмов по жанру
SELECT m.name, m.release_year, g.name FROM movies m 
	LEFT JOIN genre g ON g.id = m.genre_id WHERE m.genre_id = (SELECT id FROM genre WHERE name = 'Боевик')
UNION
SELECT m.name, m.release_year, g.name FROM movies m 
	LEFT JOIN genre g ON g.id = m.genre_id WHERE m.genre_id = (SELECT id FROM genre WHERE name = 'Мультфильмы');

-- 3) Вложенные запросы
-- выбираем фильм с определенным актером
SELECT m.name FROM movies m WHERE m.movie_id = 
	(SELECT fg.movie_id FROM film_group fg WHERE fg.people_id = 
		(SELECT p.people_id FROM people p WHERE p.surname = 'Стейтем')
);

-- 4) Представления
-- передставление, выирающее все фильмы по режиссеру
INSERT INTO film_group (movie_id, people_id, professions_id) VALUES (5, 1, 2);

CREATE OR REPLACE VIEW film_director AS
SELECT m.name, m.release_year, m.genre_id FROM movies m
	JOIN film_group fg ON fg.movie_id = m.movie_id 
WHERE fg.people_id = (SELECT p.people_id FROM people p WHERE p.surname = 'Ричи');

SELECT * FROM film_director;

-- передставление с полной информацией о пользователях условием по id
CREATE OR REPLACE VIEW users_full AS
SELECT * FROM users u 
	LEFT JOIN profiles p ON u.id = p.user_id
WHERE u.id > 2;

SELECT * FROM users_full;


-- 5) Хранимые процедеры/триггеры
-- процедура рекомендации друзей по городу
DROP PROCEDURE IF EXISTS friends_recommendations;

DELIMITER //

CREATE PROCEDURE friends_recommendations(IN for_user_id BIGINT UNSIGNED)
BEGIN
	SELECT p1.user_id FROM profiles p1 JOIN profiles p2 ON p1.city = p2.city
	WHERE p2.user_id = for_user_id AND p1.user_id != for_user_id;
END//

DELIMITER;

CALL friends_recommendations(2);

-- 6) триггер
-- введем логи для записей фильмов
DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
    table_name VARCHAR(100) NOT NULL,
    id BIGINT(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
	created_at DATETIME NOT NULL
);

DROP TRIGGER IF EXISTS users_log;

DELIMITER //
CREATE TRIGGER users_log AFTER INSERT ON movies
FOR EACH ROW
BEGIN
	INSERT INTO logs (table_name, id, name, created_at)
	VALUES ('Фильм', NEW.movie_id, NEW.name, NOW());
END//

DELIMITER ;

INSERT INTO movies VALUES (DEFAULT, 6, 'Джентельмены', '2019');
SELECT * FROM movies;
SELECT * FROM logs;