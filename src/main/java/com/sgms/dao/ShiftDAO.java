package com.sgms.dao;

import com.sgms.model.Shift;
import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShiftDAO {
    private static final Logger logger = LoggerFactory.getLogger(ShiftDAO.class);

    private static final String SELECT_BASE =
        "SELECT s.*, si.site_name, c.company_name as client_name, " +
        "(SELECT COUNT(*) FROM shift_assignments sa WHERE sa.shift_id = s.id AND sa.status != 'NO_SHOW') as assigned_guards " +
        "FROM shifts s " +
        "JOIN sites si ON s.site_id = si.id " +
        "JOIN clients c ON si.client_id = c.id ";

    public List<Shift> findAll() {
        List<Shift> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "ORDER BY s.shift_date DESC, s.start_time")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findAll shifts: {}", e.getMessage(), e); }
        return list;
    }

    public List<Shift> findByDate(java.time.LocalDate date) {
        List<Shift> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "WHERE s.shift_date = ? ORDER BY s.start_time")) {
            ps.setDate(1, Date.valueOf(date));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findByDate: {}", e.getMessage(), e); }
        return list;
    }

    public Shift findById(int id) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "WHERE s.id = ?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { logger.error("findById shift: {}", e.getMessage(), e); }
        return null;
    }

    public int create(Shift shift) {
        String sql = "INSERT INTO shifts (site_id, shift_name, start_time, end_time, shift_date, required_guards, status, created_by) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, shift.getSiteId());
            ps.setString(2, shift.getShiftName());
            ps.setObject(3, shift.getStartTime());
            ps.setObject(4, shift.getEndTime());
            ps.setObject(5, shift.getShiftDate());
            ps.setInt(6, shift.getRequiredGuards());
            ps.setString(7, shift.getStatus() != null ? shift.getStatus() : "SCHEDULED");
            ps.setObject(8, shift.getCreatedBy());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { logger.error("create shift: {}", e.getMessage(), e); }
        return -1;
    }

    public boolean update(Shift shift) {
        String sql = "UPDATE shifts SET site_id=?, shift_name=?, start_time=?, end_time=?, shift_date=?, required_guards=?, status=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shift.getSiteId());
            ps.setString(2, shift.getShiftName());
            ps.setObject(3, shift.getStartTime());
            ps.setObject(4, shift.getEndTime());
            ps.setObject(5, shift.getShiftDate());
            ps.setInt(6, shift.getRequiredGuards());
            ps.setString(7, shift.getStatus());
            ps.setInt(8, shift.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("update shift: {}", e.getMessage(), e); }
        return false;
    }

    public boolean delete(int id) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM shifts WHERE id=?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("delete shift: {}", e.getMessage(), e); }
        return false;
    }

    public boolean assignGuard(int shiftId, int guardId, int assignedBy) {
        String sql = "INSERT INTO shift_assignments (shift_id, guard_id, assigned_by) VALUES (?,?,?) ON DUPLICATE KEY UPDATE status='ASSIGNED', assigned_by=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shiftId); ps.setInt(2, guardId);
            ps.setInt(3, assignedBy); ps.setInt(4, assignedBy);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("assignGuard: {}", e.getMessage(), e); }
        return false;
    }

    public List<com.sgms.model.Guard> getAssignedGuards(int shiftId) {
        List<com.sgms.model.Guard> guards = new ArrayList<>();
        String sql = "SELECT g.*, u.first_name, u.last_name, u.email, u.phone, sa.status as assignment_status " +
                     "FROM shift_assignments sa JOIN guards g ON sa.guard_id = g.id JOIN users u ON g.user_id = u.id " +
                     "WHERE sa.shift_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                com.sgms.model.Guard g = new com.sgms.model.Guard();
                g.setId(rs.getInt("id"));
                g.setEmployeeNumber(rs.getString("employee_number"));
                g.setFirstName(rs.getString("first_name"));
                g.setLastName(rs.getString("last_name"));
                g.setPhone(rs.getString("phone"));
                g.setStatus(rs.getString("assignment_status"));
                guards.add(g);
            }
        } catch (SQLException e) { logger.error("getAssignedGuards: {}", e.getMessage(), e); }
        return guards;
    }

    public long countToday() {
        String sql = "SELECT COUNT(*) FROM shifts WHERE shift_date = CURDATE()";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countToday: {}", e.getMessage()); }
        return 0;
    }

    private Shift mapRow(ResultSet rs) throws SQLException {
        Shift s = new Shift();
        s.setId(rs.getInt("id"));
        s.setSiteId(rs.getInt("site_id"));
        s.setSiteName(rs.getString("site_name"));
        s.setClientName(rs.getString("client_name"));
        s.setShiftName(rs.getString("shift_name"));
        Time st = rs.getTime("start_time");
        if (st != null) s.setStartTime(st.toLocalTime());
        Time et = rs.getTime("end_time");
        if (et != null) s.setEndTime(et.toLocalTime());
        Date sd = rs.getDate("shift_date");
        if (sd != null) s.setShiftDate(sd.toLocalDate());
        s.setRequiredGuards(rs.getInt("required_guards"));
        s.setAssignedGuards(rs.getInt("assigned_guards"));
        s.setStatus(rs.getString("status"));
        int cb = rs.getInt("created_by");
        if (!rs.wasNull()) s.setCreatedBy(cb);
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) s.setCreatedAt(ca.toLocalDateTime());
        return s;
    }
}
