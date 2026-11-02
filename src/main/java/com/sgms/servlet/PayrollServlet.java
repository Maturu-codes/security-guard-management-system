package com.sgms.servlet;

import com.sgms.dao.*;
import com.sgms.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/payroll/*")
public class PayrollServlet extends HttpServlet {
    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!SecurityUtil.hasRole(req, "SUPER_ADMIN", "COMPANY_ADMIN")) {
            resp.sendError(403); return;
        }
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("periods", payrollDAO.findAllPeriods());
            req.getRequestDispatcher("/WEB-INF/views/payroll/list.jsp").forward(req, resp);
        } else if (path.equals("/new")) {
            req.getRequestDispatcher("/WEB-INF/views/payroll/form.jsp").forward(req, resp);
        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            req.setAttribute("period", payrollDAO.getPeriodById(id));
            req.setAttribute("payslips", payrollDAO.getPayslips(id));
            req.getRequestDispatcher("/WEB-INF/views/payroll/view.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!SecurityUtil.hasRole(req, "SUPER_ADMIN", "COMPANY_ADMIN")) {
            resp.sendError(403); return;
        }
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");

        if ("/create".equals(path)) {
            int id = payrollDAO.createPeriod(req.getParameter("periodName"),
                req.getParameter("startDate"), req.getParameter("endDate"),
                req.getParameter("payDate"), userId);
            if (id > 0) {
                req.getSession().setAttribute("successMsg", "Payroll period created. Click 'Process' to generate payslips.");
                resp.sendRedirect(req.getContextPath() + "/payroll/view/" + id);
            } else {
                req.setAttribute("error", "Failed to create payroll period.");
                req.getRequestDispatcher("/WEB-INF/views/payroll/form.jsp").forward(req, resp);
            }
        } else if (path != null && path.startsWith("/process/")) {
            int id = parseId(path.substring(9));
            payrollDAO.processPayroll(id);
            auditDAO.log(userId, "PAYROLL_PROCESSED", "PAYROLL_PERIOD", id, null, null, req.getRemoteAddr(), null);
            req.getSession().setAttribute("successMsg", "Payroll processed successfully. All payslips generated.");
            resp.sendRedirect(req.getContextPath() + "/payroll/view/" + id);
        } else if (path != null && path.startsWith("/approve/")) {
            int id = parseId(path.substring(9));
            payrollDAO.approvePeriod(id, userId);
            auditDAO.log(userId, "PAYROLL_APPROVED", "PAYROLL_PERIOD", id, null, null, req.getRemoteAddr(), null);
            req.getSession().setAttribute("successMsg", "Payroll approved.");
            resp.sendRedirect(req.getContextPath() + "/payroll/view/" + id);
        }
    }

    private int parseId(String s) { try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; } }
}
