# Base Alpine Linux based image with OpenJDK JRE only
FROM openjdk:8-jre-alpine
# set working directory
WORKDIR /
# add application JAR (with libraries inside)
ADD target/*.jar target/
# expose port
EXPOSE 9966
# specify default command
CMD ["java","-jar","target/*.jar"]
