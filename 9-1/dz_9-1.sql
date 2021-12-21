DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

DROP TABLE IF EXISTS rubrics;
CREATE TABLE rubrics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO rubrics VALUES
  (NULL, 'Видеокарты'),
  (NULL, 'Память');

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';


DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';
/* ДЗ 9-1
 * 1) В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
 */
SELECT * FROM users;
SELECT * FROM sample.users;

START TRANSACTION;
INSERT INTO sample.users (id, name) SELECT shop_dz.users.id, shop_dz.users.name FROM shop_dz.users WHERE id=1;
COMMIT;

SELECT * FROM users;
SELECT * FROM sample.users;

/* 2) Создайте представление, которое выводит название name товарной позиции из таблицы
products и соответствующее название каталога name из таблицы catalogs. */
SELECT * FROM products;
SELECT * FROM catalogs;

SELECT p.name, c.name FROM products p 
	INNER JOIN catalogs AS c ON p.catalog_id = c.id;
	
CREATE VIEW pr_ct AS SELECT p.name AS name_p, c.name AS name_c FROM products p 
	INNER JOIN catalogs AS c ON p.catalog_id = c.id;

SELECT * FROM pr_ct;

/* 3) Пусть имеется таблица с календарным полем created_at. В ней размещены
разряженые календарные записи за август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и
2018-08-17. Составьте запрос, который выводит полный список дат за август, выставляя в
соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она
отсутствует. */

DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
	id SERIAL PRIMARY KEY,
	text_post TEXT,
	created_at DATE NOT NULL
);

INSERT INTO posts VALUES (1,'a1', '2018-08-01'), 
(2,'b1', '2018-08-04'), 
(3,'c1','2018-08-16'), 
(4,'d1','2018-08-17');
SELECT * FROM posts;

DROP TABLE IF EXISTS days;
CREATE TABLE days (
	`day` INT
);
INSERT INTO days VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12),(13),(14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30), (31);
SELECT * FROM days;
SELECT DATE(CONCAT('2018-08-',`day`)) AS dates FROM days;

-- SELECT DATE(DATE('2018-08-31') - INTERVAL `day` DAY) AS dates FROM days;

SELECT DATE(CONCAT('2018-08-',`day`)) AS dates, NOT ISNULL(id) AS exist FROM days
	LEFT JOIN posts
	ON created_at = DATE(CONCAT('2018-08-',`day`))
;

/* 4) Пусть имеется любая таблица с календарным полем created_at. Создайте
запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих
записей.*/

INSERT INTO posts VALUES (5,'a2', '2018-08-02'), 
(6,'b2', '2018-08-05'), 
(7,'c2','2018-08-26'), 
(8,'d2','2018-08-27');
SELECT * FROM posts;

SELECT * FROM posts ORDER BY created_at DESC LIMIT 5;

PREPARE del_post FROM 'DELETE FROM posts ORDER BY created_at LIMIT ?';
SET @amount_post = (SELECT COUNT(*)-5 FROM posts);
EXECUTE del_post USING @amount_post;
SELECT * FROM posts;
