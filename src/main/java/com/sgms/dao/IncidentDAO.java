package com.sgms.dao;

import com.sgms.model.Incident;
import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class IncidentDAO {
    private static final Logger logger = LoggerFactory.getLogger(IncidentDAO.class);

    private static final String SELECT_BASE =
        "SELECT i.*, s.site_name, CONCAT(ug.first_name,' ',ug.last_name) as guard_name, " +
        "CONCAT(ur.first_name,' ',ur.last_name) as reported_by_name " +
        "FROM incidents i " +
        "JOIN sites s ON i.site_id = s.id " +
        "JOIN guards g ON i.guard_id = g.id " +
        "JOIN users ug ON g.user_id = ug.id " +
        "LEFT JOIN users ur ON i.reported_by = ur.id ";

    public List<Incident> findAll() {
        List<Incident> list = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY i.incident_datetime DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            logger.error("findAll incidents: {}", e.getMessage(), e);
        }
        return list;
    }

    public List<Incident> findOpenHighSeverity() {
        List<Incident> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE i.status IN ('OPEN','ESCALATED') AND i.severity IN ('HIGH','CRITICAL') " +
                     "ORDER BY i.incident_datetime DESC LIMIT 10";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            logger.error("findOpenHighSeverity: {}", e.getMessage(), e);
        }
        return list;
    }

    public Incident findById(int id) {
        String sql = SELECT_BASE + "WHERE i.id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            logger.error("findById incident: {}", e.getMessage(), e);
        }
        return null;
    }

    public int create(Incident incident) {
        String sql = "INSERT INTO incidents (site_id, guard_id, shift_id, incident_type, severity, title, " +
                     "description, incident_datetime, location_details, action_taken, police_report_number, " +
                     "status, reported_by) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, incident.getSiteId());
            ps.setInt(2, incident.getGuardId());
            ps.setObject(3, incident.getShiftId());
            ps.setString(4, incident.getIncidentType());
            ps.setString(5, incident.getSeverity());
            ps.setString(6, incident.getTitle());
            ps.setString(7, incident.getDescription());
            ps.setTimestamp(8, Timestamp.valueOf(incident.getIncidentDatetime()));
            ps.setString(9, incident.getLocationDetails());
            ps.setString(10, incident.getActionTaken());
            ps.setString(11, incident.getPoliceReportNumber());
            ps.setString(12, incident.getStatus() != null ? incident.getStatus() : "OPEN");
            ps.setObject(13, incident.getReportedBy());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) {
            logger.error("create incident: {}", e.getMessage(), e);
        }
        return -1;
    }

    public boolean updateStatus(int id, String status, int reviewedBy) {
        String sql = "UPDATE incidents SET status=?, reviewed_by=?, updated_at=NOW() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, reviewedBy);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateStatus incident: {}", e.getMessage(), e);
        }
        return false;
    }

    public long countOpen() {
        String sql = "SELECT COUNT(*) FROM incidents WHERE status IN ('OPEN','ESCALATED')";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countOpen: {}", e.getMessage()); }
        return 0;
    }

    private Incident mapRow(ResultSet rs) throws SQLException {
        Incident i = new Incident();
        i.setId(rs.getInt("id"));
        i.setSiteId(rs.getInt("site_id"));
        i.setSiteName(rs.getString("site_name"));
        i.setGuardId(rs.getInt("guard_id"));
        i.setGuardName(rs.getString("guard_name"));
        int shiftId = rs.getInt("shift_id");
        if (!rs.wasNull()) i.setShiftId(shiftId);
        i.setIncidentType(rs.getString("incident_type"));
        i.setSeverity(rs.getString("severity"));
        i.setTitle(rs.getString("title"));
        i.setDescription(rs.getString("description"));
        Timestamp dt = rs.getTimestamp("incident_datetime");
        if (dt != null) i.setIncidentDatetime(dt.toLocalDateTime());
        i.setLocationDetails(rs.getString("location_details"));
        i.setActionTaken(rs.getString("action_taken"));
        i.setPoliceReportNumber(rs.getString("police_report_number"));
        i.setStatus(rs.getString("status"));
        int rep = rs.getInt("reported_by");
        if (!rs.wasNull()) i.setReportedBy(rep);
        i.setReportedByName(rs.getString("reported_by_name"));
        int rev = rs.getInt("reviewed_by");
        if (!rs.wasNull()) i.setReviewedBy(rev);
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) i.setCreatedAt(created.toLocalDateTime());
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) i.setUpdatedAt(updated.toLocalDateTime());
        return i;
    }
}
