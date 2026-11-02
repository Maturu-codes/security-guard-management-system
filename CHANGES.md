# Changes in this upgrade
- Removed hardcoded DB credentials from db.properties and META-INF/context.xml (env vars / system properties now)
- DatabaseUtil reads DB_URL, DB_USER, DB_PASSWORD from the environment
- Added Dockerfile, docker-compose.yml, .dockerignore, .env.example
- Added JUnit 5 + Mockito, 3 test classes, surefire plugin
- Added GitHub Actions CI (build, test, docker build)
- README: corrected Tomcat 9 -> 10.1 / Jakarta namespaces, added Docker + testing sections
