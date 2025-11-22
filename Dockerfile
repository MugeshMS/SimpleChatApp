# Stage 1: Build the Spring Boot application with Maven
FROM eclipse-temurin:17-jdk-focal AS builder

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

COPY src src

RUN ./mvnw package -DskipTests

# Stage 2: Create the final lightweight runtime image
FROM eclipse-temurin:17-jre-focal

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

# Render uses a dynamic port from the env variable PORT
ENV PORT=8080
EXPOSE 8080

# Run the Spring Boot app and bind it to Render PORT
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=$PORT"]
