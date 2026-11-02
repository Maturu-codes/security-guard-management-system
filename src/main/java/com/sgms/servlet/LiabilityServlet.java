package com.sgms.servlet;

import com.sgms.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

@WebServlet("/liability/*")
public class LiabilityServlet extends HttpServlet {
    private final LiabilityDAO liabilityDAO = new LiabilityDAO();
    private final GuardDAO guardDAO = new GuardDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("reports", liabilityDAO.findAll());
            req.setAttribute("pendingCount", liabilityDAO.countPending());
            req.getRequestDispatcher("/WEB-INF/views/liability/list.jsp").forward(req, resp);
        } else if (path.equals("/new")) {
            req.setAttribute("guards", guardDAO.findActive());
            req.getRequestDispatcher("/WEB-INF/views/liability/form.jsp").forward(req, resp);
        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            Map<String,Object> report = liabilityDAO.findById(id);
            if (report == null) { resp.sendError(404); return; }
            req.setAttribute("report", report);
            req.getRequestDispatcher("/WEB-INF/views/liability/view.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");
        String role = (String) req.getSession().getAttribute("userRole");

        if ("/create".equals(path)) {
            String costStr = req.getParameter("estimatedCost");
            BigDecimal cost = costStr != null && !costStr.isBlank() ? new BigDecimal(costStr) : BigDecimal.ZERO;
            String incStr = req.getParameter("incidentId");
            String eqStr = req.getParameter("equipmentId");
            String dogStr = req.getParameter("dogId");
            int id = liabilityDAO.create(
                Integer.parseInt(req.getParameter("guardId")),
                incStr != null && !incStr.isBlank() ? Integer.parseInt(incStr) : null,
                eqStr != null && !eqStr.isBlank() ? Integer.parseInt(eqStr) : null,
                dogStr != null && !dogStr.isBlank() ? Integer.parseInt(dogStr) : null,
                req.getParameter("liabilityType"), req.getParameter("description"),
                req.getParameter("severity"), cost, req.getParameter("evidenceNotes"), userId);
            if (id > 0) {
                auditDAO.log(userId, "LIABILITY_CREATED", "LIABILITY_REPORT", id, null, null, req.getRemoteAddr(), null);
                req.getSession().setAttribute("successMsg", "Liability report submitted.");
                resp.sendRedirect(req.getContextPath() + "/liability/view/" + id);
            } else {
                req.setAttribute("error", "Failed to submit report.");
                req.setAttribute("guards", guardDAO.findActive());
                req.getRequestDispatcher("/WEB-INF/views/liability/form.jsp").forward(req, resp);
            }
        } else if (path != null && path.startsWith("/approve/")) {
            int id = parseId(path.substring(9));
            String costStr = req.getParameter("approvedDeduction");
            BigDecimal approved = costStr != null && !costStr.isBlank() ? new BigDecimal(costStr) : BigDecimal.ZERO;
            String reviewRole = determineReviewRole(role);
            liabilityDAO.approve(id, reviewRole, userId, approved, req.getParameter("notes"));
            auditDAO.log(userId, "LIABILITY_APPROVED", "LIABILITY_REPORT", id, null, null, req.getRemoteAddr(), null);
            req.getSession().setAttribute("successMsg", "Report approved.");
            resp.sendRedirect(req.getContextPath() + "/liability/view/" + id);
        } else if (path != null && path.startsWith("/reject/")) {
            int id = parseId(path.substring(8));
            liabilityDAO.reject(id, userId, req.getParameter("notes"));
            auditDAO.log(userId, "LIABILITY_REJECTED", "LIABILITY_REPORT", id, null, null, req.getRemoteAddr(), null);
            req.getSession().setAttribute("successMsg", "Report rejected.");
            resp.sendRedirect(req.getContextPath() + "/liability/view/" + id);
        }
    }

    private String determineReviewRole(String sessionRole) {
        if ("SUPERVISOR".equals(sessionRole)) return "SUPERVISOR";
        if ("OPERATIONS_MANAGER".equals(sessionRole)) return "MANAGER";
        if ("SUPER_ADMIN".equals(sessionRole) || "COMPANY_ADMIN".equals(sessionRole)) return "HR";
        return "SUPERVISOR";
    }

    private int parseId(String s) { try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; } }
}
