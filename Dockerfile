# Stage 1: Build Stage
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy Maven wrapper and POM to leverage Docker cache
COPY mvnw pom.xml ./

# Install dependencies and package the application
RUN ./mvnw clean package -DskipTests

# Stage 2: Deploy on Tomcat
FROM tomcat:9.0.78-jdk17

# Create a non-root user for security
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Set working directory
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file from the build stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Set appropriate permissions
RUN chown -R tomcat:tomcat /usr/local/tomcat/webapps

# Switch to non-root user
USER tomcat

# Expose Tomcat's default port
EXPOSE 8080

# Optional health check
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1

# Start Tomcat
CMD ["catalina.sh", "run"]



