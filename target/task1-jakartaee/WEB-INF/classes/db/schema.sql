CREATE TABLE IF NOT EXISTS authors (
  id BIGSERIAL PRIMARY KEY,
  full_name VARCHAR(200) NOT NULL,
  birth_year INT,
  CONSTRAINT uq_authors_full_name UNIQUE (full_name)
);

CREATE TABLE IF NOT EXISTS books (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(250) NOT NULL,
  isbn VARCHAR(32),
  published_year INT,
  price NUMERIC(10,2),
  author_id BIGINT NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
  CONSTRAINT uq_books_isbn UNIQUE (isbn)
);
