package com.sgms.dao;

import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class LiabilityDAO {
    private static final Logger logger = LoggerFactory.getLogger(LiabilityDAO.class);

    public List<Map<String,Object>> findAll() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT lr.*, CONCAT(u.first_name,' ',u.last_name) as guard_name, g.employee_number " +
                     "FROM liability_reports lr " +
                     "JOIN guards g ON lr.guard_id = g.id JOIN users u ON g.user_id = u.id " +
                     "ORDER BY lr.created_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findAll liability: {}", e.getMessage(), e); }
        return list;
    }

    public Map<String,Object> findById(int id) {
        String sql = "SELECT lr.*, CONCAT(u.first_name,' ',u.last_name) as guard_name, g.employee_number " +
                     "FROM liability_reports lr " +
                     "JOIN guards g ON lr.guard_id = g.id JOIN users u ON g.user_id = u.id " +
                     "WHERE lr.id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { logger.error("findById liability: {}", e.getMessage(), e); }
        return null;
    }

    public int create(int guardId, Integer incidentId, Integer equipmentId, Integer dogId,
                      String liabilityType, String description, String severity,
                      BigDecimal estimatedCost, String evidenceNotes, int createdBy) {
        String sql = "INSERT INTO liability_reports (guard_id, incident_id, equipment_id, dog_id, liability_type, description, severity, estimated_cost, evidence_notes, created_by) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, guardId);
            ps.setObject(2, incidentId);
            ps.setObject(3, equipmentId);
            ps.setObject(4, dogId);
            ps.setString(5, liabilityType);
            ps.setString(6, description);
            ps.setString(7, severity != null ? severity : "MODERATE");
            ps.setBigDecimal(8, estimatedCost);
            ps.setString(9, evidenceNotes);
            ps.setInt(10, createdBy);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { logger.error("create liability: {}", e.getMessage(), e); }
        return -1;
    }

    public boolean approve(int id, String role, int reviewerId, BigDecimal approvedDeduction, String notes) {
        String statusNew;
        String sql;
        switch (role) {
            case "SUPERVISOR":
                statusNew = "SUPERVISOR_APPROVED";
                sql = "UPDATE liability_reports SET status=?, supervisor_id=?, supervisor_notes=?, supervisor_reviewed_at=NOW(), approved_deduction=? WHERE id=?";
                break;
            case "MANAGER":
                statusNew = "MANAGER_APPROVED";
                sql = "UPDATE liability_reports SET status=?, manager_id=?, manager_notes=?, manager_reviewed_at=NOW(), approved_deduction=? WHERE id=?";
                break;
            case "HR":
                statusNew = "HR_APPROVED";
                sql = "UPDATE liability_reports SET status=?, hr_id=?, hr_notes=?, hr_reviewed_at=NOW(), approved_deduction=? WHERE id=?";
                break;
            default:
                return false;
        }
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusNew);
            ps.setInt(2, reviewerId);
            ps.setString(3, notes);
            ps.setBigDecimal(4, approvedDeduction);
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("approve liability: {}", e.getMessage(), e); }
        return false;
    }

    public boolean reject(int id, int reviewerId, String notes) {
        String sql = "UPDATE liability_reports SET status='REJECTED', supervisor_id=?, supervisor_notes=?, supervisor_reviewed_at=NOW() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewerId); ps.setString(2, notes); ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("reject liability: {}", e.getMessage(), e); }
        return false;
    }

    public long countPending() {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM liability_reports WHERE status='PENDING'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countPending: {}", e.getMessage()); }
        return 0;
    }

    private Map<String,Object> mapRow(ResultSet rs) throws SQLException {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("id", rs.getInt("id"));
        m.put("guardId", rs.getInt("guard_id"));
        m.put("guardName", rs.getString("guard_name"));
        m.put("employeeNumber", rs.getString("employee_number"));
        m.put("liabilityType", rs.getString("liability_type"));
        m.put("description", rs.getString("description"));
        m.put("severity", rs.getString("severity"));
        m.put("estimatedCost", rs.getBigDecimal("estimated_cost"));
        m.put("approvedDeduction", rs.getBigDecimal("approved_deduction"));
        m.put("evidenceNotes", rs.getString("evidence_notes"));
        m.put("status", rs.getString("status"));
        m.put("supervisorNotes", rs.getString("supervisor_notes"));
        m.put("managerNotes", rs.getString("manager_notes"));
        m.put("hrNotes", rs.getString("hr_notes"));
        m.put("createdAt", rs.getTimestamp("created_at"));
        return m;
    }
}
