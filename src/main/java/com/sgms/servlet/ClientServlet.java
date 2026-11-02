package com.sgms.servlet;

import com.sgms.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/clients/*")
public class ClientServlet extends HttpServlet {
    private final ClientDAO clientDAO = new ClientDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("clients", clientDAO.findAll());
            req.setAttribute("sites", clientDAO.findAllSites());
            req.getRequestDispatcher("/WEB-INF/views/clients/list.jsp").forward(req, resp);
        } else if (path.equals("/new")) {
            req.getRequestDispatcher("/WEB-INF/views/clients/form.jsp").forward(req, resp);
        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            req.setAttribute("client", clientDAO.findById(id));
            req.setAttribute("sites", clientDAO.findSitesByClient(id));
            req.getRequestDispatcher("/WEB-INF/views/clients/view.jsp").forward(req, resp);
        } else if (path.startsWith("/edit/")) {
            int id = parseId(path.substring(6));
            req.setAttribute("client", clientDAO.findById(id));
            req.getRequestDispatcher("/WEB-INF/views/clients/form.jsp").forward(req, resp);
        } else if (path.equals("/site/new")) {
            req.setAttribute("clients", clientDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/clients/site-form.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");
        if ("/create".equals(path)) {
            int id = clientDAO.create(req.getParameter("companyName"), req.getParameter("contactPerson"),
                req.getParameter("email"), req.getParameter("phone"), req.getParameter("address"),
                req.getParameter("contractStart"), req.getParameter("contractEnd"));
            if (id > 0) {
                auditDAO.log(userId, "CLIENT_CREATED", "CLIENT", id, null, null, req.getRemoteAddr(), null);
                req.getSession().setAttribute("successMsg", "Client created successfully.");
                resp.sendRedirect(req.getContextPath() + "/clients/view/" + id);
            } else {
                req.setAttribute("error", "Failed to create client.");
                req.getRequestDispatcher("/WEB-INF/views/clients/form.jsp").forward(req, resp);
            }
        } else if (path != null && path.startsWith("/update/")) {
            int id = parseId(path.substring(8));
            clientDAO.update(id, req.getParameter("companyName"), req.getParameter("contactPerson"),
                req.getParameter("email"), req.getParameter("phone"), req.getParameter("address"),
                req.getParameter("contractStart"), req.getParameter("contractEnd"),
                "on".equals(req.getParameter("isActive")));
            resp.sendRedirect(req.getContextPath() + "/clients/view/" + id);
        } else if ("/site/create".equals(path)) {
            int clientId = Integer.parseInt(req.getParameter("clientId"));
            String rg = req.getParameter("requiredGuards");
            clientDAO.createSite(clientId, req.getParameter("siteName"), req.getParameter("address"),
                req.getParameter("siteType"), req.getParameter("riskLevel"),
                rg != null && !rg.isBlank() ? Integer.parseInt(rg) : 1);
            req.getSession().setAttribute("successMsg", "Site added successfully.");
            resp.sendRedirect(req.getContextPath() + "/clients/view/" + clientId);
        }
    }

    private int parseId(String s) { try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; } }
}
