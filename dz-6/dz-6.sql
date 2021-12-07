-- 
-- Модифицируем таблицу friends_requests

CREATE TABLE friend_requests_types
(
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(128) UNIQUE NOT NULL
);

ALTER TABLE friend_requests DROP COLUMN accepted;

ALTER TABLE friend_requests ADD COLUMN request_type INT UNSIGNED NOT NULL;

ALTER TABLE friend_requests ADD CONSTRAINT fk_friends_types 
FOREIGN KEY (request_type) REFERENCES friend_requests_types (id);

ALTER TABLE friend_requests ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

/*
 * Запрос 1. Выбираем основную информацию пользователя с id=1.
*/


-- Выбираем данные пользователя с id 1
SELECT 
	firstname, 
	lastname,
	'city',
	'profile_photo'
FROM users WHERE id = 1;

SELECT city FROM profiles WHERE user_id = 1;

SELECT 
	firstname, 
	lastname,
	(SELECT city FROM profiles WHERE user_id = 1) AS city,
	(SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = 1)) AS profile_photo
FROM users WHERE id = 1;

SELECT photo_id FROM profiles WHERE user_id = 1;

SELECT file_name FROM media WHERE id = 1;

SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = 1);

SELECT 
	firstname, 
	lastname,
	(SELECT city FROM profiles WHERE user_id = users.id) AS city,
	(SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = users.id)) AS profile_photo
FROM users WHERE id = 1;

SELECT 
	firstname, 
	lastname,
	(SELECT city FROM profiles WHERE user_id = users.id) AS city,
	(SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = users.id)) AS profile_photo
FROM users;

/*
 * Задание 2. Поиск медиафайлов пользователя с id = 1.
*/

SELECT file_name FROM media WHERE user_id = 1 AND media_types_id = 1;

SELECT id FROM media_types WHERE name = 'image';

SELECT file_name FROM media WHERE user_id = 1 AND media_types_id = (SELECT id FROM media_types WHERE name = 'image');

-- 'greenfelder.antwan@example.org'

SELECT id FROM users WHERE email = 'greenfelder.antwan@example.org';

SELECT file_name FROM media 
WHERE user_id = (SELECT id FROM users WHERE email = 'greenfelder.antwan@example.org')
	AND media_types_id = (SELECT id FROM media_types WHERE name = 'image');
	
SELECT user_id,  file_name FROM media WHERE (file_name LIKE '%.png' OR file_name LIKE '%.jpg') AND user_id = 1;

/*
 * Задание 3. Посчитаем количество медиафайлов каждого типа.
*/

-- количество всех файлов в таблице media
SELECT COUNT(*) FROM media;

SELECT * FROM media;

SELECT COUNT(*) FROM profiles;

SELECT COUNT(photo_id) FROM profiles;

-- считаем количество медиафайлов по каждому типу

SELECT media_types_id, COUNT(*) FROM media GROUP BY media_types_id;

SELECT 
	media_types_id,
	(SELECT name FROM media_types WHERE media_types.id = media.media_types_id) AS media_type, 
	COUNT(*) AS total
FROM media GROUP BY media_types_id;

/*
 * Задание 4. Посчитаем количество медиафайлов каждого типа для каждого пользователя.
*/

SELECT user_id,
	(SELECT name FROM media_types WHERE media_types.id = media.media_types_id) AS media_type, 
	COUNT(*) AS total,
	SUM(file_size) AS total_size
FROM media GROUP BY user_id, media_types_id
ORDER BY user_id, total_size;

/*
 * Задание 5. Выбираем друзей пользователя с id = 1.
*/
-- выбираем от кого пользователю пришли заявки, заявки приняты
SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1;

-- выбираем кому пользователь отправил заявки
SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 1;

SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1
UNION
SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 1;

-- еще один вариант без использования UNION
SELECT DISTINCT IF(to_user_id = 1, from_user_id , to_user_id) AS friend FROM friend_requests 
WHERE (to_user_id = 1 OR from_user_id = 1) AND request_type = 1;


/*
 * Задание 6. Выводим имя и фамилию друзей пользователя с id = 1
*/

SELECT firstname, lastname FROM users WHERE id IN (2,3,5,7,11);


SELECT firstname, lastname FROM users WHERE id IN 
	(SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 
		(SELECT id FROM friend_requests_types WHERE name = 'accepted')
	UNION
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 
		(SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

SELECT id FROM friend_requests_types WHERE name = 'accepted';

SET @request_id := (SELECT id FROM friend_requests_types WHERE name = 'accepted');
SELECT @request_id;

SET @test_var = 'Hello world';

SELECT @test_var;

SELECT firstname, lastname FROM users WHERE id IN 
	(SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = @request_id
	UNION
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = @request_id
);

/*
 * Задание 7. Выводим красиво информацию о друзьях. Выводим пол, возраст.
*/

-- красиво выводим пол
SELECT *, 
	CASE (gender)
		WHEN 'f' THEN 'female'
		WHEN 'm' THEN 'male'
		WHEN 'x' THEN 'not defined'
	END AS gender_title
FROM profiles;

SELECT *, 
	TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
FROM profiles;

SELECT 
	firstname,
	lastname,
	(SELECT 
		CASE (gender)
			WHEN 'f' THEN 'female'
			WHEN 'm' THEN 'male'
			WHEN 'x' THEN 'not defined'
		END 
	FROM profiles WHERE profiles.user_id = users.id) AS gender,
	(SELECT TIMESTAMPDIFF(YEAR, birthday, NOW()) FROM profiles WHERE profiles.user_id = users.id) AS age
FROM users WHERE id IN (
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 
		(SELECT id FROM friend_requests_types WHERE name = 'accepted')
	UNION
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND request_type = 
		(SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

/*
 * Задание 8. Выводим все непрочитанные сообщения пользователя с id = 1.
*/

SELECT from_user_id, to_user_id, txt FROM messages 
WHERE (from_user_id = 1 OR to_user_id = 1) AND is_delivered = FALSE
ORDER BY created_at DESC;

SELECT from_user_id, to_user_id, txt FROM messages 
WHERE (from_user_id = 1 OR to_user_id = 1) AND is_delivered = FALSE
ORDER BY (from_user_id = 1), created_at DESC;

/* Домашнее задание
1) Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался 
с выбранным пользователем (написал ему сообщений).*/

SELECT firstname, lastname from users WHERE id = 
	(SELECT from_user_id FROM messages WHERE to_user_id = 2 GROUP BY from_user_id ORDER BY COUNT(from_user_id) DESC LIMIT 1
);

/* 2) Подсчитать общее количество лайков, которые получили пользователи младше 10 лет. */
 
SELECT COUNT(*) as 'Кол-во лайков' FROM posts_likes WHERE user_id IN (
	SELECT user_id FROM profiles WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 10
);

/* 3) Определить кто больше поставил лайков (всего): мужчины или женщины.*/

SELECT CASE (gender)
	WHEN 'f' THEN 'Женщина'
	WHEN 'm' THEN 'Мужчина'
	END AS 'Пол', COUNT(gender) AS 'Кол-во лайков' FROM profiles WHERE user_id IN 
		(SELECT user_id FROM posts_likes) GROUP BY gender ORDER BY COUNT(gender) DESC;