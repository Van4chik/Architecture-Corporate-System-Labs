# Архитектура корпоративных систем
## Практическая работа №4 — Java Message Service

**Студент:** Мамонтов И. А.
**Группа:** 6133-010402D

---
### 1) Настройка базы данных
Создайте БД и пользователя. Пример:
```sql
CREATE DATABASE acs_pass;
CREATE USER acs_user WITH PASSWORD 'acs_pass';
GRANT ALL PRIVILEGES ON DATABASE acs_pass TO acs_user;
````

В `application.properties` должны быть корректные данные подключения:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/acs_pass
spring.datasource.username=acs_user
spring.datasource.password=acs_pass
```

Flyway при запуске сам создаст таблицы, включая `audit_log`.

---
### 2) Запуск ActiveMQ Artemis и MailHog

#### Вариант A - запуск через Docker
Запуск Artemis

```bash
docker run -d --name artemis \
  -p 61616:61616 -p 8161:8161 \
  -e ARTEMIS_USER=admin -e ARTEMIS_PASSWORD=admin \
  apache/activemq-artemis:2.41.0-alpine
```

Панель Artemis: [http://localhost:8161](http://localhost:8161)
Логин / пароль: `admin / admin`

Запуск MailHog
```bash
docker run -d --name mailhog \
  -p 1025:1025 -p 8025:8025 \
  mailhog/mailhog
```

Панель MailHog: [http://localhost:8025](http://localhost:8025)

---
#### Вариант B: запуск без Docker (локально)
ActiveMQ Artemis без Docker

1. Скачайте ActiveMQ Artemis с официального сайта (дистрибутив).
2. Создайте брокер:
```bash
./artemis create mybroker
```

3. Запустите:
```bash
cd mybroker/bin
./artemis run
```

4. Убедитесь, что порты:
* 61616 (JMS).
* 8161 (web console).

MailHog без Docker
1. Скачайте MailHog (бинарник под вашу ОС) из релизов.
2. Запуск:
```bash
MailHog
```

3. Порты по умолчанию:
* SMTP: 1025.
* Web UI: 8025.

---
### 3) Настройки приложения
Пример `src/main/resources/application.properties`:

```properties
# DB
spring.datasource.url=jdbc:postgresql://localhost:5432/acs_pass
spring.datasource.username=acs_user
spring.datasource.password=acs_pass

spring.jpa.hibernate.ddl-auto=validate
spring.jpa.open-in-view=false

spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration

# JMS (Artemis)
spring.artemis.mode=native
spring.artemis.broker-url=tcp://localhost:61616
spring.artemis.user=admin
spring.artemis.password=admin

app.jms.audit-queue=audit.queue
app.jms.notify-queue=notify.queue

# Email (MailHog)
spring.mail.host=localhost
spring.mail.port=1025
spring.mail.properties.mail.smtp.auth=false
spring.mail.properties.mail.smtp.starttls.enable=false

app.notify.enabled=true
app.notify.from=acs-pr4@localhost
app.notify.to=test1@local.test,test2@local.test
app.notify.subject-prefix=[ACS-PR4]
```
---

### 4) Запуск приложения
В корне проекта:
```bash
mvn clean spring-boot:run
```

Swagger UI: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)