FROM amazoncorretto:25.0.2

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /app.jar

EXPOSE 8094
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]
