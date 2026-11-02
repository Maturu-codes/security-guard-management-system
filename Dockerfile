# ---- Build stage: compile and package the WAR with Maven ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B package -DskipTests

# ---- Runtime stage: Tomcat 10.1 (the code uses the jakarta.* namespace) ----
FROM tomcat:10.1-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
# Deploy at /sgms to match the path in META-INF/context.xml
COPY --from=build /app/target/sgms.war /usr/local/tomcat/webapps/sgms.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
