INSERT INTO authors(full_name, birth_year) VALUES
('Фёдор Достоевский', 1821),
('Агата Кристи', 1890);

INSERT INTO books(title, isbn, published_year, price, author_id) VALUES
(
  'Преступление и наказание',
  '978-5-17-118366-0',
  1866,
  12.50,
  (SELECT id FROM authors WHERE full_name = 'Фёдор Достоевский')
),
(
  'Убийство в "Восточном экспрессе"',
  '978-0-00-711931-8',
  1934,
  9.90,
  (SELECT id FROM authors WHERE full_name = 'Агата Кристи')
);
