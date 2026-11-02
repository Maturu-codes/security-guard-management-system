package com.sgms.filter;

import com.sgms.util.SecurityUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Authentication filter: redirects unauthenticated users to login.
 * Also enforces role-based access for sensitive paths.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {
    private static final Logger logger = LoggerFactory.getLogger(AuthFilter.class);

    // Public paths that don't require authentication
    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
        "/login", "/login.jsp", "/error", "/error.jsp",
        "/css/", "/js/", "/images/", "/favicon.ico"
    ));

    // Paths restricted to admin roles only
    private static final Set<String> ADMIN_ONLY_PATHS = new HashSet<>(Arrays.asList(
        "/admin/", "/payroll/process", "/users/delete"
    ));

    // Roles with admin access
    private static final Set<String> ADMIN_ROLES = new HashSet<>(Arrays.asList(
        "SUPER_ADMIN", "COMPANY_ADMIN"
    ));

    @Override
    public void init(FilterConfig config) {
        logger.info("AuthFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String contextPath = request.getContextPath();
        String requestURI = request.getRequestURI();
        String path = requestURI.substring(contextPath.length());

        // Always set security headers
        setSecurityHeaders(response);

        // Allow public resources
        if (isPublicPath(path)) {
            chain.doFilter(req, res);
            return;
        }

        // Check authentication
        HttpSession session = request.getSession(false);
        boolean loggedIn = session != null && session.getAttribute("userId") != null;

        if (!loggedIn) {
            logger.debug("Unauthenticated access attempt: {} -> {}", request.getRemoteAddr(), path);
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // Check role-based access
        if (isAdminOnlyPath(path)) {
            String role = (String) session.getAttribute("userRole");
            if (!ADMIN_ROLES.contains(role)) {
                logger.warn("Unauthorized admin access by user {} role {} to {}",
                    session.getAttribute("userId"), role, path);
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access this resource.");
                return;
            }
        }

        chain.doFilter(req, res);
    }

    private boolean isPublicPath(String path) {
        if (path.equals("/") || path.isEmpty()) return false;
        for (String pub : PUBLIC_PATHS) {
            if (path.equals(pub) || path.startsWith(pub)) return true;
        }
        return false;
    }

    private boolean isAdminOnlyPath(String path) {
        for (String admin : ADMIN_ONLY_PATHS) {
            if (path.startsWith(admin)) return true;
        }
        return false;
    }

    private void setSecurityHeaders(HttpServletResponse response) {
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("X-XSS-Protection", "1; mode=block");
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        response.setHeader("Content-Security-Policy",
            "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; " +
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com; " +
            "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com;");
    }

    @Override
    public void destroy() {}
}
