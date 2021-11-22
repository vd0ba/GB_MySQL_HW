DROP DATABASE IF EXISTS vk;

CREATE DATABASE IF NOT EXISTS vk;

USE vk;

/*
* 1. Создадим таблицу users.
*/
CREATE TABLE users(
	id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(50) NOT NULL,
	lastname VARCHAR(50) NOT NULL,
	phone CHAR(11) NOT NULL,
	email VARCHAR(120) UNIQUE,
	password_hash CHAR(65), 
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX (lastname),
	INDEX (phone)
);

-- показываем все таблицы
SHOW TABLES;

INSERT INTO users 
VALUES (1, 'Petya', 'Petukhov','99999999929', 'petya@mail.com', '81dc9bdb52d04dc20036dbd8313ed055', DEFAULT, DEFAULT);

INSERT INTO users (firstname, lastname, email, password_hash, phone) 
 VALUES ('Vasya', 'Vasilkov', 'vasya@mail.com', '81dc9bdb52d04dc20036dbd8313ed055', '99999999919');

SELECT * FROM users;

/*
 * 2. Создадим таблицу с профилем пользователя, чтобы не хранить все данные в таблице users
 */

CREATE TABLE profiles(
	user_id SERIAL PRIMARY KEY, -- BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	gender ENUM('f', 'm', 'x') NOT NULL,
	birhday DATE NOT NULL,
	photo_id BIGINT UNSIGNED NOT NULL,
	city VARCHAR(130),
	country VARCHAR(130),
	FOREIGN KEY (user_id) REFERENCES users (id)
);
-- Заполним таблицу, добавим профили для уже созданных Пети и Васи

INSERT INTO profiles VALUES (1, 'm', '1997-12-01', 1, 'Moscow', 'Russia'); -- профиль Пети

-- INSERT INTO profiles VALUES (5, 'm', '1988-11-02', 5, 'Moscow', 'Russia'); -- ошибка 

INSERT INTO profiles VALUES (2, 'm', '1988-11-02', 2, 'Moscow', 'Russia'); -- профиль Васи

SELECT * FROM profiles;

/*
 * 3. Создадим таблицу с сообщениями пользователей.
 */

CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	create_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	is_delievered BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id)	
);

-- Добавим два сообщения от Пети к Васе, одно сообщение от Васи к Пете

INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Hi!', DEFAULT, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 1
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Vasya!', DEFAULT, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2
INSERT INTO messages VALUES (DEFAULT, 2, 1, 'Hi, Petya', DEFAULT, DEFAULT, DEFAULT); -- сообщение от Пети к Васе номер 2

SELECT * FROM messages;

/*
 * 4. Создадим таблицу запросов в друзья.
 */

CREATE TABLE friend_requests(
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	accepted BOOL DEFAULT FALSE,
	PRIMARY KEY(from_user_id, to_user_id),
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id)
);

-- Добавим запрос на дружбу от Пети к Васе
INSERT INTO friend_requests VALUES (1, 2, 1);

/*
 * 5. Создадим таблицу сообществ.
*/

CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(145) NOT NULL,
	description VARCHAR(255),
	admin_id BIGINT UNSIGNED NOT NULL,
	INDEX communities_name_idx (name),
	CONSTRAINT fk_communities_admin_id FOREIGN KEY (admin_id) REFERENCES users (id) 
);

INSERT INTO communities VALUES (DEFAULT, 'Number1', 'I am number one', 1);

/*
 * 6. Создадим таблицу для хранения информации обо всех участниках всех сообществ.
 */

CREATE TABLE communities_users(
	community_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY(community_id, user_id),
	FOREIGN KEY (community_id) REFERENCES communities (id),
	FOREIGN KEY (user_id) REFERENCES users (id) 
);

INSERT INTO communities_users VALUES (1, 2);

/*
 * 7. Создадим таблицу для хранения типов медиа файлов, каталог типов медифайлов.
 */

CREATE TABLE media_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(45) NOT NULL UNIQUE
);

INSERT INTO media_types VALUES (DEFAULT, 'изображение');
INSERT INTO media_types VALUES (DEFAULT, 'музыка');
INSERT INTO media_types VALUES (DEFAULT, 'документ');

SELECT * FROM media_types;

/*
 * 8. Создадим таблицу всех медиафайлов.
 */

CREATE TABLE media(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_types_id INT UNSIGNED NOT NULL,
	file_name VARCHAR(255),
	file_size BIGINT UNSIGNED,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (media_types_id) REFERENCES media_types (id)
);

-- Добавим два изображения, которые добавил Петя
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im.jpg', 100, DEFAULT);
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im1.png', 78, DEFAULT);

-- Добавим документ, который добавил Вася
INSERT INTO media VALUES (DEFAULT, 2, 3, 'doc.docx', 1024, DEFAULT);

SELECT * FROM media;

-- Долго думал какие таблицы еще придумать и решил...

/*
 * №0 Сделать таблицу-каталог с жанрами игр
 */
CREATE TABLE game_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO game_types VALUES (DEFAULT,'Action');
INSERT INTO game_types VALUES (DEFAULT, 'RPG');
INSERT INTO game_types VALUES (DEFAULT, 'Puzzle');

SELECT * FROM game_types;

/*
 * №1 Сделать таблицу с играми
 */
CREATE TABLE games(
	id SERIAL PRIMARY KEY,
	name VARCHAR(250),
	game_types_id INT UNSIGNED NOT NULL,
	description TEXT NOT NULL,
	developer_user_id BIGINT UNSIGNED NOT NULL, 
	created_at DATETIME NOT NULL DEFAULT NOW(),
	INDEX game_name_indx (name),
	FOREIGN KEY (developer_user_id) REFERENCES users (id),
	FOREIGN KEY (game_types_id) REFERENCES game_types (id)
);

INSERT INTO games VALUES (DEFAULT, 'Contra', 1, 'ЭТА игра теперь здесь!', 1, DEFAULT);
INSERT INTO games VALUES (DEFAULT, 'Super Mario', 1, 'Братья Марио вернулись!', 1, DEFAULT);

/*
* №2 Сделаем таблицу участников игры
*/

CREATE TABLE table_game (
	game_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	score_user BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (game_id) REFERENCES games (id)
);

INSERT INTO table_game VALUES (1,1,1000), (1,2,950);

SELECT * FROM table_game;

/*
* №3 Таблица объявлений (без категорий)
*/

CREATE TABLE board_announcement(
	id SERIAL PRIMARY KEY,
	name_product VARCHAR(128) NOT NULL,
	description_product TEXT NOT NULL,
	photo_product_id BIGINT UNSIGNED NOT NULL,
	amount_product DECIMAL(15,2) NOT NULL,
	seller_id BIGINT UNSIGNED NOT NULL,
	INDEX name_product_index (name_product),
	FOREIGN KEY (photo_product_id) REFERENCES media (id),
	FOREIGN KEY (seller_id) REFERENCES users (id)
);

INSERT INTO board_announcement VALUES (DEFAULT, 'Сапоги', 'Резиновые непромокаемые сапоги', 1, 999.99, 1);

SELECT * FROM board_announcement;