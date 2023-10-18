# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-oracle

ARG ACCESS_KEY
ARG SECRET_KEY
ARG AWS_REGION
# Set the working directory in the container
WORKDIR /app

# Copy the JAR file into the container at the working directory
COPY target/message-1.jar message.jar
RUN apt-get update
RUN apt-get install -y add aws-cli

# Add your AWS CLI configuration (access key, secret key, region)
RUN aws configure set aws_access_key_id ACCESS_KEY
RUN aws configure set aws_secret_access_key SECRET_KEY
RUN aws configure set default.region AWS_REGION
# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the application when the container launches
CMD ["java", "-jar", "message.jar", "--spring.profiles.active=dev"]
