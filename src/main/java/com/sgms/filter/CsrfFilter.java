package com.sgms.filter;

import com.sgms.util.SecurityUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * CSRF protection filter for all state-changing requests (POST, PUT, DELETE).
 */
@WebFilter("/*")
public class CsrfFilter implements Filter {
    private static final Logger logger = LoggerFactory.getLogger(CsrfFilter.class);

    private static final Set<String> SAFE_METHODS = new HashSet<>(Arrays.asList("GET", "HEAD", "OPTIONS", "TRACE"));

    @Override
    public void init(FilterConfig config) {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String method = request.getMethod().toUpperCase();

        // Only validate CSRF on state-changing methods
        if (!SAFE_METHODS.contains(method)) {
            // Skip CSRF check for login endpoint (no session yet)
            String path = request.getRequestURI().substring(request.getContextPath().length());
            if (!path.equals("/login") && !path.equals("/login.jsp")) {
                if (!SecurityUtil.isValidCsrfToken(request)) {
                    logger.warn("CSRF token validation failed for {} {} from {}",
                        method, path, request.getRemoteAddr());
                    response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "CSRF token validation failed. Please refresh and try again.");
                    return;
                }
            }
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {}
}
