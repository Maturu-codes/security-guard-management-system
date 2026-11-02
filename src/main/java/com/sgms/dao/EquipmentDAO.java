package com.sgms.dao;

import com.sgms.model.Equipment;
import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.*;

public class EquipmentDAO {
    private static final Logger logger = LoggerFactory.getLogger(EquipmentDAO.class);

    private static final String SELECT_BASE =
        "SELECT e.*, CONCAT(u.first_name,' ',u.last_name) as assignee_name, s.site_name " +
        "FROM equipment e " +
        "LEFT JOIN guards g ON e.current_assignee_id = g.id " +
        "LEFT JOIN users u ON g.user_id = u.id " +
        "LEFT JOIN sites s ON e.current_site_id = s.id ";

    public List<Equipment> findAll() {
        List<Equipment> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "ORDER BY e.equipment_type, e.serial_number");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findAll equipment: {}", e.getMessage(), e); }
        return list;
    }

    public Equipment findById(int id) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "WHERE e.id = ?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { logger.error("findById equipment: {}", e.getMessage(), e); }
        return null;
    }

    public List<Equipment> findAvailable() {
        List<Equipment> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "WHERE e.status = 'AVAILABLE' ORDER BY e.equipment_type")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findAvailable: {}", e.getMessage(), e); }
        return list;
    }

    public int create(Equipment eq) {
        String sql = "INSERT INTO equipment (equipment_type, serial_number, make_model, description, condition_state, " +
                     "acquisition_date, acquisition_cost, license_number, license_expiry, requires_license, status, notes) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, eq.getEquipmentType());
            ps.setString(2, eq.getSerialNumber());
            ps.setString(3, eq.getMakeModel());
            ps.setString(4, eq.getDescription());
            ps.setString(5, eq.getConditionState() != null ? eq.getConditionState() : "GOOD");
            ps.setObject(6, eq.getAcquisitionDate());
            ps.setBigDecimal(7, eq.getAcquisitionCost());
            ps.setString(8, eq.getLicenseNumber());
            ps.setObject(9, eq.getLicenseExpiry());
            ps.setBoolean(10, eq.isRequiresLicense());
            ps.setString(11, eq.getStatus() != null ? eq.getStatus() : "AVAILABLE");
            ps.setString(12, eq.getNotes());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { logger.error("create equipment: {}", e.getMessage(), e); }
        return -1;
    }

    public boolean update(Equipment eq) {
        String sql = "UPDATE equipment SET equipment_type=?, make_model=?, description=?, condition_state=?, " +
                     "license_number=?, license_expiry=?, requires_license=?, status=?, notes=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eq.getEquipmentType());
            ps.setString(2, eq.getMakeModel());
            ps.setString(3, eq.getDescription());
            ps.setString(4, eq.getConditionState());
            ps.setString(5, eq.getLicenseNumber());
            ps.setObject(6, eq.getLicenseExpiry());
            ps.setBoolean(7, eq.isRequiresLicense());
            ps.setString(8, eq.getStatus());
            ps.setString(9, eq.getNotes());
            ps.setInt(10, eq.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("update equipment: {}", e.getMessage(), e); }
        return false;
    }

    public boolean issueToGuard(int equipmentId, int guardId, int issuedBy, String condition) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            // Insert assignment record
            PreparedStatement ps1 = conn.prepareStatement(
                "INSERT INTO equipment_assignments (equipment_id, guard_id, issued_by, condition_on_issue, status) VALUES (?,?,?,?,'ISSUED')");
            ps1.setInt(1, equipmentId); ps1.setInt(2, guardId);
            ps1.setInt(3, issuedBy); ps1.setString(4, condition);
            ps1.executeUpdate();
            // Update equipment status
            PreparedStatement ps2 = conn.prepareStatement(
                "UPDATE equipment SET status='ASSIGNED', current_assignee_id=? WHERE id=?");
            ps2.setInt(1, guardId); ps2.setInt(2, equipmentId);
            ps2.executeUpdate();
            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("issueToGuard: {}", e.getMessage(), e);
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException ex) {}
        }
        return false;
    }

    public boolean returnEquipment(int equipmentId, int receivedBy, String conditionOnReturn) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            PreparedStatement ps1 = conn.prepareStatement(
                "UPDATE equipment_assignments SET returned_at=NOW(), received_by=?, condition_on_return=?, status='RETURNED' " +
                "WHERE equipment_id=? AND status='ISSUED' ORDER BY issued_at DESC LIMIT 1");
            ps1.setInt(1, receivedBy); ps1.setString(2, conditionOnReturn); ps1.setInt(3, equipmentId);
            ps1.executeUpdate();
            PreparedStatement ps2 = conn.prepareStatement(
                "UPDATE equipment SET status='AVAILABLE', current_assignee_id=NULL WHERE id=?");
            ps2.setInt(1, equipmentId);
            ps2.executeUpdate();
            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.error("returnEquipment: {}", e.getMessage(), e);
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException ex) {}
        }
        return false;
    }

    public List<Map<String,Object>> getAssignmentHistory(int equipmentId) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT ea.*, CONCAT(u.first_name,' ',u.last_name) as guard_name " +
                     "FROM equipment_assignments ea JOIN guards g ON ea.guard_id = g.id JOIN users u ON g.user_id = u.id " +
                     "WHERE ea.equipment_id = ? ORDER BY ea.issued_at DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("guardName", rs.getString("guard_name"));
                m.put("issuedAt", rs.getTimestamp("issued_at"));
                m.put("returnedAt", rs.getTimestamp("returned_at"));
                m.put("conditionOnIssue", rs.getString("condition_on_issue"));
                m.put("conditionOnReturn", rs.getString("condition_on_return"));
                m.put("status", rs.getString("status"));
                list.add(m);
            }
        } catch (SQLException e) { logger.error("getAssignmentHistory: {}", e.getMessage(), e); }
        return list;
    }

    public long countByStatus(String status) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM equipment WHERE status=?")) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countByStatus: {}", e.getMessage()); }
        return 0;
    }

    private Equipment mapRow(ResultSet rs) throws SQLException {
        Equipment e = new Equipment();
        e.setId(rs.getInt("id"));
        e.setEquipmentType(rs.getString("equipment_type"));
        e.setSerialNumber(rs.getString("serial_number"));
        e.setMakeModel(rs.getString("make_model"));
        e.setDescription(rs.getString("description"));
        e.setConditionState(rs.getString("condition_state"));
        java.sql.Date ad = rs.getDate("acquisition_date");
        if (ad != null) e.setAcquisitionDate(ad.toLocalDate());
        e.setAcquisitionCost(rs.getBigDecimal("acquisition_cost"));
        e.setLicenseNumber(rs.getString("license_number"));
        java.sql.Date le = rs.getDate("license_expiry");
        if (le != null) e.setLicenseExpiry(le.toLocalDate());
        e.setRequiresLicense(rs.getBoolean("requires_license"));
        int assigneeId = rs.getInt("current_assignee_id");
        if (!rs.wasNull()) e.setCurrentAssigneeId(assigneeId);
        e.setCurrentAssigneeName(rs.getString("assignee_name"));
        int siteId = rs.getInt("current_site_id");
        if (!rs.wasNull()) e.setCurrentSiteId(siteId);
        e.setCurrentSiteName(rs.getString("site_name"));
        e.setStatus(rs.getString("status"));
        e.setNotes(rs.getString("notes"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) e.setCreatedAt(ca.toLocalDateTime());
        return e;
    }
}
