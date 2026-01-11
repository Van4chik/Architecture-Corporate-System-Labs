-- удаление существующих таблиц, если они существуют
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;

-- создание таблицы authors
CREATE TABLE authors (
  id BIGSERIAL PRIMARY KEY,
  full_name VARCHAR(200) NOT NULL,
  birth_year INT
);

-- создание таблицы books
CREATE TABLE books (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(250) NOT NULL,
  isbn VARCHAR(32),
  published_year INT,
  price NUMERIC(10,2),
  author_id BIGINT NOT NULL REFERENCES authors(id) ON DELETE CASCADE
);

-- заполнение данными таблицы authors
INSERT INTO authors(full_name, birth_year) VALUES
('Фёдор Достоевский', 1821),
('Агата Кристи', 1890);

-- заполнение данными таблицы books
INSERT INTO books(title, isbn, published_year, price, author_id) VALUES
('Преступление и наказание', '978-5-17-118366-0', 1866, 12.50, 1),
('Убийство в "Восточном экспрессе"', '978-0-00-711931-8', 1934, 9.90, 2);
