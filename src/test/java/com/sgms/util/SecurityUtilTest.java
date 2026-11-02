package com.sgms.util;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class SecurityUtilTest {

    // ---- password hashing ----

    @Test
    @DisplayName("A hashed password verifies against the original and not against another")
    void hashAndVerifyPassword() {
        String hash = SecurityUtil.hashPassword("S3cret!pass");
        assertNotEquals("S3cret!pass", hash);
        assertTrue(SecurityUtil.checkPassword("S3cret!pass", hash));
        assertFalse(SecurityUtil.checkPassword("wrong-pass", hash));
    }

    @Test
    @DisplayName("Hashing the same password twice gives different hashes (random salt)")
    void hashesAreSalted() {
        assertNotEquals(SecurityUtil.hashPassword("same"), SecurityUtil.hashPassword("same"));
    }

    @Test
    @DisplayName("checkPassword fails safely on null or malformed input")
    void checkPasswordHandlesBadInput() {
        assertFalse(SecurityUtil.checkPassword(null, "hash"));
        assertFalse(SecurityUtil.checkPassword("pw", null));
        assertFalse(SecurityUtil.checkPassword("pw", "not-a-bcrypt-hash"));
    }

    // ---- CSRF ----

    @Test
    @DisplayName("CSRF tokens are URL-safe, long enough, and unique")
    void csrfTokenShape() {
        String a = SecurityUtil.generateCsrfToken();
        String b = SecurityUtil.generateCsrfToken();
        assertNotEquals(a, b);
        assertTrue(a.length() >= 43);
        assertTrue(a.matches("[A-Za-z0-9_-]+"));
    }

    @Test
    @DisplayName("getOrCreateCsrfToken creates a token once and stores it in the session")
    void getOrCreateStoresToken() {
        HttpSession session = mock(HttpSession.class);
        when(session.getAttribute(SecurityUtil.CSRF_TOKEN_ATTR)).thenReturn(null);
        String token = SecurityUtil.getOrCreateCsrfToken(session);
        assertNotNull(token);
        org.mockito.Mockito.verify(session).setAttribute(SecurityUtil.CSRF_TOKEN_ATTR, token);
    }

    @Test
    @DisplayName("getOrCreateCsrfToken reuses an existing session token")
    void getOrCreateReusesToken() {
        HttpSession session = mock(HttpSession.class);
        when(session.getAttribute(SecurityUtil.CSRF_TOKEN_ATTR)).thenReturn("existing");
        assertEquals("existing", SecurityUtil.getOrCreateCsrfToken(session));
        org.mockito.Mockito.verify(session, org.mockito.Mockito.never())
                .setAttribute(org.mockito.ArgumentMatchers.anyString(),
                        org.mockito.ArgumentMatchers.any());
    }

    private static HttpServletRequest requestWith(String sessionToken, String requestToken) {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute(SecurityUtil.CSRF_TOKEN_ATTR)).thenReturn(sessionToken);
        when(request.getParameter("csrfToken")).thenReturn(requestToken);
        return request;
    }

    @Test
    @DisplayName("Matching CSRF token is accepted")
    void csrfValid() {
        assertTrue(SecurityUtil.isValidCsrfToken(requestWith("tok123", "tok123")));
    }

    @Test
    @DisplayName("Mismatched, missing or session-less CSRF tokens are rejected")
    void csrfInvalid() {
        assertFalse(SecurityUtil.isValidCsrfToken(requestWith("tok123", "tok124")));
        assertFalse(SecurityUtil.isValidCsrfToken(requestWith("tok123", "short")));
        assertFalse(SecurityUtil.isValidCsrfToken(requestWith("tok123", null)));
        assertFalse(SecurityUtil.isValidCsrfToken(requestWith(null, "tok123")));

        HttpServletRequest noSession = mock(HttpServletRequest.class);
        when(noSession.getSession(false)).thenReturn(null);
        assertFalse(SecurityUtil.isValidCsrfToken(noSession));
    }

    // ---- XSS ----

    @Test
    @DisplayName("escapeHtml neutralises markup and quotes")
    void escapeHtmlEscapesSpecialChars() {
        assertEquals("&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;",
                SecurityUtil.escapeHtml("<script>alert(\"x\")</script>"));
        assertEquals("a &amp; b", SecurityUtil.escapeHtml("a & b"));
        assertEquals("it&#x27;s", SecurityUtil.escapeHtml("it's"));
    }

    @Test
    @DisplayName("escapeHtml returns empty string for null")
    void escapeHtmlNull() {
        assertEquals("", SecurityUtil.escapeHtml(null));
    }

    // ---- sessions and roles ----

    private static HttpServletRequest requestWithSession(Integer userId, String role) {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpSession session = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(userId);
        when(session.getAttribute("userRole")).thenReturn(role);
        return request;
    }

    @Test
    @DisplayName("isLoggedIn depends on a userId in the session")
    void isLoggedIn() {
        assertTrue(SecurityUtil.isLoggedIn(requestWithSession(7, "GUARD")));
        assertFalse(SecurityUtil.isLoggedIn(requestWithSession(null, null)));
        HttpServletRequest noSession = mock(HttpServletRequest.class);
        when(noSession.getSession(false)).thenReturn(null);
        assertFalse(SecurityUtil.isLoggedIn(noSession));
    }

    @Test
    @DisplayName("hasRole matches any listed role, ignoring case")
    void hasRole() {
        HttpServletRequest request = requestWithSession(1, "ops_manager");
        assertTrue(SecurityUtil.hasRole(request, "SUPER_ADMIN", "OPS_MANAGER"));
        assertFalse(SecurityUtil.hasRole(request, "SUPER_ADMIN", "GUARD"));
    }

    @Test
    @DisplayName("hasRole is false when no one is logged in")
    void hasRoleWithoutSession() {
        HttpServletRequest noSession = mock(HttpServletRequest.class);
        when(noSession.getSession(false)).thenReturn(null);
        assertFalse(SecurityUtil.hasRole(noSession, "GUARD"));
    }
}
