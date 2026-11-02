package com.sgms.servlet;

import com.sgms.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/attendance/*")
public class AttendanceServlet extends HttpServlet {
    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final ShiftDAO shiftDAO = new ShiftDAO();
    private final GuardDAO guardDAO = new GuardDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("records", attendanceDAO.findAll());
            req.setAttribute("todayShifts", shiftDAO.findByDate(java.time.LocalDate.now()));
            req.getRequestDispatcher("/WEB-INF/views/attendance/list.jsp").forward(req, resp);
        } else if (path.startsWith("/shift/")) {
            int shiftId = parseId(path.substring(7));
            req.setAttribute("shift", shiftDAO.findById(shiftId));
            req.setAttribute("assignedGuards", shiftDAO.getAssignedGuards(shiftId));
            req.setAttribute("attendanceRecords", attendanceDAO.findByShift(shiftId));
            req.getRequestDispatcher("/WEB-INF/views/attendance/record.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");

        if ("/checkin".equals(path)) {
            int guardId = Integer.parseInt(req.getParameter("guardId"));
            int shiftId = Integer.parseInt(req.getParameter("shiftId"));
            attendanceDAO.checkIn(guardId, shiftId, "MANUAL", userId);
            req.getSession().setAttribute("successMsg", "Check-in recorded.");
            resp.sendRedirect(req.getContextPath() + "/attendance/shift/" + shiftId);
        } else if ("/checkout".equals(path)) {
            int guardId = Integer.parseInt(req.getParameter("guardId"));
            int shiftId = Integer.parseInt(req.getParameter("shiftId"));
            attendanceDAO.checkOut(guardId, shiftId, userId);
            req.getSession().setAttribute("successMsg", "Check-out recorded.");
            resp.sendRedirect(req.getContextPath() + "/attendance/shift/" + shiftId);
        } else if ("/absent".equals(path)) {
            int guardId = Integer.parseInt(req.getParameter("guardId"));
            int shiftId = Integer.parseInt(req.getParameter("shiftId"));
            attendanceDAO.markAbsent(guardId, shiftId, req.getParameter("notes"), userId);
            req.getSession().setAttribute("successMsg", "Absence recorded.");
            resp.sendRedirect(req.getContextPath() + "/attendance/shift/" + shiftId);
        }
    }

    private int parseId(String s) { try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; } }
}
