# Stage 1: Build Stage
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy all files from the current directory to /app in the container
COPY . /usr/local/app

# Run Maven to compile and package the application
RUN ./mvnw clean package -DskipTests

# Stage 2: Deploy on Tomcat
FROM tomcat:9.0.78-jdk17


# Copy the WAR file from the build stage into Tomcat's webapps directory
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Optional health check
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1


