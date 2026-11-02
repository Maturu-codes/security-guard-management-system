package com.sgms.servlet;

import com.sgms.dao.*;
import com.sgms.model.Incident;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private final GuardDAO guardDAO = new GuardDAO();
    private final IncidentDAO incidentDAO = new IncidentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Summary stats
        req.setAttribute("totalActiveGuards", guardDAO.countActive());
        req.setAttribute("openIncidents", incidentDAO.countOpen());

        // Recent critical incidents
        List<Incident> criticalIncidents = incidentDAO.findOpenHighSeverity();
        req.setAttribute("criticalIncidents", criticalIncidents);

        req.getRequestDispatcher("/WEB-INF/views/dashboard/dashboard.jsp").forward(req, resp);
    }
}
