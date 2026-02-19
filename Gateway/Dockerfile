FROM amazoncorretto:25.0.2


#ARG JAR_FILE=target/authentication*.jar
ARG JAR_FILE=target/gateway-0.0.1.jar

COPY ${JAR_FILE} gateway.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/gateway.jar"]