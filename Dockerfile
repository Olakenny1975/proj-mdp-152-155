# Stage 1: Build Stage
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy only the necessary files to leverage Docker cache
COPY pom.xml .
COPY src ./src

# Run Maven to compile and package the application
RUN ./mvnw clean package -DskipTests

# Stage 2: Deploy on Tomcat
FROM tomcat:9.0.78-jdk17-slim

# Create a non-root user for security
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Set the working directory inside the container
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file from the build stage into Tomcat's webapps directory
COPY --from=builder /app/target/*.war ./ROOT.war

# Set appropriate permissions for the Tomcat user
RUN chown -R tomcat:tomcat /usr/local/tomcat/webapps

# Switch to the non-root user
USER tomcat

# Expose the application port
EXPOSE 8080

# Start Tomcat when the container launches
ENTRYPOINT ["catalina.sh", "run"]
