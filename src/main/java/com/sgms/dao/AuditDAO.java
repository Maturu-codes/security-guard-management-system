package com.sgms.dao;

import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;

public class AuditDAO {
    private static final Logger logger = LoggerFactory.getLogger(AuditDAO.class);

    public void log(Integer userId, String action, String entityType, Integer entityId,
                    String oldValues, String newValues, String ipAddress, String userAgent) {
        String sql = "INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_values, " +
                     "new_values, ip_address, user_agent) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setString(2, action);
            ps.setString(3, entityType);
            ps.setObject(4, entityId);
            ps.setString(5, oldValues);
            ps.setString(6, newValues);
            ps.setString(7, ipAddress);
            ps.setString(8, userAgent);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("audit log error: {}", e.getMessage(), e);
        }
    }

    public void log(Integer userId, String action, String ipAddress) {
        log(userId, action, null, null, null, null, ipAddress, null);
    }
}
