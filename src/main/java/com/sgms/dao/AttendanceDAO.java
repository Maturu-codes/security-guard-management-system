package com.sgms.dao;

import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.*;

public class AttendanceDAO {
    private static final Logger logger = LoggerFactory.getLogger(AttendanceDAO.class);

    public List<Map<String,Object>> findAll() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT a.*, CONCAT(u.first_name,' ',u.last_name) as guard_name, g.employee_number, " +
                     "sh.shift_name, si.site_name " +
                     "FROM attendance a " +
                     "JOIN guards g ON a.guard_id = g.id JOIN users u ON g.user_id = u.id " +
                     "JOIN shifts sh ON a.shift_id = sh.id JOIN sites si ON sh.site_id = si.id " +
                     "ORDER BY a.check_in_time DESC LIMIT 200";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findAll attendance: {}", e.getMessage(), e); }
        return list;
    }

    public List<Map<String,Object>> findByShift(int shiftId) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT a.*, CONCAT(u.first_name,' ',u.last_name) as guard_name, g.employee_number, " +
                     "sh.shift_name, si.site_name " +
                     "FROM attendance a " +
                     "JOIN guards g ON a.guard_id = g.id JOIN users u ON g.user_id = u.id " +
                     "JOIN shifts sh ON a.shift_id = sh.id JOIN sites si ON sh.site_id = si.id " +
                     "WHERE a.shift_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findByShift attendance: {}", e.getMessage(), e); }
        return list;
    }

    public boolean checkIn(int guardId, int shiftId, String method, int recordedBy) {
        // Check if already checked in
        String checkSql = "SELECT id FROM attendance WHERE guard_id=? AND shift_id=?";
        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, guardId); checkPs.setInt(2, shiftId);
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                // Update existing
                PreparedStatement upPs = conn.prepareStatement(
                    "UPDATE attendance SET check_in_time=NOW(), check_in_method=?, status='PRESENT', recorded_by=? WHERE id=?");
                upPs.setString(1, method); upPs.setInt(2, recordedBy); upPs.setInt(3, rs.getInt("id"));
                return upPs.executeUpdate() > 0;
            } else {
                PreparedStatement insPs = conn.prepareStatement(
                    "INSERT INTO attendance (guard_id, shift_id, check_in_time, check_in_method, status, recorded_by) VALUES (?,?,NOW(),?,?,?)");
                insPs.setInt(1, guardId); insPs.setInt(2, shiftId);
                insPs.setString(3, method); insPs.setString(4, "PRESENT"); insPs.setInt(5, recordedBy);
                return insPs.executeUpdate() > 0;
            }
        } catch (SQLException e) { logger.error("checkIn: {}", e.getMessage(), e); }
        return false;
    }

    public boolean checkOut(int guardId, int shiftId, int recordedBy) {
        String sql = "UPDATE attendance SET check_out_time=NOW(), recorded_by=? WHERE guard_id=? AND shift_id=? AND check_out_time IS NULL";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordedBy); ps.setInt(2, guardId); ps.setInt(3, shiftId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("checkOut: {}", e.getMessage(), e); }
        return false;
    }

    public boolean markAbsent(int guardId, int shiftId, String notes, int recordedBy) {
        String sql = "INSERT INTO attendance (guard_id, shift_id, status, notes, recorded_by) VALUES (?,?,'ABSENT',?,?) " +
                     "ON DUPLICATE KEY UPDATE status='ABSENT', notes=?, recorded_by=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, guardId); ps.setInt(2, shiftId); ps.setString(3, notes);
            ps.setInt(4, recordedBy); ps.setString(5, notes); ps.setInt(6, recordedBy);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("markAbsent: {}", e.getMessage(), e); }
        return false;
    }

    public long countPresentToday() {
        String sql = "SELECT COUNT(*) FROM attendance a JOIN shifts s ON a.shift_id = s.id WHERE s.shift_date = CURDATE() AND a.status='PRESENT'";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countPresentToday: {}", e.getMessage()); }
        return 0;
    }

    private Map<String,Object> mapRow(ResultSet rs) throws SQLException {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("id", rs.getInt("id"));
        m.put("guardName", rs.getString("guard_name"));
        m.put("employeeNumber", rs.getString("employee_number"));
        m.put("shiftName", rs.getString("shift_name"));
        m.put("siteName", rs.getString("site_name"));
        m.put("checkInTime", rs.getTimestamp("check_in_time"));
        m.put("checkOutTime", rs.getTimestamp("check_out_time"));
        m.put("checkInMethod", rs.getString("check_in_method"));
        m.put("status", rs.getString("status"));
        m.put("notes", rs.getString("notes"));
        m.put("guardId", rs.getInt("guard_id"));
        m.put("shiftId", rs.getInt("shift_id"));
        return m;
    }
}
