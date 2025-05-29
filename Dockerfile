# Stage 1: Build Stage
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy necessary files
COPY pom.xml .
COPY src ./src

# Run Maven to compile and package the application
RUN ./mvnw clean package -DskipTests

# Stage 2: Deploy on Tomcat
FROM tomcat:9-jdk17
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file from the build stage
COPY --from=builder /app/target/*.war ./ROOT.war

# Expose the application port
EXPOSE 8080

# Start Tomcat when the container launches
ENTRYPOINT ["catalina.sh", "run"]


