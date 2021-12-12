/* INNER JOIN */
/* Выведем имя и фамилию администраторов сообществ. */

SELECT users.firstname, users.lastname, communities.name FROM users 
	INNER JOIN communities ON users.id = communities.admin_id;
	
/* LEFT JOIN */
/* Вывести всех пользователей и сообщества, где они создатели, если такие есть. */
SELECT users.firstname, users.lastname, communities.name FROM users LEFT JOIN communities 
	ON users.id = communities.admin_id;

/* LEFT JOIN, только без совпадений. */ 
/* Вывести пользователей, которые не создавали сообщества. */
SELECT users.firstname, users.lastname, communities.name FROM users LEFT JOIN communities 
	ON users.id = communities.admin_id WHERE communities.name IS NULL;

/* RIGHT JOIN */
/* Вывести всех пользователей и сообщества, где они создатели, если такие есть. */
SELECT users.firstname, users.lastname, communities.name FROM communities RIGHT JOIN users
	ON users.id = communities.admin_id;

-- ALTER TABLE communities MODIFY admin_id BIGINT UNSIGNED;

ALTER TABLE communities MODIFY admin_id BIGINT UNSIGNED;

INSERT INTO communities (name, description) VALUES ('community_name', 'i have no admin');

SELECT users.firstname, users.lastname, communities.name FROM users RIGHT JOIN communities 
	ON users.id = communities.admin_id;
	
/* FULL OUTER JOIN */
SELECT users.firstname, users.lastname, communities.name FROM users 
	LEFT JOIN communities ON users.id = communities.admin_id
UNION
SELECT users.firstname, users.lastname, communities.name FROM users RIGHT JOIN communities 
	ON users.id = communities.admin_id;
	
/* FULL OUTER JOIN, только без совпадений. */
/* Выводим список из пользователей, которых нет сообществ, и сообществ без администратора */
SELECT users.firstname, users.lastname, communities.name FROM users 
	LEFT JOIN communities ON users.id = communities.admin_id WHERE communities.id IS NULL
UNION
SELECT users.firstname, users.lastname, communities.name FROM users RIGHT JOIN communities 
	ON users.id = communities.admin_id WHERE users.id IS NULL;
	
/* CROSS JOIN*/
SELECT  users.firstname, users.lastname, communities.name FROM users CROSS JOIN communities;

-- Неявный cross join
SELECT users.firstname, users.lastname, communities.name FROM users, communities;

/* Задание 1. Выводим данные пользователя: фамилию, имя, дату рождения, пол. */
SELECT users.firstname, users.lastname, profiles.birthday, profiles.gender FROM users JOIN profiles
	ON users.id = profiles.user_id;
	
/* Задание 2. Выводим данные пользователя с красивым полом и возрастом. */
SELECT 
firstname, lastname,
	CASE gender
		WHEN 'f' THEN 'female'
		WHEN 'm' THEN 'male'
		WHEN 'x' THEN 'not defined'
	END AS gender, 
TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age 
FROM users JOIN profiles ON users.id = profiles.user_id;

/* Задание 3. Выводим все медифайлы пользователей. */
SELECT firstname, lastname, file_name, file_size FROM media JOIN users ON media.user_id = users.id;

/* Задание 4. Выводим все медифайлы пользователя c id = 2. */
SELECT u.firstname, u.lastname, m.file_name, m.file_size FROM users AS u 
	JOIN media AS m ON u.id = m.user_id 
WHERE u.id = 2;

/* Задание 5. Выводим изображения пользователей. */
SELECT firstname, lastname, file_name, file_size, name FROM media 
	JOIN users ON media.user_id = users.id
	JOIN media_types ON media.media_types_id = media_types.id
	WHERE name = 'image';

/* Задание 6. Выводим все отправленные сообщения пользователя с email = greenfelder.antwan@example.org. */
SELECT from_user_id, to_user_id, txt FROM messages
	JOIN users ON messages.from_user_id = users.id
	WHERE users.email = 'greenfelder.antwan@example.org';

/* Задание 7. Выводим все сообщения пользователя с email = greenfelder.antwan@example.org. */
SELECT from_user_id, to_user_id, txt, messages.created_at FROM messages 
	JOIN users ON from_user_id = users.id OR to_user_id = users.id
WHERE users.email = 'greenfelder.antwan@example.org'
ORDER BY messages.created_at DESC;

/* Задание 8. Выводим все сообщения пользователя с email = greenfelder.antwan@example.org c именем получателя. */

SELECT 
	sender.firstname,
	sender.lastname,
	from_user_id,
	txt,
	receiver.firstname,
	receiver.lastname,
	to_user_id 
FROM messages
	JOIN users AS sender ON messages.from_user_id = sender.id
	JOIN users AS receiver ON messages.to_user_id = receiver.id
WHERE sender.email = 'greenfelder.antwan@example.org' OR receiver.email = 'greenfelder.antwan@example.org';

/* Задание 9. Выводим диалог между пользователями с id = 1 и id = 2. */

SELECT 
	CONCAT(u1.firstname, ' ', u1.lastname) AS sender,
	CONCAT(u2.firstname, ' ', u2.lastname) AS reciever,
	txt
FROM messages m
	JOIN users u1 ON m.from_user_id = u1.id
	JOIN users u2 ON m.to_user_id = u2.id
WHERE m.from_user_id = 1 AND m.to_user_id = 2 OR m.from_user_id = 2 AND m.to_user_id = 1
ORDER BY m.created_at DESC;

/* Задание 10. Выводим количество друзей. */
SELECT u.id, u.lastname, u.firstname, COUNT(*) AS total_friends FROM users u
	JOIN friend_requests fr ON fr.from_user_id = u.id OR fr.to_user_id = u.id
	-- 	WHERE fr.request_type = 1
	JOIN friend_requests_types frt ON frt.id = fr.request_type
	WHERE frt.name = 'accepted'
	GROUP BY u.id;
	
/* Задание 11. Выводим пользователей с количеством друзей больше 5. */

SELECT u.id, u.lastname, u.firstname, COUNT(*) AS total_friends FROM users u
	JOIN friend_requests fr ON fr.from_user_id = u.id OR fr.to_user_id = u.id
	-- 	WHERE fr.request_type = 1
	JOIN friend_requests_types frt ON frt.id = fr.request_type
	WHERE frt.name = 'accepted'
	GROUP BY u.id
	HAVING total_friends > 5;

/* Задание 12. Выводим все посты пользователя с количеством лайков. 'greenfelder.antwan@example.org' */
SELECT p.id, p.txt, COUNT(*) AS total_likes FROM posts p 
	JOIN posts_likes pl ON p.id = pl.post_id
	JOIN users u ON u.id = p.user_id
	WHERE u.email = 'greenfelder.antwan@example.org'
	GROUP BY p.id;
	
/* Задание 13. Выводим всех друзей пользователя с id = 1. */
SELECT DISTINCT u.id, firstname, lastname FROM users u
	JOIN friend_requests fr ON u.id = fr.from_user_id OR u.id = fr.to_user_id
	JOIN friend_requests_types frt ON fr.request_type = frt.id 
	WHERE (fr.from_user_id = 1 OR fr.to_user_id = 1) AND u.id != 1 AND frt.name = 'accepted';

/* Задание 15. Выводим все положительно разрешенные заявки для пользователя с id = 1. */
SELECT 
	u1.id,
	CONCAT(u1.firstname, ' ', u1.lastname) AS requester,
	u2.id,
	CONCAT(u2.firstname, ' ', u2.lastname) AS reciever
FROM friend_requests fr 
	JOIN users u1 ON fr.from_user_id = u1.id
	JOIN users u2 ON fr.to_user_id = u2.id
	JOIN friend_requests_types frt ON fr.request_type = frt.id
WHERE (u1.id = 1 OR u2.id = 1) AND frt.name = 'accepted';


/* ДЗ №8
 * 1) Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался
 * с выбранным пользователем (написал ему сообщений). */
SELECT 
	from_user_id,
	CONCAT(sender.firstname, ' ', sender.lastname) AS sender,
	CONCAT(receiver.firstname, ' ', receiver.lastname) AS receiver,
	to_user_id,
	count(*) AS total_mess
FROM messages
	JOIN users AS sender ON messages.from_user_id = sender.id
	JOIN users AS receiver ON messages.to_user_id = receiver.id
WHERE receiver.id = 1
GROUP BY sender
ORDER BY total_mess DESC
LIMIT 1;

/* 2) Подсчитать общее количество лайков, которые получили пользователи младше 10 лет. */
SELECT * FROM posts_likes pl;

SELECT u.id, p.id, p.txt, 
	COUNT(*) AS total_likes,
	TIMESTAMPDIFF(YEAR, pr.birthday, NOW()) AS age
FROM posts p 
	JOIN posts_likes pl ON p.id = pl.post_id
	JOIN users u ON u.id = p.user_id
	JOIN profiles pr ON pr.user_id = p.user_id 
GROUP BY p.id
ORDER BY total_likes DESC
;

SELECT COUNT(*) AS total_likes FROM posts p 
	JOIN posts_likes pl ON p.id = pl.post_id
	JOIN users u ON u.id = p.user_id
	JOIN profiles pr ON u.id = pr.user_id 
	WHERE TIMESTAMPDIFF(YEAR, pr.birthday, NOW()) < 10
;

/* 3) Определить кто больше поставил лайков (всего): мужчины или женщины. */
-- SELECT user_id, count(*) FROM posts_likes pl WHERE like_type = '1' GROUP BY user_id; для проверки

SELECT pr.gender, count(*) total_likes
FROM posts_likes pl
		JOIN profiles pr ON pr.user_id = pl.user_id 
WHERE pl.like_type = 1 AND gender != 'x'
GROUP BY gender
ORDER BY total_likes DESC
-- LIMIT 1
;