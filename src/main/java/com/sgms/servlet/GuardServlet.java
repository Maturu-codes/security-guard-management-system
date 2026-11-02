package com.sgms.servlet;

import com.sgms.dao.AuditDAO;
import com.sgms.dao.GuardDAO;
import com.sgms.dao.UserDAO;
import com.sgms.filter.LoggingFilter;
import com.sgms.model.Guard;
import com.sgms.model.User;
import com.sgms.util.SecurityUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/guards/*")
public class GuardServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(GuardServlet.class);
    private final GuardDAO guardDAO = new GuardDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            // List all guards
            List<Guard> guards = guardDAO.findAll();
            req.setAttribute("guards", guards);
            req.getRequestDispatcher("/WEB-INF/views/guards/list.jsp").forward(req, resp);

        } else if (pathInfo.equals("/new")) {
            // Show create form
            checkRole(req, resp, "SUPER_ADMIN", "COMPANY_ADMIN", "OPERATIONS_MANAGER");
            req.getRequestDispatcher("/WEB-INF/views/guards/form.jsp").forward(req, resp);

        } else if (pathInfo.startsWith("/edit/")) {
            // Show edit form
            checkRole(req, resp, "SUPER_ADMIN", "COMPANY_ADMIN", "OPERATIONS_MANAGER");
            int id = parseId(pathInfo.substring(6));
            Guard guard = guardDAO.findById(id);
            if (guard == null) { resp.sendError(404); return; }
            req.setAttribute("guard", guard);
            req.getRequestDispatcher("/WEB-INF/views/guards/form.jsp").forward(req, resp);

        } else if (pathInfo.startsWith("/view/")) {
            int id = parseId(pathInfo.substring(6));
            Guard guard = guardDAO.findById(id);
            if (guard == null) { resp.sendError(404); return; }
            req.setAttribute("guard", guard);
            req.getRequestDispatcher("/WEB-INF/views/guards/view.jsp").forward(req, resp);
        } else {
            resp.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");
        String ip = LoggingFilter.getClientIp(req);

        if ("/create".equals(pathInfo)) {
            createGuard(req, resp, userId, ip);
        } else if (pathInfo != null && pathInfo.startsWith("/update/")) {
            int id = parseId(pathInfo.substring(8));
            updateGuard(req, resp, id, userId, ip);
        } else if (pathInfo != null && pathInfo.startsWith("/status/")) {
            int id = parseId(pathInfo.substring(8));
            String status = req.getParameter("status");
            Guard guard = guardDAO.findById(id);
            if (guard != null) {
                guard.setStatus(status);
                guardDAO.update(guard);
                auditDAO.log(userId, "GUARD_STATUS_CHANGE", "GUARD", id, null, status, ip, null);
            }
            resp.sendRedirect(req.getContextPath() + "/guards");
        } else {
            resp.sendError(404);
        }
    }

    private void createGuard(HttpServletRequest req, HttpServletResponse resp, int userId, String ip)
            throws ServletException, IOException {

        // First create user account for the guard
        User user = new User();
        user.setUsername(req.getParameter("username"));
        user.setEmail(req.getParameter("email"));
        user.setFirstName(req.getParameter("firstName"));
        user.setLastName(req.getParameter("lastName"));
        user.setPhone(req.getParameter("phone"));
        user.setRoleId(5); // GUARD role
        user.setPasswordHash(SecurityUtil.hashPassword(req.getParameter("tempPassword")));

        int newUserId = userDAO.create(user);
        if (newUserId < 0) {
            req.setAttribute("error", "Failed to create user account. Username or email may already exist.");
            req.getRequestDispatcher("/WEB-INF/views/guards/form.jsp").forward(req, resp);
            return;
        }

        Guard guard = buildGuardFromRequest(req, newUserId);
        int guardId = guardDAO.create(guard);

        if (guardId > 0) {
            auditDAO.log(userId, "GUARD_CREATED", "GUARD", guardId, null, null, ip, null);
            req.getSession().setAttribute("successMsg", "Guard created successfully.");
            resp.sendRedirect(req.getContextPath() + "/guards/view/" + guardId);
        } else {
            req.setAttribute("error", "Failed to create guard profile.");
            req.getRequestDispatcher("/WEB-INF/views/guards/form.jsp").forward(req, resp);
        }
    }

    private void updateGuard(HttpServletRequest req, HttpServletResponse resp, int id, int userId, String ip)
            throws ServletException, IOException {
        Guard guard = guardDAO.findById(id);
        if (guard == null) { resp.sendError(404); return; }

        guard.setNationalId(req.getParameter("nationalId"));
        guard.setKraPin(req.getParameter("kraPin"));
        guard.setNssfNumber(req.getParameter("nssfNumber"));
        guard.setNhifNumber(req.getParameter("nhifNumber"));
        guard.setGender(req.getParameter("gender"));
        guard.setEmploymentType(req.getParameter("employmentType"));
        String salary = req.getParameter("basicSalary");
        if (salary != null && !salary.isBlank()) {
            guard.setBasicSalary(new BigDecimal(salary));
        }
        guard.setBankName(req.getParameter("bankName"));
        guard.setBankAccount(req.getParameter("bankAccount"));
        guard.setEmergencyContactName(req.getParameter("emergencyContactName"));
        guard.setEmergencyContactPhone(req.getParameter("emergencyContactPhone"));
        guard.setPsvBadgeNumber(req.getParameter("psvBadgeNumber"));
        String psvExpiry = req.getParameter("psvExpiry");
        if (psvExpiry != null && !psvExpiry.isBlank()) {
            guard.setPsvExpiry(LocalDate.parse(psvExpiry));
        }
        guard.setK9Handler("true".equals(req.getParameter("isK9Handler")));
        guard.setStatus(req.getParameter("status"));

        if (guardDAO.update(guard)) {
            auditDAO.log(userId, "GUARD_UPDATED", "GUARD", id, null, null, ip, null);
            req.getSession().setAttribute("successMsg", "Guard updated successfully.");
            resp.sendRedirect(req.getContextPath() + "/guards/view/" + id);
        } else {
            req.setAttribute("error", "Update failed.");
            req.setAttribute("guard", guard);
            req.getRequestDispatcher("/WEB-INF/views/guards/form.jsp").forward(req, resp);
        }
    }

    private Guard buildGuardFromRequest(HttpServletRequest req, int userId) {
        Guard g = new Guard();
        g.setUserId(userId);
        g.setEmployeeNumber(req.getParameter("employeeNumber"));
        g.setNationalId(req.getParameter("nationalId"));
        g.setKraPin(req.getParameter("kraPin"));
        g.setNssfNumber(req.getParameter("nssfNumber"));
        g.setNhifNumber(req.getParameter("nhifNumber"));
        String dob = req.getParameter("dateOfBirth");
        if (dob != null && !dob.isBlank()) g.setDateOfBirth(LocalDate.parse(dob));
        g.setGender(req.getParameter("gender"));
        String hireDate = req.getParameter("hireDate");
        if (hireDate != null && !hireDate.isBlank()) g.setHireDate(LocalDate.parse(hireDate));
        g.setEmploymentType(req.getParameter("employmentType"));
        String salary = req.getParameter("basicSalary");
        if (salary != null && !salary.isBlank()) g.setBasicSalary(new BigDecimal(salary));
        g.setBankName(req.getParameter("bankName"));
        g.setBankAccount(req.getParameter("bankAccount"));
        g.setEmergencyContactName(req.getParameter("emergencyContactName"));
        g.setEmergencyContactPhone(req.getParameter("emergencyContactPhone"));
        g.setPsvBadgeNumber(req.getParameter("psvBadgeNumber"));
        String psvExpiry = req.getParameter("psvExpiry");
        if (psvExpiry != null && !psvExpiry.isBlank()) g.setPsvExpiry(LocalDate.parse(psvExpiry));
        g.setK9Handler("on".equals(req.getParameter("isK9Handler")));
        g.setStatus("ACTIVE");
        return g;
    }

    private void checkRole(HttpServletRequest req, HttpServletResponse resp, String... roles)
            throws IOException {
        if (!SecurityUtil.hasRole(req, roles)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
    }

    private int parseId(String s) {
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return -1; }
    }
}
