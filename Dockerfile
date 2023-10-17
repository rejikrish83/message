# Use an official OpenJDK runtime as a parent image
FROM adoptopenjdk:17-jre-hotspot-bionic

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file into the container at the working directory
COPY target/message-1.jar message.jar

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the application when the container launches
CMD ["java", "-jar", "message.jar"]
