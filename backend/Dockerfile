
# Use a base image with JDK
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file built in your CI pipeline
#COPY target/my-spring-boot-app.jar app.jar
#COPY target/app.jar app.jar
COPY target/react-and-spring-data-rest-0.0.1-SNAPSHOT.jar app.jar



# Expose the port the app will run on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# Build stage (AMD64)
FROM --platform=linux/amd64 maven:3.8.6-openjdk-11-slim AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage (AMD64)
FROM --platform=linux/amd64 eclipse-temurin:11-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Security best practices
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

