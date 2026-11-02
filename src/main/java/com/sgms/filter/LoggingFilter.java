package com.sgms.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

/**
 * Request logging filter — logs all requests with timing and user context.
 */
@WebFilter("/*")
public class LoggingFilter implements Filter {
    private static final Logger logger = LoggerFactory.getLogger(LoggingFilter.class);

    @Override
    public void init(FilterConfig config) {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String requestId = UUID.randomUUID().toString().substring(0, 8);
        long start = System.currentTimeMillis();

        // Set MDC context for structured logging
        MDC.put("requestId", requestId);
        MDC.put("ip", getClientIp(request));

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("username") != null) {
            MDC.put("user", (String) session.getAttribute("username"));
        }

        try {
            String path = request.getRequestURI();
            String method = request.getMethod();
            logger.info("→ {} {}", method, path);

            chain.doFilter(req, res);

            long duration = System.currentTimeMillis() - start;
            logger.info("← {} {} [{}ms] status={}", method, path, duration, response.getStatus());

        } finally {
            MDC.clear();
        }
    }

    public static String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // Take first IP if comma-separated
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip != null ? ip : "unknown";
    }

    @Override
    public void destroy() {}
}
