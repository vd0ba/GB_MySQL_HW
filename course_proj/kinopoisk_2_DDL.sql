-- Решено взять Кинопоиск для создания БД - часто стали там просматривать фильмы и сериалы

/* БД на основе сайта Кинопоиск - таблицы с пользователями, профилями, статистиками пользователей,
 * друзьями, рецензиями*/

DROP DATABASE IF EXISTS kinopoisk_2;
CREATE DATABASE kinopoisk_2;
USE kinopoisk_2;

-- 1) Добавляем таблицу пользователей с основной информацией
DROP TABLE IF EXISTS users;
CREATE table users(
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(100),
	lastname VARCHAR(100),
	email VARCHAR(150) UNIQUE,
	phone CHAR(15) NOT NULL,
	password_hash VARCHAR(200),	
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX (firstname, lastname)
);
-- Наполняем таблицу
INSERT INTO users (firstname, lastname, email, phone, password_hash) VALUES
('Иван', 'Иванов', 'abcd@mail.ru', '+79123456789', 'e1fwef2f2'),
('Сергей', 'Сергеев', 'asdf@ya.ru', '+79998765432', '1frg55d8d'),
('Ольга', 'Александрова', 'qwerty@inbox.ru', '+79121234567', 'ewf55888f'),
('Екатерина', 'Первая', 'zxcvb@google.com', '+79134567890', 'uioh256e'),
('Кристина', 'Игорева', 'tyui@yandex.ru', '+79145678901', '5ghu52fg56'),
('Андрей', 'Андреев', 'fghj@mail.ru', '+79156789012', 'wf20r25dd2w'),
('Александр', 'Андриевский', 'erty@list.com', '+79167890123', 'qth52ds87'),
('Человек', 'Обычный', 'forty@bk.ru', '+79178901234', 'w32f5t20z5a');
SELECT * FROM users;

-- 2) Добавляем таблицу профилей пользователей
DROP TABLE IF EXISTS profiles;
CREATE table profiles(
	user_id SERIAL PRIMARY KEY,
	gender ENUM('f', 'm', 'x') NOT NULL,
	birthday DATE,
	photo_id BIGINT UNSIGNED NULL,	
	city VARCHAR(100),
	country VARCHAR(100),
	FOREIGN KEY (user_id) REFERENCES users (id)
);
-- Наполняем таблицу
INSERT INTO profiles (user_id, gender, birthday, city, country) VALUES
(1, 'm', '1991-11-21', 'Вена', 'Венгрия'),
(2, 'm', '1982-01-01', 'Москва', 'РФ'),
(3, 'f', '2004-10-10', 'Москва', 'РФ'),
(4, 'f', '1993-08-22', 'Прага', 'Чехия'),
(5, 'f', '1994-07-15', 'Минск', 'РБ'),
(6, 'm', '2003-10-13', 'Санкт-Петербург', 'РФ'),
(7, 'm', '1989-02-12', 'Маяйми', 'США'),
(8, 'x', '2000-12-31', 'Сочи', 'РФ');
SELECT * FROM profiles;

-- 3) Добавляем таблицу профессий, связанных с кино
DROP TABLE IF EXISTS professions;
CREATE table professions(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255)
);
-- Наполняем таблицу
INSERT INTO professions (name) VALUES ('Актер'), ('Режиссёр'), ('Продюсер');
SELECT * FROM professions;

-- 4) Добавляем таблицу людей, связанных с индустрией кино (актеры, режиссеры и т.д.)
DROP TABLE IF EXISTS people;
CREATE table people(
	people_id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	biography TEXT
);
-- Наполняем таблицу
INSERT INTO people(name, surname, biography) VALUES
('Гай', 'Ричи', 'британский кинорежиссёр, сценарист, продюсер. Наиболее известные фильмы — «Карты, деньги, два ствола», «Большой куш», «Револьвер», «Рок-н-рольщик», «Шерлок Холмс», «Шерлок Холмс: Игра теней», «Агенты А.Н.К.Л.», «Меч короля Артура», «Аладдин», «Джентльмены».'),  
('Джейсон','Стейтем','родился 26 июля[5] 1967[6], Шайрбрук, Великобритания — английский актёр, известный по фильмам режиссёра Гая Ричи («Карты, деньги, два ствола», «Большой куш», «Револьвер», «Гнев человеческий»), дилогии «Адреналин» (1, 2), а также сериям «Перевозчик»  (англ.)рус., «Неудержимые» и «Форсаж».'),
('Зак', 'Снайдер', 'американский режиссёр, сценарист, продюсер и оператор'),
('Бен', 'Аффлек', 'американский актёр кино и телевидения, кинорежиссёр, сценарист и продюсер. Лауреат двух премий «Оскар»: за оригинальный сценарий фильма «Умница Уилл Хантинг» (совместно с Мэттом Деймоном) и за фильм «Операция „Арго“» (совместно с Джорджем Клуни и Грантом Хесловом).'),
('Олег', 'Трофим', 'российский режиссёр, сценарист, продюсер и музыкант. Наиболее известен, как режиссёр фильмов «Лёд» и «Майор Гром: Чумной Доктор»'),
('Тихон','Жизневский','родился 30 августа 1988, Зеленоградск, Калининградская область - российский актёр театра и кино'),
('Дон','Холл', 'родился 8 марта 1969 года — американский кинорёжиссер, сценарист и актёр озвучивания из киностудии Walt Disney Animation. Он известен как сорежиссёр мультфильмов «Медвежонок Винни и его друзья» (2011), основанного на повести А. А. Милна «Винни-Пух», «Город героев» (2014), который был вдохновлён комиксом Marvel Big Hero 6[en], «Моана» (2016), а также «Райя и последний дракон» (2021). [1] «Город героев» получил премию «Оскар», «Золотой глобус» и «Энни» за лучший анимационный полнометражный фильм в 2015 году.')
;
SELECT * FROM people;

-- 5) Добавляем таблицу людей и их профессии (хотел сделать в одной таблице, но бывает несколько профессий на одного человека)
DROP TABLE IF EXISTS people_professions;
CREATE table people_professions (
	people_id BIGINT UNSIGNED NOT NULL,
	professions_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (people_id) REFERENCES people(people_id),	
	FOREIGN KEY (professions_id) REFERENCES professions(id)
);
-- Наполняем таблицу
INSERT INTO people_professions (people_id, professions_id) VALUES
(1, 2), (1, 3),
(2, 1), 
(3, 2), (3, 3),
(4, 1), (4, 2), (4, 3),
(5, 2), (5, 3),
(6, 1),
(7, 2);

-- 6) Добавляем таблицу жанров в кино
DROP TABLE IF EXISTS genre;
CREATE table genre(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255)
);
-- Наполняем таблицу
INSERT INTO genre (name) VALUES 
('Комедия'),
('Мультфильмы'),
('Ужасы'),
('Фантастика'),
('Триллер'),
('Боевик'),
('Мелодрама'),
('Детектив'),
('Приключения'),
('Фэнтези');

-- 7) Добавляем таблицу с фильмами
DROP TABLE IF EXISTS movies;
CREATE table movies(
	movie_id SERIAL PRIMARY KEY,
	genre_id BIGINT UNSIGNED NOT NULL,
	name VARCHAR(255) UNIQUE,
	release_year YEAR,	
	INDEX (genre_id),
	FOREIGN KEY (genre_id) REFERENCES genre (id)
);
-- Наполняем таблицу
INSERT INTO movies (genre_id, name, release_year) VALUES
(6, 'Гнев человеческий', '2021'),
(4, 'Лига справедливости', '2021'),
(6, 'Майор Гром: Чумной доктор', '2021'),
(2, 'Райя и последний дракон', '2021');
SELECT * FROM movies;

-- 8) Добавим таблицу людей, которые связаны с конкретным фильмом
DROP TABLE IF EXISTS film_group;
CREATE table film_group (
	movie_id BIGINT UNSIGNED NOT NULL,
	people_id BIGINT UNSIGNED NOT NULL,
	professions_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
	FOREIGN KEY (people_id) REFERENCES people(people_id)
);
-- Наполняем таблицу
INSERT INTO film_group (movie_id, people_id, professions_id) VALUES
(1, 1, 2), (1, 2, 1), 
(2, 3, 2), (2, 4, 1), (2, 4, 3),
(3, 5, 2), (3, 6, 1),
(4, 7, 2);

-- 9) Добавим таблицу рецензий
DROP TABLE IF EXISTS reviews;
CREATE table reviews(
	review_id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	movie_id BIGINT UNSIGNED NOT NULL,
	review TEXT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	INDEX (movie_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
-- Наполняем таблицу
INSERT INTO reviews (movie_id, user_id, review) VALUES
(1, 1, 'Очень жаль, что я не смог посмотреть «Гнев человеческий» Гая Ричи в кинотеатрах, хоть и собирался, но посмотрел его только сейчас. В общем говоря, Гай Ричи хорошо в своём стиле «кинул пыль в глаза», но получилось не так плохо, а для боевика так вообще отлично.'),
(1, 2, 'Я очень благодарный зритель и не угодить мне сложно, но здесь было прям плохо.'),
(2, 3, 'Вряд ли найдется человек, который хотя бы краем уха не слышал о легендарном "Снайдеркате" - оригинальном проекте Зака Снайдера, спрятанный где-то в застенках три года после выхода, не побоюсь этого слова, позорной театральной версии "Лиги справедливости", досъемками и пересъемками которой руководил Джосс Уидон после ухода Снайдера с поста режиссера в начале 2017 года.'),
(2, 4, 'Зак, ты, конечно, молодец, что разъяснил многое, но это можно было сделать, ужав фильм часов до трех или двух с половиной. Но нет, нам четыре часа показывают помимо сюжета и драк еще и кучу красивых, но абсолютно не нужных кадров.'),
(3, 5, 'Честно говоря, я как и большинство людей конечно же люблю боевики с комедийным уклоном. Все эти фильмы, наверное. стараются показать нам какие нибудь истории, максимально приближенные к жизни, но каждая со своей изюминкой. И конечно же Майор Гром, должна была стать одной из их числа.'),
(3, 6, 'Как бы мы не хаяли российское кино, но Майор Гром можно уже поставить особняком.'),
(4, 7, 'Не всегда дети расплачиваются за грехи отцов, порой отцы расплачиваются за глупость детей.'),
(4, 8, 'Сначала начну с положительных сторон, чтобы не выглядеть предвзято, но большая часть отзыва явно будет негативной.')
;

-- 10) Добавим таблицу оценок от пользователей
DROP TABLE IF EXISTS rating;
CREATE table rating(
	user_id BIGINT UNSIGNED NOT NULL,
	movie_id BIGINT UNSIGNED NOT NULL,
	film_rating INT UNSIGNED,
	PRIMARY KEY (user_id, movie_id),
	INDEX (film_rating),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
-- Наполняем таблицу
INSERT INTO rating (user_id, movie_id, film_rating) VALUES
(1, 1, 10),
(1, 3, 7),
(1, 4, 9),
(2, 1, 9),
(2, 2, 9),
(2, 3, 9),
(2, 4, 5),
(3, 3, 9),
(4, 4, 10),
(5, 2, 7),
(5, 3, 8),
(6, 1, 5),
(7, 1, 9),
(8, 2, 7);

-- 11) Добавляем таблицу типами медиафайлов
DROP TABLE IF EXISTS media_types;
CREATE table media_types(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255)
);
-- Наполняем таблицу
INSERT INTO media_types (name) VALUES ('Фото'), ('Постер'), ('Сцена'), ('Трейлер'), ('Видео');
SELECT * FROM media_types;

-- 12) Добавим таблицу с файлами
DROP TABLE IF EXISTS mediafiles;
CREATE table mediafiles(
	id SERIAL primary key,
	media_type_id BIGINT UNSIGNED NOT NULL,
	description TEXT,
	file_name VARCHAR(255),
	file_size BIGINT UNSIGNED,	
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);
-- Наполняем таблицу
INSERT INTO mediafiles (id, media_type_id, description, file_name, file_size) VALUES
(1, 1, 'режиссер Гай Ричи', 'Гай Ричи.jpeg', 1024),
(2, 1, 'актер Джейсон Стейтэм', 'Стейтэм.jpeg', 1024),
(3, 1, 'режиссер Зак Снайдер', 'Зак_Снайдер.jpeg', 1024),
(4, 1, 'актер Бен Аффлек', 'БЕН-АФФЛЕК.jpeg', 1024),
(5, 1, 'режиссер Олег Трофим', 'Трофим.jpeg', 1024),
(6, 2, 'постер к фильму Гнев Человеческий', 'постер_Гнев.jpeg', 20484),
(7, 2, 'постер к фильму Майор Гром', 'постер Гром.jpeg', 2048),
(8, 2, 'постер к мультфильму Райя и последний дракон', 'Раяй и дракон-постер.jpeg', 2048),
(9, 3, 'сцена Гнев Человечески', 'сцена_Гнев_Человеческий-1.jpeg', 3072),
(10, 3, 'сцена Лига Справедливости', 'сцена_Лига_Справедливости(Зак)-3.jpeg', 3072),
(11, 3, 'сцена Майор Гром', 'сцена_Майор_Гром-2.jpeg', 3072),
(12, 4, 'трейлер Гнев Человечески', 'трейлер_Гнев_Человеческий.mpeg4', 51200),
(13, 4, 'трейлер Майор Гром', 'трейлер_Майор_Гром.mpeg4', 51200),
(14, 4, 'трейлер Лиги Справедливости', 'трейлер_Лига_Справедливости_Зак.mpeg4', 51200),
(15, 4, 'трейлер Райя и последний дракон', 'трейлер_Райя_Дракон.mpeg4', 51200),
(16, 5, 'фильм Гнев Человечески', 'Гнев_Человеческий.avi', 1048576),
(17, 5, 'Лига Справедливости', 'Лига_Справедливости.avi', 1048576),
(18, 5, 'Майор Гром и Чумной Доктор', 'Майор Гром.avi', 1048576),
(19, 5, 'мультфильм Раяй и последний дракон', 'Райя и последний дракон.avi', 1048576)
;

-- 12) Добавляем таблицу с фото людей, связанных с кино (не добавил сразу потому как сначала завел таблицу людей, а потом медиа)
DROP TABLE IF EXISTS media_people;
CREATE table media_people(
	people_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	FOREIGN  KEY (people_id) REFERENCES people (people_id),
	FOREIGN  KEY (media_id) REFERENCES mediafiles (id)
);
-- Наполняем таблицу
INSERT INTO media_people (people_id, media_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5);

-- 13) Добавляем таблицу файлов для фильмов
DROP TABLE IF EXISTS media_movies;
CREATE table media_movies(
	movie_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	INDEX (movie_id),
	FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
	FOREIGN KEY (media_id) REFERENCES mediafiles(id)
);
-- Наполняем таблицу
INSERT INTO media_movies (movie_id, media_id) VALUES
(1, 6), (2, 7), (4, 8),
(1, 9), (2, 10) , (3, 11), 
(1, 12), (2, 14), (3, 13), (4, 15),
(1, 16), (2, 17), (3, 18), (4, 19);

-- 14) Добавляем таблицу друзей
DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests(
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	accepted BOOL DEFAULT FALSE,
	PRIMARY KEY(from_user_id, to_user_id),
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id)
);
-- Наполняем таблицу
INSERT INTO friend_requests VALUES (1, 2, 1), (1, 4, 1), (2, 5, 1), (2, 1, 0), (3, 8, 1);