FROM gradle:jdk8-openj9 AS GRADLE_BUILD

COPY complete/ /gradle-build/

WORKDIR /gradle-build/
RUN gradle build -x test

FROM openjdk:8-jre-alpine

WORKDIR /app

COPY --from=GRADLE_BUILD /gradle-build/build/libs/*.jar /app/

ENTRYPOINT ["java", "-jar", "spring-boot-0.0.1-SNAPSHOT.jar"]
