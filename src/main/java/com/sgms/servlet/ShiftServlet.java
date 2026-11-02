package com.sgms.servlet;

import com.sgms.dao.*;
import com.sgms.model.*;
import com.sgms.util.SecurityUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/shifts/*")
public class ShiftServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ShiftServlet.class);
    private final ShiftDAO shiftDAO = new ShiftDAO();
    private final ClientDAO clientDAO = new ClientDAO();
    private final GuardDAO guardDAO = new GuardDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("shifts", shiftDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/shifts/list.jsp").forward(req, resp);
        } else if (path.equals("/new")) {
            req.setAttribute("sites", clientDAO.findAllSites());
            req.getRequestDispatcher("/WEB-INF/views/shifts/form.jsp").forward(req, resp);
        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            Shift shift = shiftDAO.findById(id);
            if (shift == null) { resp.sendError(404); return; }
            req.setAttribute("shift", shift);
            req.setAttribute("assignedGuards", shiftDAO.getAssignedGuards(id));
            req.setAttribute("availableGuards", guardDAO.findActive());
            req.getRequestDispatcher("/WEB-INF/views/shifts/view.jsp").forward(req, resp);
        } else if (path.startsWith("/edit/")) {
            int id = parseId(path.substring(6));
            Shift shift = shiftDAO.findById(id);
            if (shift == null) { resp.sendError(404); return; }
            req.setAttribute("shift", shift);
            req.setAttribute("sites", clientDAO.findAllSites());
            req.getRequestDispatcher("/WEB-INF/views/shifts/form.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");

        if ("/create".equals(path)) {
            Shift shift = new Shift();
            shift.setSiteId(Integer.parseInt(req.getParameter("siteId")));
            shift.setShiftName(req.getParameter("shiftName"));
            String st = req.getParameter("startTime");
            if (st != null && !st.isBlank()) shift.setStartTime(LocalTime.parse(st));
            String et = req.getParameter("endTime");
            if (et != null && !et.isBlank()) shift.setEndTime(LocalTime.parse(et));
            String sd = req.getParameter("shiftDate");
            if (sd != null && !sd.isBlank()) shift.setShiftDate(LocalDate.parse(sd));
            String rg = req.getParameter("requiredGuards");
            shift.setRequiredGuards(rg != null && !rg.isBlank() ? Integer.parseInt(rg) : 1);
            shift.setCreatedBy(userId);
            int id = shiftDAO.create(shift);
            if (id > 0) {
                auditDAO.log(userId, "SHIFT_CREATED", "SHIFT", id, null, null, req.getRemoteAddr(), null);
                req.getSession().setAttribute("successMsg", "Shift created successfully.");
                resp.sendRedirect(req.getContextPath() + "/shifts/view/" + id);
            } else {
                req.setAttribute("error", "Failed to create shift.");
                req.setAttribute("sites", clientDAO.findAllSites());
                req.getRequestDispatcher("/WEB-INF/views/shifts/form.jsp").forward(req, resp);
            }
        } else if (path != null && path.startsWith("/update/")) {
            int id = parseId(path.substring(8));
            Shift shift = shiftDAO.findById(id);
            if (shift == null) { resp.sendError(404); return; }
            shift.setSiteId(Integer.parseInt(req.getParameter("siteId")));
            shift.setShiftName(req.getParameter("shiftName"));
            String st = req.getParameter("startTime");
            if (st != null && !st.isBlank()) shift.setStartTime(LocalTime.parse(st));
            String et = req.getParameter("endTime");
            if (et != null && !et.isBlank()) shift.setEndTime(LocalTime.parse(et));
            String sd = req.getParameter("shiftDate");
            if (sd != null && !sd.isBlank()) shift.setShiftDate(LocalDate.parse(sd));
            shift.setStatus(req.getParameter("status"));
            shiftDAO.update(shift);
            resp.sendRedirect(req.getContextPath() + "/shifts/view/" + id);
        } else if (path != null && path.startsWith("/assign/")) {
            int shiftId = parseId(path.substring(8));
            int guardId = Integer.parseInt(req.getParameter("guardId"));
            shiftDAO.assignGuard(shiftId, guardId, userId);
            req.getSession().setAttribute("successMsg", "Guard assigned successfully.");
            resp.sendRedirect(req.getContextPath() + "/shifts/view/" + shiftId);
        } else if (path != null && path.startsWith("/delete/")) {
            int id = parseId(path.substring(8));
            shiftDAO.delete(id);
            req.getSession().setAttribute("successMsg", "Shift deleted.");
            resp.sendRedirect(req.getContextPath() + "/shifts");
        }
    }

    private int parseId(String s) {
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; }
    }
}
