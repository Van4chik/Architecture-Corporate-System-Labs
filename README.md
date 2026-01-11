# Архитектура корпоративных систем
## Практическая работа №2 — Приложение на Spring

**Студент:** Мамонтов И. А.
**Группа:** 6133-010402D

CRUD‑приложение Spring (3 слоя):

- *Слой данных:* Spring Data JPA + Hibernate, PostgreSQL.
- *Бизнес-логика*: сервисы `AuthorService`, `BookService`.
- *Представление*: Spring MVC + Thymeleaf.

Предметная область: Авторы и книги (таблицы `authors` и `books`).

---
### Возможности
- Просмотр списка авторов и книг.
- Добавление / редактирование / удаление авторов.
- Добавление / редактирование / удаление книг.
- Связь Book → Author (многие‑к‑одному).
- Миграции БД через Flyway (создание таблиц + начальные данные).

---
### Настройка базы данных
Создайте базу и пользователя:

```sql
CREATE DATABASE acs_pass;

CREATE USER acs_user WITH PASSWORD 'acs_pass';
GRANT ALL PRIVILEGES ON DATABASE acs_pass TO acs_user;

-- Для PostgreSQL иногда нужно отдельно дать права на схему/таблицы (после миграций):
-- GRANT ALL ON SCHEMA public TO acs_user;
```

Если сделано — просто пропускаем шаг.

---
### Конфигурация приложения

Файл: `src/main/resources/application.properties`

Пример:
```properties
spring.application.name=acs-pr2-spring-mvc

spring.datasource.url=jdbc:postgresql://localhost:5432/acs_pass
spring.datasource.username=acs_user
spring.datasource.password=acs_pass

spring.jpa.hibernate.ddl-auto=validate
spring.jpa.open-in-view=false

spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
```

---
### Миграции Flyway

Миграции лежат в папке:
```
src/main/resources/db/migration
```

При первом запуске Flyway:
- создаст таблицу `flyway_schema_history`.
- применит миграции и создаст таблицы `authors`, `books`.
- при наличии SQL вставок — добавит стартовые данные.

---
### Запуск проекта
#### Вариант A: запустить через Maven Wrapper (самый простой)

*Windows (PowerShell):*
```powershell
.\mvnw.cmd spring-boot:run
```

*macOS / Linux:*
```bash
./mvnw spring-boot:run
```

После старта откройте в браузере:
- `http://localhost:8080/authors`
- `http://localhost:8080/books`

#### Вариант B: собрать JAR и запустить его
Сборка:
```bash
./mvnw clean package
```

Запуск:
```bash
java -jar target/*.jar
```