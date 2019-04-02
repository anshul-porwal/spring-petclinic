# Base Alpine Linux based image with OpenJDK JRE only
FROM openjdk:8-jre-alpine
# set working directory
WORKDIR /app
# add application JAR (with libraries inside)
ADD target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /app
# expose port
EXPOSE 9966
# specify default command
CMD ["java","-jar","spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar"]
