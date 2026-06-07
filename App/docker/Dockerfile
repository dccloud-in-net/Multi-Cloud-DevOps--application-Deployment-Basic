# ==============================================================================
# Build Stage
# ==============================================================================
FROM maven:3.9-amazoncorretto-17 AS builder

WORKDIR /app

# Copy the pom.xml and fetch dependencies to enable caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build the application packaging
COPY src ./src
RUN mvn clean package -DskipTests -B

# ==============================================================================
# Runtime Stage
# ==============================================================================
FROM amazoncorretto:17-alpine-jdk

# Define standard metadata
LABEL maintainer="BankPro Platform Team <devops@bankpro.com>" \
      application="bankpro-microservice" \
      environment="production"

# Create a non-root group and user for security compliance
RUN addgroup -S bankpro && adduser -S bankpro -G bankpro

# Establish app working directory
WORKDIR /app

# Copy jar from builder stage
COPY --from=builder /app/target/bankpro-*.jar app.jar
COPY docker/entrypoint.sh entrypoint.sh

# Ensure script is executable and adjust ownership
RUN chmod +x entrypoint.sh && chown -R bankpro:bankpro /app

# Switch to the non-root user
USER bankpro

# Expose microservice port (Spring Boot default is 8080)
EXPOSE 8080

# Environment variables with sensible defaults
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC" \
    SPRING_PROFILES_ACTIVE="prod"

# Healthcheck configuration using standard wget (alpine doesn't have curl by default)
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["./entrypoint.sh"]
