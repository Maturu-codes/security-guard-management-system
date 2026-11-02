package com.sgms.servlet;

import com.sgms.dao.AuditDAO;
import com.sgms.dao.GuardDAO;
import com.sgms.dao.IncidentDAO;
import com.sgms.filter.LoggingFilter;
import com.sgms.model.Guard;
import com.sgms.model.Incident;
import com.sgms.util.SecurityUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/incidents/*")
public class IncidentServlet extends HttpServlet {
    private final IncidentDAO incidentDAO = new IncidentDAO();
    private final GuardDAO guardDAO = new GuardDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();

        if (path == null || path.equals("/")) {
            req.setAttribute("incidents", incidentDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/incidents/list.jsp").forward(req, resp);

        } else if (path.equals("/new")) {
            req.setAttribute("guards", guardDAO.findActive());
            req.getRequestDispatcher("/WEB-INF/views/incidents/form.jsp").forward(req, resp);

        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            Incident incident = incidentDAO.findById(id);
            if (incident == null) { resp.sendError(404); return; }
            req.setAttribute("incident", incident);
            req.getRequestDispatcher("/WEB-INF/views/incidents/view.jsp").forward(req, resp);
        } else {
            resp.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");
        String ip = LoggingFilter.getClientIp(req);

        if ("/create".equals(path)) {
            Incident incident = new Incident();
            incident.setSiteId(Integer.parseInt(req.getParameter("siteId")));
            incident.setGuardId(Integer.parseInt(req.getParameter("guardId")));
            incident.setIncidentType(req.getParameter("incidentType"));
            incident.setSeverity(req.getParameter("severity"));
            incident.setTitle(req.getParameter("title"));
            incident.setDescription(req.getParameter("description"));
            String dt = req.getParameter("incidentDatetime");
            incident.setIncidentDatetime(dt != null && !dt.isBlank()
                ? LocalDateTime.parse(dt) : LocalDateTime.now());
            incident.setLocationDetails(req.getParameter("locationDetails"));
            incident.setActionTaken(req.getParameter("actionTaken"));
            incident.setPoliceReportNumber(req.getParameter("policeReportNumber"));
            incident.setReportedBy(userId);

            int id = incidentDAO.create(incident);
            if (id > 0) {
                auditDAO.log(userId, "INCIDENT_REPORTED", "INCIDENT", id, null, null, ip, null);
                req.getSession().setAttribute("successMsg", "Incident reported successfully.");
                resp.sendRedirect(req.getContextPath() + "/incidents/view/" + id);
            } else {
                req.setAttribute("error", "Failed to save incident.");
                req.setAttribute("guards", guardDAO.findActive());
                req.getRequestDispatcher("/WEB-INF/views/incidents/form.jsp").forward(req, resp);
            }

        } else if (path != null && path.startsWith("/updateStatus/")) {
            int id = parseId(path.substring(14));
            String status = req.getParameter("status");
            incidentDAO.updateStatus(id, status, userId);
            auditDAO.log(userId, "INCIDENT_STATUS_CHANGED", "INCIDENT", id, null, status, ip, null);
            resp.sendRedirect(req.getContextPath() + "/incidents/view/" + id);
        }
    }

    private int parseId(String s) {
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return -1; }
    }
}
