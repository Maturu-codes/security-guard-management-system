# 🛡️ SGMS — Security Guards Management System
**Kenya-Compliant | Enterprise-Grade | Java MVC (Servlets + JSP + JSTL)**

---

## Overview

SGMS is a full-scale, production-ready web application for managing private security operations in Kenya. Built using **pure Java EE** (no Spring Boot) with Servlets, JSP, JSTL, MySQL, and Tomcat.

### Key Features
- 👮 **Guard Management** — full employee lifecycle, PSV licensing
- 📅 **Shift Scheduling & Attendance** — GPS/QR/biometric check-in
- 🚨 **Incident Reporting & Escalation** — severity-tiered workflows
- 🔫 **Equipment Tracking** — serial numbers, licensing, issue/return logs
- 🐕 **K9 Unit Management** — dogs, handlers, medical & training records
- ⚖️ **Employee Liability & Deductions** — approval workflow, 30% cap
- 💰 **Kenya-Compliant Payroll** — NSSF (Tier I & II), NHIF, PAYE (KRA bands)
- 🔐 **Security-First** — bcrypt passwords, CSRF tokens, XSS prevention, audit trail
- 👥 **Role-Based Access** — Super Admin, Company Admin, Ops Manager, Supervisor, Guard, Client

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Language | Java 11 |
| Web Framework | Jakarta Servlet 6.0 + JSP 3.1 + JSTL 3.0 |
| Build Tool | Maven 3.x |
| Application Server | Apache Tomcat 10.1 |
| Database | MySQL 8.x |
| Password Hashing | jBCrypt |
| Frontend | Bootstrap 5, Font Awesome 6 |
| Logging | SLF4J + Logback |
| Architecture | MVC (Model-View-Controller) |

---

## Project Structure

```
sgms/
├── pom.xml
└── src/main/
    ├── java/com/sgms/
    │   ├── model/              # POJOs (User, Guard, Incident, Equipment, K9Dog, Shift…)
    │   ├── dao/                # Data Access Objects (JDBC PreparedStatements)
    │   │   ├── UserDAO.java
    │   │   ├── GuardDAO.java
    │   │   ├── IncidentDAO.java
    │   │   ├── AuditDAO.java
    │   │   └── …
    │   ├── servlet/            # Controller Servlets
    │   │   ├── LoginServlet.java
    │   │   ├── LogoutServlet.java
    │   │   ├── DashboardServlet.java
    │   │   ├── GuardServlet.java
    │   │   ├── IncidentServlet.java
    │   │   └── …
    │   ├── filter/             # Cross-cutting Filters
    │   │   ├── AuthFilter.java        # Authentication + Security Headers
    │   │   ├── CsrfFilter.java        # CSRF token validation
    │   │   ├── LoggingFilter.java     # Request logging with MDC
    │   │   └── EncodingFilter.java    # UTF-8 encoding
    │   └── util/
    │       ├── DatabaseUtil.java      # JNDI/JDBC connection management
    │       ├── SecurityUtil.java      # bcrypt, CSRF, session helpers
    │       └── PayrollCalculator.java # Kenya NSSF/NHIF/PAYE calculator
    ├── resources/
    │   ├── schema.sql          # Full MySQL DDL + seed data
    │   ├── db.properties       # JDBC fallback config
    │   └── logback.xml         # Logging config
    └── webapp/
        ├── META-INF/
        │   └── context.xml     # Tomcat JNDI DataSource config
        ├── WEB-INF/
        │   ├── web.xml         # Deployment descriptor (filters, error pages, session)
        │   └── views/
        │       ├── layout/     # header.jsp, footer.jsp (shared layout)
        │       ├── auth/       # login.jsp
        │       ├── dashboard/  # dashboard.jsp
        │       ├── guards/     # list.jsp, form.jsp, view.jsp
        │       ├── incidents/  # list.jsp, form.jsp, view.jsp
        │       ├── equipment/
        │       ├── k9/
        │       ├── shifts/
        │       ├── payroll/
        │       └── error/      # 403.jsp, 404.jsp, 500.jsp
        ├── css/main.css
        └── js/main.js
```

---

## Quick Start with Docker

Requires Docker with the Compose plugin.

```bash
cp .env.example .env        # then edit .env and choose your own passwords
docker compose up --build
```

Open http://localhost:8080/sgms once both containers are up. The database schema in
`src/main/resources/schema.sql` is loaded automatically on first start.

> The schema seeds an `admin` account (`admin@sgms.co.ke`). Change its password immediately
> after first login; never expose a fresh install to the internet.

## Running the Tests

```bash
mvn test
```

Unit tests cover the Kenya payroll calculator (NSSF tiers, NHIF brackets, PAYE bands,
liability cap) and the security utilities (bcrypt, CSRF validation, HTML escaping, role checks).
They run automatically on every push through GitHub Actions.

---

## Prerequisites

- **Java JDK 11+** (`java -version`)
- **Apache Tomcat 10.1.x** — [Download](https://tomcat.apache.org/download-10.cgi)
- **MySQL 8.x** — [Download](https://dev.mysql.com/downloads/)
- **Maven 3.6+** (`mvn -version`)

---

## Setup Instructions

### 1. Clone / Extract the Project
```bash
cd /your/workspace
# Extract or clone SGMS project
```

### 2. Set Up MySQL Database
```sql
-- Connect as root
mysql -u root -p

-- Create database and user
CREATE DATABASE sgms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'sgms_user'@'localhost' IDENTIFIED BY 'YOUR_STRONG_PASSWORD';
GRANT ALL PRIVILEGES ON sgms.* TO 'sgms_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

-- Run the schema
mysql -u sgms_user -p sgms < src/main/resources/schema.sql
```

### 3. Configure Database Credentials

**Option A — JNDI (Recommended for production):**

Edit `src/main/webapp/META-INF/context.xml`:
```xml
<Resource
    ...
    username="sgms_user"
    password="YOUR_STRONG_PASSWORD"
    ...
/>
```

Copy the MySQL Connector JAR to Tomcat's lib directory:
```bash
cp ~/.m2/repository/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar \
   $CATALINA_HOME/lib/
```

**Option B — Direct JDBC fallback:**

Edit `src/main/resources/db.properties`:
```properties
db.url=jdbc:mysql://localhost:3306/sgms?useSSL=true&serverTimezone=Africa/Nairobi
db.username=sgms_user
db.password=YOUR_STRONG_PASSWORD
```

### 4. Build the WAR
```bash
cd sgms
mvn clean package -DskipTests
```
The WAR file will be at `target/sgms.war`.

### 5. Deploy to Tomcat
```bash
# Method 1: Copy WAR
cp target/sgms.war $CATALINA_HOME/webapps/

# Method 2: Use Tomcat Manager
# Upload via http://localhost:8080/manager/html

# Start Tomcat
$CATALINA_HOME/bin/startup.sh   # Linux/Mac
$CATALINA_HOME\bin\startup.bat  # Windows
```

### 6. Access the Application
```
URL: http://localhost:8080/sgms
```

**Default admin credentials:**
```
Username: admin
Password: Admin@1234
```
⚠️ **Change the default password immediately after first login.**

---

## HTTPS Configuration (TLS)

For production, configure TLS in Tomcat's `server.xml`:

```xml
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true">
    <SSLHostConfig>
        <Certificate certificateKeystoreFile="conf/keystore.jks"
                     type="RSA"
                     certificateKeystorePassword="your_keystore_password"/>
    </SSLHostConfig>
</Connector>
```

Generate a self-signed certificate for development:
```bash
keytool -genkey -alias sgms -keyalg RSA -keystore keystore.jks \
        -dname "CN=localhost, O=SGMS, C=KE" -storepass changeit
```

Redirect HTTP to HTTPS in `web.xml`:
```xml
<security-constraint>
    <web-resource-collection><web-resource-name>All</web-resource-name>
        <url-pattern>/*</url-pattern></web-resource-collection>
    <user-data-constraint>
        <transport-guarantee>CONFIDENTIAL</transport-guarantee>
    </user-data-constraint>
</security-constraint>
```

---

## Security Features

| Feature | Implementation |
|---------|---------------|
| Password Hashing | jBCrypt with cost factor 12 |
| CSRF Protection | Per-session tokens validated on all POST requests |
| XSS Prevention | `<c:out>` in all JSPs + CSP headers |
| SQL Injection | PreparedStatements throughout all DAOs |
| Session Fixation | Session invalidated and recreated on login |
| Clickjacking | `X-Frame-Options: DENY` header |
| Content Sniffing | `X-Content-Type-Options: nosniff` header |
| Session Cookie | `HttpOnly=true`, `Secure=true`, `SameSite=Strict` |
| Audit Trail | Tamper-proof DB audit_logs + file audit log |
| Auth Filter | Redirects unauthenticated users; enforces role access |
| Security Headers | CSP, Referrer-Policy, X-XSS-Protection |

---

## Kenya Payroll Compliance

The `PayrollCalculator` implements:

### NSSF (Act No. 45 of 2013)
- **Tier I**: 6% on pensionable pay up to **KES 6,000/month**
- **Tier II**: 6% on earnings between **KES 6,000 and KES 18,000**

### NHIF (Income-based brackets)
- Ranges from **KES 150** (< KES 6,000) to **KES 1,700** (≥ KES 100,000)

### PAYE (KRA Monthly Bands)
| Income Band | Rate |
|-------------|------|
| 0 – KES 24,000 | 10% |
| KES 24,001 – 32,333 | 25% |
| KES 32,334 – 500,000 | 30% |
| KES 500,001 – 800,000 | 32.5% |
| KES 800,001+ | 35% |
| Personal Relief | KES 2,400/month |

### Liability Deductions
- Applied **after** statutory deductions
- **Capped at 30%** of net salary per pay period
- Installment recovery supported across multiple periods

---

## User Roles & Access

| Role | Access Level |
|------|-------------|
| SUPER_ADMIN | Full system access, all modules |
| COMPANY_ADMIN | All company data, payroll, settings |
| OPERATIONS_MANAGER | Guards, shifts, equipment, K9, incidents |
| SUPERVISOR | Attend, patrols, incidents, reports |
| GUARD | Own profile, patrol scan, incident reporting |
| CLIENT | Client portal — own site reports only |

---

## Database Schema Summary

Key tables: `users`, `roles`, `guards`, `clients`, `sites`, `shifts`, `shift_assignments`, `attendance`, `patrol_checkpoints`, `patrol_logs`, `incidents`, `equipment`, `equipment_assignments`, `equipment_maintenance`, `k9_dogs`, `k9_training_records`, `k9_medical_records`, `k9_deployments`, `liability_reports`, `payroll_periods`, `payslips`, `liability_deduction_applications`, `audit_logs`

---

## Extending the Application

To add a new module (e.g., Payroll):
1. Create `Payslip.java` model in `com.sgms.model`
2. Create `PayslipDAO.java` in `com.sgms.dao`
3. Create `PayrollServlet.java` in `com.sgms.servlet`
4. Create JSP views in `WEB-INF/views/payroll/`
5. Add navigation link in `header.jsp`

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Place MySQL JAR in `$TOMCAT_HOME/lib/` |
| `JNDI lookup failed` | Check `context.xml` credentials; ensure MySQL JAR is in Tomcat lib |
| CSRF token errors | Clear browser cookies/session and retry |
| 403 on admin pages | Verify user role in `users` table |
| Blank pages | Check `$CATALINA_HOME/logs/catalina.out` and `sgms.log` |

---

## License

Internal use. All rights reserved. Kenya PSRA compliance required for production use.

---

*Built for professional private security companies operating in Kenya under the Private Security Regulatory Authority (PSRA) Act.*
