# ---------- build WAR ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

# ---------- runtime: GlassFish ----------
FROM eclipse-temurin:17-jre-jammy

ARG GF_VERSION=7.1.0
ARG PG_JDBC_VERSION=42.7.8

ENV GF_HOME=/opt/glassfish7
ENV PATH="${GF_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates netcat-openbsd bash \
 && rm -rf /var/lib/apt/lists/*

# GlassFish (официальная ссылка Eclipse)
RUN mkdir -p /opt \
 && curl -fsSL "https://download.eclipse.org/ee4j/glassfish/glassfish-${GF_VERSION}.zip" -o /tmp/gf.zip \
 && unzip -q /tmp/gf.zip -d /opt \
 && rm /tmp/gf.zip \
 && mv /opt/glassfish7 /opt/glassfish7 || true

# PostgreSQL JDBC driver (нужен для PGSimpleDataSource в пуле)
RUN curl -fsSL "https://repo1.maven.org/maven2/org/postgresql/postgresql/${PG_JDBC_VERSION}/postgresql-${PG_JDBC_VERSION}.jar" \
    -o "${GF_HOME}/glassfish/domains/domain1/lib/postgresql.jar"

# WAR из build stage
COPY --from=build /src/target/*.war /opt/app.war

# entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 4848
ENTRYPOINT ["/entrypoint.sh"]
