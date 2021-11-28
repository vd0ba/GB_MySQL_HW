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
SELECT * FROM games;

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

-- Урок №4
-- Добавим колонку с номером паспорта
ALTER TABLE users ADD COLUMN passport_number VARCHAR(10);

-- изменит тип даных
ALTER TABLE users MODIFY COLUMN passport_number VARCHAR(20);

-- переименуем ее
ALTER TABLE users RENAME COLUMN passport_number TO passport;

-- Добавим индекс на колонку
ALTER TABLE users ADD INDEX passport_idx(passport);

-- Удалим колонку
ALTER TABLE users DROP COLUMN passport;

-- совершенствуем таблицу дружбы
-- добавляем ограничение, что отправитель запроса на дружбу 
-- не может быть одновременно и получателем
-- CHECK CONSTRAINTS
ALTER TABLE friend_requests ADD CONSTRAINT CHECK(from_user_id != to_user_id);

-- добавляем ограничение, что номер телефона должен состоять из 11
-- символов и только из цифр
-- https://regex101.com/
ALTER TABLE users ADD CONSTRAINT CHECK (REGEXP_LIKE(phone, '^[0-9]{11}$'));

-- CRUD-операции
-- INSERT 
DESCRIBE users;

-- добавляем пользователя
INSERT users(id, firstname, lastname, phone, email, password_hash, created_at, updated_at)
VALUES (DEFAULT, 'Alex', 'Stepanov', '89162558844', 'alex@mail.com', 'asdsdaasd', DEFAULT, DEFAULT);

-- не указываем default значения
INSERT users (firstname, lastname, phone, email)
VALUES ('Lena', 'Stepanova', '89123456789', 'lena@mail.com');

-- не указываем названия колонок
INSERT users 
VALUES (DEFAULT, 'Chris', 'Ivanov', '89213546560', 'chris@mail.com', 'kdfhgkasd', DEFAULT, DEFAULT);

INSERT INTO users (id, firstname, lastname, email, phone)
VALUES (55, 'Jane', 'Kvanov', 'jane@mail.com', '89293546560');

-- добавляем несколько пользователей
INSERT INTO users (firstname, lastname, email, phone)
VALUES ('Igor', 'Petrov', 'igor@mail.com', '89213549560'),
('Oksana', 'Petrova', 'oksana@mail.com', '89213549561');

-- добавляем через SET
INSERT users
SET firstname = 'Iren',
lastname = 'Sidorova',
email = 'iren@mail.com',
phone = '89123456789';

-- выполняем скрипт из файла users.sql, добавляется база данных test1 с таблицей users
-- добавляем через SELECT в таблицу users базы данных vk информацию о пользователях из базы данных test1
INSERT INTO users (firstname, lastname, email, phone)
SELECT name, surname, email, phone FROM test1.users;

/*
 * SELECT
 * https://dev.mysql.com/doc/refman/8.0/en/select.html
 */

-- выбираем константы

SELECT 1;

SELECT 'Hello world';

SELECT 10+10;

-- выбираем только имена
SELECT firstname FROM users;

-- выбираем только уникальные имеа
SELECT DISTINCT firstname FROM users;

-- выбор по имени
SELECT * FROM users WHERE firstname = 'Аноним';

-- выбираем пользователей с id больше или равным 85
SELECT * FROM users WHERE id >= 85;

-- выбираем пользователей с id больше или равным 85 и меньше или равным 100
SELECT * FROM users WHERE id >= 85 AND id <= 100;
SELECT * FROM users WHERE id BETWEEN 85 AND 100;

-- выбираем столбцы с фамилией, именем и телефоном
SELECT lastname, firstname, phone FROM users;

-- соединяем имя и фамилию с помощью CONCAT, оставляет от имени только первую букву с помощью SUBSTR
-- задаем псевдоним username для столбца
SELECT CONCAT (lastname, ' ', SUBSTR(firstname, 1, 1), '.') AS username, phone FROM users;

-- аналогично предыдущему запросу, алиас задается без ключевого слова AS
SELECT CONCAT (lastname, ' ', SUBSTR(firstname, 1, 1), '.') username, phone FROM users;

-- сортировка по столбцу lastname по убыванию (ASC- по возрастанию)
SELECT lastname, firstname, phone FROM users ORDER BY lastname DESC;

-- выбираем количество выводимых строк
SELECT * FROM users LIMIT 4;

-- выбираем 5 пропустив 10
SELECT * FROM users LIMIT 5 OFFSET 10;
SELECT * FROM users LIMIT 10, 5;

-- выбираем у кого нет хэша пароля
SELECT * FROM users WHERE password_hash IS NULL;

-- выбираем у кого есть хэш пароля
SELECT * FROM users WHERE password_hash IS NOT NULL;

-- выбираем пользователей с id c 70 по 100 или именем Екатерина
SELECT * FROM users WHERE id > 70 AND id < 100 OR firstname = 'Екатерина';

-- выбираем пользователей с именем, оканчивающимся на -ина
SELECT * FROM users WHERE firstname LIKE '%ина';

/*
 * UPDATE
 * https://dev.mysql.com/doc/refman/8.0/en/update.html 
*/

-- добавляем несколько сообщений
INSERT INTO messages (from_user_id, to_user_id, body)
VALUES (45, 55, 'Hi!');

INSERT INTO messages (from_user_id, to_user_id, body)
VALUES (45, 55, 'I hate you!');

SELECT * FROM messages;


-- меняем текст сообщения
UPDATE messages 
SET body = 'I love you!'
WHERE id = 5;

-- меняем статус на сообщение доставлено
UPDATE messages SET is_delievered = 1;

/*
 * DELETE
 * https://dev.mysql.com/doc/refman/8.0/en/update.html 
 * TRUNCATE
 * https://dev.mysql.com/doc/refman/8.0/en/truncate-table.html
*/

SELECT * FROM users WHERE lastname = 'Stepanov';

-- удаляем пользователя с фамилией Степанов
DELETE FROM users WHERE lastname = 'Stepanov';

DELETE FROM users WHERE id = 1;


-- удаляем все строки из messages
DELETE FROM messages;

SELECT * FROM messages;

SELECT * FROM communities_users;

-- Очищаем таблицу
TRUNCATE TABLE communities_users;


-- ДЗ №4

-- 1) Заполнить все таблицы БД vk данными (по 10-20 записей в каждой таблице)
-- добавим в таблицу-каталог "видео"
INSERT INTO media_types VALUES (DEFAULT, 'видео');
-- таблица с медиа ( + добавляю фото для таблицы с объявлениеми)
INSERT INTO media 
VALUES (DEFAULT, 1, 1, 'phone_sell.jpg', 150, DEFAULT),
(DEFAULT, 2, 1, 'auto_sell.jpg', 150, DEFAULT),
(DEFAULT, 55, 1, 'house_sell.jpg', 150, DEFAULT),
(DEFAULT, 80, 1, 'ball_sell.jpg', 150, DEFAULT),
(DEFAULT, 1, 1, 'Iphone12_sell.jpg', 150, DEFAULT),
(DEFAULT, 7, 1, 'mouse_sell.jpg', 150, DEFAULT),
(DEFAULT, 200, 1, 'cat_sell.jpg', 150, DEFAULT),
(DEFAULT, 25, 1, 'picture_sell.jpg', 150, DEFAULT),
(DEFAULT, 43, 1, 'juice_sell.jpg', 150, DEFAULT),
(DEFAULT, 141, 1, 'PC_sell.jpg', 150, DEFAULT),
(DEFAULT, 145, 1, 'PS4_sell.jpg', 150, DEFAULT),
(DEFAULT, 55, 4, 'TheBigBangTheory_promo.avi', 716800, DEFAULT),
(DEFAULT, 45, 4, 'Dexter_s001.mp4', 110000, DEFAULT),
(DEFAULT, 10, 2, 'song_1', 3072, DEFAULT),
(DEFAULT, 11, 2, 'song_2', 3072, DEFAULT),
(DEFAULT, 12, 2, 'song_3', 3072, DEFAULT),
(DEFAULT, 13, 3, 'price.docx', 100, DEFAULT),
(DEFAULT, 14, 3, 'test1.txt', 150, DEFAULT),
(DEFAULT, 15, 3, 'test2.txt.jpg', 150, DEFAULT);
SELECT * FROM media;

-- таблица с объявлениями
INSERT INTO board_announcement 
VALUES (DEFAULT, 'Телефон', 'Продам классный телефон', 4, 9999.50, 1),
(DEFAULT, 'Машина', 'Продам машину в отличном состоянии', 5, 99999.50, 2),
(DEFAULT, 'Дом', 'Продам уютный дом', 6, 10000000, 55),
(DEFAULT, 'Мяч', 'Продам футбольный мяч', 7, 100, 80),
(DEFAULT, 'Iphone12', 'Продам Iphone12', 8, 10000, 1),
(DEFAULT, 'Мышь', 'Продам компьютерную мышь', 9, 200, 7),
(DEFAULT, 'Мейкун', 'Продам мейкун мальчик', 10, 10000, 200),
(DEFAULT, 'Картина', 'Продам картину-реплику', 11, 10000, 25),
(DEFAULT, 'Сок', 'Продам березовый сок', 12, 1000, 43),
(DEFAULT, 'Компьютер', 'Продам игровой компьютер', 13, 20000, 141),
(DEFAULT, 'Приставка', 'Продам игровую приставку', 14, 30000, 145);
SELECT * FROM board_announcement;

-- заполняем таблицу с группами
INSERT INTO communities 
VALUES (DEFAULT, 'Number2', 'I am number two', 2),
(DEFAULT, 'Киноманы', 'Великие кинокритики', 25),
(DEFAULT, 'Музыка', 'Типо песни', 30),
(DEFAULT, 'Картины', 'Сборище художников', 35),
(DEFAULT, 'Юмор', 'Сборник анекдотов, мемасов и прочего нетонущего', 19),
(DEFAULT, 'Книжки', 'Сборник классики поэзии', 29),
(DEFAULT, 'Новости', 'Самые несвежие новости', 39),
(DEFAULT, 'Кухня', 'Пальчики откусишь', 11),
(DEFAULT, 'Медицина', 'Приложи подорожник', 111),
(DEFAULT, 'Спорт', 'Пью, курю, ругаюсь матом', 22),
(DEFAULT, 'Работа', 'РАБотай', 35);
SELECT * FROM communities;

-- заполняем таблицу участников групп
INSERT INTO communities_users VALUES (2, 7), (2, 4), (4, 5), (4, 6), (3, 21), (5, 44),
(6, 7), (6, 8), (10, 9), (10, 10), (10, 11), (12, 20),(12, 30);
SELECT * FROM communities_users;

-- заполняем таблицу запросов в друзья
INSERT INTO friend_requests VALUES (4, 2, 1), (4, 5, 0), (6, 8, 1), (6, 11, 0), (8, 12, 1), (8, 15, 0), (11, 22, 1),
(12, 23, 0), (13, 33, 1), (22, 40, 0), (25, 42, 1), (26, 48, 1);
SELECT * FROM friend_requests;

-- заполняем таблицу-каталог жанров игр
INSERT INTO game_types VALUES (DEFAULT, 'Викторины'),
(DEFAULT, 'Гонки'),
(DEFAULT, 'Детские'),
(DEFAULT, 'Инди'),
(DEFAULT, 'Казино'),
(DEFAULT, 'Казуальные'),
(DEFAULT, 'Карточные'),
(DEFAULT, 'Музыкальные'),
(DEFAULT, 'Настольные'),
(DEFAULT, 'Симуляторы'),
(DEFAULT, 'Стратегии');
SELECT * FROM game_types;
SELECT * FROM games;

-- заполняем таблицу игр
INSERT INTO games VALUES (DEFAULT, 'Черепашки-ниндзя', 1, 'Черепашки-ниндзя снова сразятся со шредером', 2, DEFAULT),
(DEFAULT, 'Формула-1', 5, 'Супер гонки Формула-1', 2, DEFAULT),
(DEFAULT, 'Миллионер', 4, 'Кто хочет стать миллионером?!', 4, DEFAULT),
(DEFAULT, 'Паззлы', 3, 'Паззлы: от 9 до 100', 5, DEFAULT),
(DEFAULT, 'Герои меча и магии', 2, 'Великая игра теперь здесь', 6, DEFAULT),
(DEFAULT, 'Кот Леопольд', 6, 'Помоги кот подружится с мышами', 7, DEFAULT),
(DEFAULT, 'Черный шар', 7, 'Помоги пройти все испытания', 8, DEFAULT),
(DEFAULT, 'Покер', 8, 'Техасский холдем', 20, DEFAULT),
(DEFAULT, 'Floppy bird', 9, 'Тап-тап, птичка', 22, DEFAULT),
(DEFAULT, 'Дурак', 10, 'Карточный дурак', 30, DEFAULT),
(DEFAULT, 'Guitar Hero', 11, 'Стань гитаристом', 33, DEFAULT),
(DEFAULT, 'Монополия', 12, 'Монополия онлайн', 35, DEFAULT),
(DEFAULT, 'Sims', 13, 'Симулятор жизни', 40, DEFAULT),
(DEFAULT, 'Рассвет цивилизации', 14, 'Развивай свой мир', 50, DEFAULT);
SELECT * FROM games;

-- заполняем таблицу очков в игре
INSERT INTO table_game VALUES (1,4,800), (2,1,700), (2,2,500), (17,4,100), (17,5,200), (18,2,1200), (18,5,500), (19,6,100),
(19,1,7500), (20,2,7200), (21,8,500), (21,1,3200), (22,2,3150), (22,12,500), (23,1,200);
SELECT * FROM table_game;

-- заполняем таблицу сообщений
INSERT INTO messages VALUES (DEFAULT, 4, 5, 'Hi!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 5, 4, 'Bye!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 6, 7, 'Hi!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 7, 6, 'Bye!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 8, 9, 'Hi!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 9, 8, 'Bye!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 10, 20, 'Hi!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 20, 15, 'Bye!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 15, 20, 'Hi!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 20, 15, 'Hello!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 30, 100, 'Hi!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 100, 30, 'No, thanks!', DEFAULT, DEFAULT, DEFAULT);
SELECT * FROM messages;

-- заполняем таблицу профилей
INSERT INTO profiles VALUES (4, 'f', '1991-02-01', 4, 'Kaluga', 'Russia');
INSERT INTO profiles VALUES (5, 'f', '1992-03-05', 5, 'Paris', 'France');
INSERT INTO profiles VALUES (6, 'm', '1993-05-10', 6, 'Murmansk', 'Russia');
INSERT INTO profiles VALUES (7, 'f', '2006-01-01', 7, 'Moscow', 'Russia');
INSERT INTO profiles VALUES (8, 'f', '2005-08-31', 8, 'Moscow', 'Russia');
INSERT INTO profiles VALUES (9, 'm', '2005-10-20', 9, 'Omsk', 'Russia');
INSERT INTO profiles VALUES (10, 'x', '1973-01-31', 10, ' ', ' ');
INSERT INTO profiles VALUES (11, 'm', '1998-06-23', 11, ' ', ' ');
INSERT INTO profiles VALUES (12, 'm', '1984-11-30', 12, 'Tyla', 'Russia');
INSERT INTO profiles VALUES (13, 'm', '2002-07-07', 13, 'Tomsk', 'Russia');
INSERT INTO profiles VALUES (14, 'm', '1993-08-01', 14, 'Irkutsk', 'Russia');
INSERT INTO profiles VALUES (15, 'f', '1998-02-28', 15, 'Afins', 'Greece');
SELECT * FROM profiles;


-- 2) Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке
SELECT DISTINCT firstname FROM users ORDER BY firstname ASC;

-- 3) Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false). 
-- Предварительно добавить такое поле в таблицу profiles со значением по умолчанию = true (или 1) 
ALTER TABLE profiles ADD COLUMN is_active BOOL NOT NULL DEFAULT (DEFAULT);
-- SELECT * FROM profiles WHERE birhday > NOW() - INTERVAL 18 YEAR;
-- скрипт
UPDATE profiles SET is_active = 0 WHERE birhday > NOW() - INTERVAL 18 YEAR;
SELECT * FROM profiles;

-- 4) Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней)
-- как мы проверим правильность работы, если не можем контролировать дату отправки...
DELETE FROM messages WHERE create_at > NOW(); 