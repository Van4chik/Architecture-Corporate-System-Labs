# Архитектура корпоративных систем
## Практическая работа №3 — RESTful веб‑сервис

**Студент:** Мамонтов И. А.
**Группа:** 6133-010402D

CRUD-приложение, поддерживает JSON и XML. Для XML добавлено XSL‑преобразование, чтобы браузер показывал XML как HTML‑страницы. Подключена документация Swagger / OpenAPI.

Предметная область: Авторы и книги (таблицы `authors` и `books`).

---
### Задание 1 — JAX‑RS vs Spring REST
Продолжение работы над Spring-проектом было выбрано сознательно, так как проект уже включает полностью настроенную типовую архитектуру (data/service/web), интеграцию с базой данных через Spring Data JPA, Flyway-миграции, валидацию (Jakarta Validation) и удобный запуск с помощью Spring Boot. Это позволяет сосредоточиться на реализации требований практического задания №3 (REST API с поддержкой JSON/XML и XSLT для XML), не тратя время на дополнительную инфраструктурную настройку и ручную сборку окружения, которая чаще требуется в варианте с JakartaEE.

Для реализации REST в выбранном Spring-проекте используется Spring REST (@RestController, Spring Web), а не JAX-RS, поскольку Spring REST обеспечивает единый стек с минимальной сложностью: те же механизмы DI, сервисы и репозитории, единая обработка ошибок и валидации, а также единая конфигурация контента (application/json, application/xml) через MessageConverters. Использование JAX-RS внутри Spring-проекта потребовало бы отдельного JAX-RS runtime (например, Jersey или RESTEasy) и дополнительной настройки маршрутизации и сериализации, что усложнило бы проект без очевидной выгоды для выполнения требований. Поэтому оптимальным и наиболее «чистым» решением в данном случае является Spring REST.

### Задание 2 — выбор предыдущего приложения и проектирование REST API
В качестве базы выбрано приложение из Практической работы №2:

- *Author*: `id`, `fullName`, `birthYear`
- *Book*: `id`, `title`, `publishedYear`, `authorId`

На его основе спроектировано REST API, которое предоставляет операции:
- Получение списков и отдельных объектов.
- Создание.
- Обновление.
- Удаление.

Дополнительно:
- `GET /api/authors/{id}/books` — книги конкретного автора.

---
### REST API

#### Authors
- `GET  /api/authors` — список авторов.
- `GET  /api/authors/{id}` — автор по id.
- `POST /api/authors` — создать автора.
- `PUT  /api/authors/{id}` — обновить автора.
- `DELETE /api/authors/{id}` — удалить автора.
- `GET /api/authors/{id}/books` — книги автора.

#### Books
- `GET  /api/books` — список книг.
- `GET  /api/books/{id}` — книга по id.
- `POST /api/books` — создать книгу.
- `PUT  /api/books/{id}` — обновить книгу.
- `DELETE /api/books/{id}` — удалить книгу.

---
### JSON и XML

#### 1) Через параметр.
- `?format=xml` → отдаётся XML (и добавляется XSL PI для красивого HTML в браузере).

Пример:
- `http://localhost:8080/api/authors?format=xml`
- `http://localhost:8080/api/books?format=xml`

#### 2) Через заголовок Accept.
- `Accept: application/json`
- `Accept: application/xml`

---
### XSL для XML в браузере

Чтобы браузер показывал XML как HTML:
1. XSL-файлы лежат в статике:
   - `src/main/resources/static/xsl/authors.xsl`
   - `src/main/resources/static/xsl/author.xsl`
   - `src/main/resources/static/xsl/books.xsl`
   - `src/main/resources/static/xsl/book.xsl`
2. При XML‑ответе сервис добавляет в начало:
   - `<?xml-stylesheet type="text/xsl" href="/xsl/....xsl"?>`

Можно просто открыть в браузере:
- `http://localhost:8080/api/authors?format=xml`
- `http://localhost:8080/api/books?format=xml`

---
### Swagger / OpenAPI
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

---
### Запуск проекта

#### 1) Настройка базы данных
Создайте БД (пример):
- database: `acs_pass`
- user: `acs_user`
- password: `acs_pass`

Проверьте настройки в:
- `src/main/resources/application.properties`

Пример:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/acs_pass
spring.datasource.username=acs_user
spring.datasource.password=acs_pass

spring.jpa.hibernate.ddl-auto=validate
spring.jpa.open-in-view=false

spring.flyway.enabled=true
```

#### 2) Запуск
Из корня проекта:
```bash
./mvnw spring-boot:run
```

Или собрать jar:
```bash
./mvnw clean package
java -jar target/*.jar
```

После запуска:
- Главная страница: `http://localhost:8080/`
- MVC: `/authors`, `/books`
- REST: `/api/...`
- Swagger: `/swagger-ui.html`