package com.sgms.servlet;

import com.sgms.dao.*;
import com.sgms.model.K9Dog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

@WebServlet("/k9/*")
public class K9Servlet extends HttpServlet {
    private final K9DAO k9DAO = new K9DAO();
    private final GuardDAO guardDAO = new GuardDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("dogs", k9DAO.findAll());
            req.setAttribute("activeCount", k9DAO.countActive());
            req.getRequestDispatcher("/WEB-INF/views/k9/list.jsp").forward(req, resp);
        } else if (path.equals("/new")) {
            req.setAttribute("handlers", guardDAO.findK9Handlers());
            req.getRequestDispatcher("/WEB-INF/views/k9/form.jsp").forward(req, resp);
        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            K9Dog dog = k9DAO.findById(id);
            if (dog == null) { resp.sendError(404); return; }
            req.setAttribute("dog", dog);
            req.setAttribute("medicalRecords", k9DAO.getMedicalRecords(id));
            req.setAttribute("trainingRecords", k9DAO.getTrainingRecords(id));
            req.setAttribute("handlers", guardDAO.findK9Handlers());
            req.getRequestDispatcher("/WEB-INF/views/k9/view.jsp").forward(req, resp);
        } else if (path.startsWith("/edit/")) {
            int id = parseId(path.substring(6));
            req.setAttribute("dog", k9DAO.findById(id));
            req.setAttribute("handlers", guardDAO.findK9Handlers());
            req.getRequestDispatcher("/WEB-INF/views/k9/form.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");

        if ("/create".equals(path)) {
            K9Dog dog = buildFromRequest(req);
            int id = k9DAO.create(dog);
            if (id > 0) {
                auditDAO.log(userId, "K9_CREATED", "K9_DOG", id, null, null, req.getRemoteAddr(), null);
                req.getSession().setAttribute("successMsg", "K9 unit added successfully.");
                resp.sendRedirect(req.getContextPath() + "/k9/view/" + id);
            } else {
                req.setAttribute("error", "Failed to add K9 unit.");
                req.setAttribute("handlers", guardDAO.findK9Handlers());
                req.getRequestDispatcher("/WEB-INF/views/k9/form.jsp").forward(req, resp);
            }
        } else if (path != null && path.startsWith("/update/")) {
            int id = parseId(path.substring(8));
            K9Dog dog = k9DAO.findById(id);
            if (dog == null) { resp.sendError(404); return; }
            dog.setName(req.getParameter("name"));
            dog.setBreed(req.getParameter("breed"));
            dog.setTrainingLevel(req.getParameter("trainingLevel"));
            dog.setSpecialization(req.getParameter("specialization"));
            dog.setStatus(req.getParameter("status"));
            dog.setNotes(req.getParameter("notes"));
            String handlerStr = req.getParameter("currentHandlerId");
            dog.setCurrentHandlerId(handlerStr != null && !handlerStr.isBlank() ? Integer.parseInt(handlerStr) : null);
            k9DAO.update(dog);
            resp.sendRedirect(req.getContextPath() + "/k9/view/" + id);
        } else if (path != null && path.startsWith("/medical/")) {
            int dogId = parseId(path.substring(9));
            String cost = req.getParameter("cost");
            k9DAO.addMedicalRecord(dogId,
                req.getParameter("recordType"), req.getParameter("description"),
                req.getParameter("vetName"), req.getParameter("visitDate"),
                req.getParameter("nextVisitDate"),
                cost != null && !cost.isBlank() ? new BigDecimal(cost) : null, userId);
            req.getSession().setAttribute("successMsg", "Medical record added.");
            resp.sendRedirect(req.getContextPath() + "/k9/view/" + dogId);
        }
    }

    private K9Dog buildFromRequest(HttpServletRequest req) {
        K9Dog d = new K9Dog();
        d.setName(req.getParameter("name"));
        d.setBreed(req.getParameter("breed"));
        String dob = req.getParameter("dateOfBirth");
        if (dob != null && !dob.isBlank()) d.setDateOfBirth(LocalDate.parse(dob));
        d.setGender(req.getParameter("gender"));
        d.setChipNumber(req.getParameter("chipNumber"));
        d.setTrainingLevel(req.getParameter("trainingLevel"));
        d.setSpecialization(req.getParameter("specialization"));
        String acq = req.getParameter("acquiredDate");
        if (acq != null && !acq.isBlank()) d.setAcquiredDate(LocalDate.parse(acq));
        String handlerId = req.getParameter("currentHandlerId");
        if (handlerId != null && !handlerId.isBlank()) d.setCurrentHandlerId(Integer.parseInt(handlerId));
        d.setNotes(req.getParameter("notes"));
        return d;
    }

    private int parseId(String s) { try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; } }
}
