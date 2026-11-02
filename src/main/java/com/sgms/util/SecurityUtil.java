package com.sgms.util;

import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Security utilities: password hashing, CSRF token generation/validation.
 */
public class SecurityUtil {

    private static final int BCRYPT_LOG_ROUNDS = 12;
    private static final SecureRandom secureRandom = new SecureRandom();
    public static final String CSRF_TOKEN_ATTR = "csrfToken";

    // ---- Password Hashing ----

    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_LOG_ROUNDS));
    }

    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }

    // ---- CSRF Tokens ----

    public static String generateCsrfToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /**
     * Gets existing CSRF token from session or generates a new one.
     */
    public static String getOrCreateCsrfToken(HttpSession session) {
        String token = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (token == null) {
            token = generateCsrfToken();
            session.setAttribute(CSRF_TOKEN_ATTR, token);
        }
        return token;
    }

    /**
     * Validates the CSRF token from a request against the session token.
     */
    public static boolean isValidCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        String requestToken = request.getParameter("csrfToken");

        if (sessionToken == null || requestToken == null) return false;

        // Constant-time comparison to prevent timing attacks
        return constantTimeEquals(sessionToken, requestToken);
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }

    // ---- XSS Prevention ----

    public static String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    // ---- Session Management ----

    public static boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("userId") != null;
    }

    public static Integer getSessionUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (Integer) session.getAttribute("userId");
    }

    public static String getSessionRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute("userRole");
    }

    public static boolean hasRole(HttpServletRequest request, String... roles) {
        String userRole = getSessionRole(request);
        if (userRole == null) return false;
        for (String role : roles) {
            if (role.equalsIgnoreCase(userRole)) return true;
        }
        return false;
    }
}
