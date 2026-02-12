# Multi-stage build для оптимизации размера образа

# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Копируем pom.xml и загружаем зависимости (кэшируется отдельно)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Копируем исходный код и собираем приложение
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Создаём непривилегированного пользователя
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Копируем собранный JAR из build stage
COPY --from=build /app/target/*.jar app.jar

# Expose порт приложения
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9000/actuator/health || exit 1

# Запуск приложения
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
