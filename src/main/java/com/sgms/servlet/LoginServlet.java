package com.sgms.servlet;

import com.sgms.dao.AuditDAO;
import com.sgms.dao.UserDAO;
import com.sgms.filter.LoggingFilter;
import com.sgms.model.User;
import com.sgms.util.SecurityUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(LoginServlet.class);
    private final UserDAO userDAO = new UserDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        if (SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        // Generate CSRF token for the login form
        HttpSession session = req.getSession(true);
        SecurityUtil.getOrCreateCsrfToken(session);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String ip = LoggingFilter.getClientIp(req);

        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByUsername(username.trim());

        if (user == null || !SecurityUtil.checkPassword(password, user.getPasswordHash())) {
            logger.warn("Failed login attempt for username='{}' from {}", username, ip);
            auditDAO.log(null, "LOGIN_FAILED", ip);
            req.setAttribute("error", "Invalid username or password.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        if (!user.isActive()) {
            req.setAttribute("error", "Your account has been deactivated. Contact your administrator.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        // Invalidate old session to prevent session fixation
        HttpSession oldSession = req.getSession(false);
        if (oldSession != null) oldSession.invalidate();

        // Create new session
        HttpSession session = req.getSession(true);
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("userRole", user.getRoleName());
        session.setAttribute("userFullName", user.getFullName());
        session.setMaxInactiveInterval(60 * 30); // 30 minutes

        // Generate CSRF token for the new session
        SecurityUtil.getOrCreateCsrfToken(session);

        // Update last login
        userDAO.updateLastLogin(user.getId());
        auditDAO.log(user.getId(), "LOGIN_SUCCESS", ip);

        logger.info("User '{}' (role: {}) logged in from {}", username, user.getRoleName(), ip);

        // Role-based redirect
        String redirect = getRoleRedirect(req.getContextPath(), user.getRoleName());
        resp.sendRedirect(redirect);
    }

    private String getRoleRedirect(String ctx, String role) {
        switch (role) {
            case "CLIENT": return ctx + "/client/dashboard";
            default: return ctx + "/dashboard";
        }
    }
}
