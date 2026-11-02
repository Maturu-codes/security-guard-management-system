package com.sgms.servlet;

import com.sgms.dao.*;
import com.sgms.model.Equipment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

@WebServlet("/equipment/*")
public class EquipmentServlet extends HttpServlet {
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();
    private final GuardDAO guardDAO = new GuardDAO();
    private final AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            req.setAttribute("equipmentList", equipmentDAO.findAll());
            req.setAttribute("totalAvailable", equipmentDAO.countByStatus("AVAILABLE"));
            req.setAttribute("totalAssigned", equipmentDAO.countByStatus("ASSIGNED"));
            req.getRequestDispatcher("/WEB-INF/views/equipment/list.jsp").forward(req, resp);
        } else if (path.equals("/new")) {
            req.getRequestDispatcher("/WEB-INF/views/equipment/form.jsp").forward(req, resp);
        } else if (path.startsWith("/view/")) {
            int id = parseId(path.substring(6));
            Equipment eq = equipmentDAO.findById(id);
            if (eq == null) { resp.sendError(404); return; }
            req.setAttribute("equipment", eq);
            req.setAttribute("assignmentHistory", equipmentDAO.getAssignmentHistory(id));
            req.setAttribute("guards", guardDAO.findActive());
            req.getRequestDispatcher("/WEB-INF/views/equipment/view.jsp").forward(req, resp);
        } else if (path.startsWith("/edit/")) {
            int id = parseId(path.substring(6));
            req.setAttribute("equipment", equipmentDAO.findById(id));
            req.getRequestDispatcher("/WEB-INF/views/equipment/form.jsp").forward(req, resp);
        } else { resp.sendError(404); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        int userId = (Integer) req.getSession().getAttribute("userId");

        if ("/create".equals(path)) {
            Equipment eq = buildFromRequest(req);
            int id = equipmentDAO.create(eq);
            if (id > 0) {
                auditDAO.log(userId, "EQUIPMENT_CREATED", "EQUIPMENT", id, null, null, req.getRemoteAddr(), null);
                req.getSession().setAttribute("successMsg", "Equipment added successfully.");
                resp.sendRedirect(req.getContextPath() + "/equipment/view/" + id);
            } else {
                req.setAttribute("error", "Failed to add equipment. Serial number may already exist.");
                req.getRequestDispatcher("/WEB-INF/views/equipment/form.jsp").forward(req, resp);
            }
        } else if (path != null && path.startsWith("/update/")) {
            int id = parseId(path.substring(8));
            Equipment eq = equipmentDAO.findById(id);
            if (eq == null) { resp.sendError(404); return; }
            eq.setEquipmentType(req.getParameter("equipmentType"));
            eq.setMakeModel(req.getParameter("makeModel"));
            eq.setDescription(req.getParameter("description"));
            eq.setConditionState(req.getParameter("conditionState"));
            eq.setLicenseNumber(req.getParameter("licenseNumber"));
            String le = req.getParameter("licenseExpiry");
            if (le != null && !le.isBlank()) eq.setLicenseExpiry(LocalDate.parse(le));
            eq.setRequiresLicense("on".equals(req.getParameter("requiresLicense")));
            eq.setStatus(req.getParameter("status"));
            eq.setNotes(req.getParameter("notes"));
            equipmentDAO.update(eq);
            resp.sendRedirect(req.getContextPath() + "/equipment/view/" + id);
        } else if (path != null && path.startsWith("/issue/")) {
            int eqId = parseId(path.substring(7));
            int guardId = Integer.parseInt(req.getParameter("guardId"));
            String condition = req.getParameter("conditionOnIssue");
            equipmentDAO.issueToGuard(eqId, guardId, userId, condition);
            auditDAO.log(userId, "EQUIPMENT_ISSUED", "EQUIPMENT", eqId, null, null, req.getRemoteAddr(), null);
            req.getSession().setAttribute("successMsg", "Equipment issued successfully.");
            resp.sendRedirect(req.getContextPath() + "/equipment/view/" + eqId);
        } else if (path != null && path.startsWith("/return/")) {
            int eqId = parseId(path.substring(8));
            String condition = req.getParameter("conditionOnReturn");
            equipmentDAO.returnEquipment(eqId, userId, condition);
            auditDAO.log(userId, "EQUIPMENT_RETURNED", "EQUIPMENT", eqId, null, null, req.getRemoteAddr(), null);
            req.getSession().setAttribute("successMsg", "Equipment returned successfully.");
            resp.sendRedirect(req.getContextPath() + "/equipment/view/" + eqId);
        }
    }

    private Equipment buildFromRequest(HttpServletRequest req) {
        Equipment eq = new Equipment();
        eq.setEquipmentType(req.getParameter("equipmentType"));
        eq.setSerialNumber(req.getParameter("serialNumber"));
        eq.setMakeModel(req.getParameter("makeModel"));
        eq.setDescription(req.getParameter("description"));
        eq.setConditionState(req.getParameter("conditionState"));
        String ad = req.getParameter("acquisitionDate");
        if (ad != null && !ad.isBlank()) eq.setAcquisitionDate(LocalDate.parse(ad));
        String cost = req.getParameter("acquisitionCost");
        if (cost != null && !cost.isBlank()) eq.setAcquisitionCost(new BigDecimal(cost));
        eq.setLicenseNumber(req.getParameter("licenseNumber"));
        String le = req.getParameter("licenseExpiry");
        if (le != null && !le.isBlank()) eq.setLicenseExpiry(LocalDate.parse(le));
        eq.setRequiresLicense("on".equals(req.getParameter("requiresLicense")));
        eq.setNotes(req.getParameter("notes"));
        return eq;
    }

    private int parseId(String s) { try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return -1; } }
}
