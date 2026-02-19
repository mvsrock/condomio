FROM amazoncorretto:25.0.2

ARG JAR_FILE=target/Discovery-*.jar
COPY ${JAR_FILE} discovery.jar
#ENV CAP_HOME /
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/discovery.jar"]