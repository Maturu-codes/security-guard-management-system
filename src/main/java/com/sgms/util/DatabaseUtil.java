package com.sgms.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database connection utility using connection pooling via JNDI (preferred)
 * or direct JDBC as fallback.
 */
public class DatabaseUtil {
    private static final Logger logger = LoggerFactory.getLogger(DatabaseUtil.class);
    private static DataSource dataSource;
    private static String jdbcUrl;
    private static String jdbcUser;
    private static String jdbcPassword;

    static {
        try {
            // Try JNDI DataSource first (Tomcat connection pool)
            Context ctx = new InitialContext();
            dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/sgms");
            logger.info("JNDI DataSource initialized successfully.");
        } catch (Exception e) {
            logger.warn("JNDI lookup failed, falling back to direct JDBC: {}", e.getMessage());
            initDirectJdbc();
        }
    }

    private static void initDirectJdbc() {
        try (InputStream is = DatabaseUtil.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            props.load(is);
            // Environment variables take priority so no credentials live in the repo.
            jdbcUrl = firstNonBlank(System.getenv("DB_URL"), props.getProperty("db.url"));
            jdbcUser = firstNonBlank(System.getenv("DB_USER"), props.getProperty("db.username"));
            jdbcPassword = firstNonBlank(System.getenv("DB_PASSWORD"), props.getProperty("db.password"));
            Class.forName(props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            logger.info("Direct JDBC initialized: {}", jdbcUrl);
        } catch (Exception e) {
            logger.error("Failed to initialize database connection: {}", e.getMessage(), e);
            throw new RuntimeException("Database initialization failed", e);
        }
    }

    static String firstNonBlank(String first, String second) {
        return (first != null && !first.trim().isEmpty()) ? first : second;
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource != null) {
            return dataSource.getConnection();
        }
        return DriverManager.getConnection(jdbcUrl, jdbcUser, jdbcPassword);
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); }
                catch (Exception e) { logger.warn("Error closing resource: {}", e.getMessage()); }
            }
        }
    }
}
