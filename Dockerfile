# Stage 1: Build
FROM maven:3.8.3-openjdk-17 AS builder

ENV PROJECT_HOME /usr/src/jwt
ENV JAR_NAME api-jwt-0.0.1.jar

WORKDIR $PROJECT_HOME
COPY . .
RUN mvn clean install -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine

ENV PROJECT_HOME /app
ENV JAR_NAME api-jwt-0.0.1.jar

# Configurações de memória e performance
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseContainerSupport"

WORKDIR $PROJECT_HOME
COPY --from=builder /usr/src/jwt/target/$JAR_NAME $PROJECT_HOME/



EXPOSE 8080

ENTRYPOINT java $JAVA_OPTS -jar -Dspring.profiles.active=prod $JAR_NAME