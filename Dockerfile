# Stage 1: build stage  
FROM mcr.microsoft.com/openjdk/jdk:21-ubuntu AS builder  
# Use Microsoft’s Build of OpenJDK 21 on Ubuntu as the build environment  
WORKDIR /app  
# Set working directory inside the container to /app  

# Install Maven  
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*  
# Update apt, install Maven (so you can build inside container), then clean up apt lists to save space  

# Copy project sources for build  
COPY pom.xml ./  
COPY src ./src  
# Copy the pom.xml first (so dependency layers can cache), then copy the src directory  

# Build the Spring Boot application (skip tests)  
RUN mvn clean package -DskipTests  
# Run Maven to package your app, skipping tests (because you currently don’t have tests)  

# Stage 2: runtime stage  
FROM mcr.microsoft.com/openjdk/jdk:21-ubuntu AS runtime  
# Use the same JDK 21 base image for the runtime; you could choose a slimmer image here  

WORKDIR /app  
# Set working dir for runtime  

# Create non-root user (optional but recommended)  
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid appgroup --shell /bin/bash --create-home appuser  
# Create a user/group so container doesn’t run as root (better security)  

# Copy the built jar from builder stage  
COPY --from=builder /app/target/demo-app-0.0.1-SNAPSHOT.jar ./app.jar  
# Copy only the packaged jar from the build stage into the runtime image  

# Change ownership so the non-root user runs the app  
RUN chown appuser:appgroup /app/app.jar  
USER appuser  
# Set the user for the runtime image  

# Expose your app port  
EXPOSE 8082  
# Expose port 8082 (because you configured your app to run on this port)  

# Provide Java options  
ENV JAVA_OPTS="-XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom"  
# ENV sets JVM options for container environment  

# Define the entrypoint command  
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar --server.port=8082"]  
# When container starts, run the jar with the JVM options and pass server.port argument  
