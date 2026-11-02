package com.sgms.dao;

import com.sgms.model.Guard;
import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GuardDAO {
    private static final Logger logger = LoggerFactory.getLogger(GuardDAO.class);

    private static final String SELECT_BASE =
        "SELECT g.*, u.first_name, u.last_name, u.email, u.phone " +
        "FROM guards g JOIN users u ON g.user_id = u.id ";

    public Guard findById(int id) {
        String sql = SELECT_BASE + "WHERE g.id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            logger.error("findById error: {}", e.getMessage(), e);
        }
        return null;
    }

    public Guard findByUserId(int userId) {
        String sql = SELECT_BASE + "WHERE g.user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            logger.error("findByUserId error: {}", e.getMessage(), e);
        }
        return null;
    }

    public List<Guard> findAll() {
        List<Guard> guards = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY g.employee_number";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) guards.add(mapRow(rs));
        } catch (SQLException e) {
            logger.error("findAll error: {}", e.getMessage(), e);
        }
        return guards;
    }

    public List<Guard> findActive() {
        List<Guard> guards = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE g.status = 'ACTIVE' ORDER BY u.first_name, u.last_name";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) guards.add(mapRow(rs));
        } catch (SQLException e) {
            logger.error("findActive error: {}", e.getMessage(), e);
        }
        return guards;
    }

    public List<Guard> findK9Handlers() {
        List<Guard> guards = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE g.is_k9_handler = TRUE AND g.status = 'ACTIVE' ORDER BY u.first_name";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) guards.add(mapRow(rs));
        } catch (SQLException e) {
            logger.error("findK9Handlers error: {}", e.getMessage(), e);
        }
        return guards;
    }

    public int create(Guard guard) {
        String sql = "INSERT INTO guards (user_id, employee_number, national_id, kra_pin, nssf_number, " +
                     "nhif_number, date_of_birth, gender, hire_date, employment_type, basic_salary, " +
                     "bank_name, bank_account, emergency_contact_name, emergency_contact_phone, " +
                     "psv_badge_number, psv_expiry, is_k9_handler, status) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, guard.getUserId());
            ps.setString(2, guard.getEmployeeNumber());
            ps.setString(3, guard.getNationalId());
            ps.setString(4, guard.getKraPin());
            ps.setString(5, guard.getNssfNumber());
            ps.setString(6, guard.getNhifNumber());
            ps.setObject(7, guard.getDateOfBirth());
            ps.setString(8, guard.getGender());
            ps.setObject(9, guard.getHireDate());
            ps.setString(10, guard.getEmploymentType());
            ps.setBigDecimal(11, guard.getBasicSalary());
            ps.setString(12, guard.getBankName());
            ps.setString(13, guard.getBankAccount());
            ps.setString(14, guard.getEmergencyContactName());
            ps.setString(15, guard.getEmergencyContactPhone());
            ps.setString(16, guard.getPsvBadgeNumber());
            ps.setObject(17, guard.getPsvExpiry());
            ps.setBoolean(18, guard.isK9Handler());
            ps.setString(19, guard.getStatus() != null ? guard.getStatus() : "ACTIVE");
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) {
            logger.error("create guard error: {}", e.getMessage(), e);
        }
        return -1;
    }

    public boolean update(Guard guard) {
        String sql = "UPDATE guards SET national_id=?, kra_pin=?, nssf_number=?, nhif_number=?, " +
                     "date_of_birth=?, gender=?, employment_type=?, basic_salary=?, bank_name=?, " +
                     "bank_account=?, emergency_contact_name=?, emergency_contact_phone=?, " +
                     "psv_badge_number=?, psv_expiry=?, is_k9_handler=?, status=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, guard.getNationalId());
            ps.setString(2, guard.getKraPin());
            ps.setString(3, guard.getNssfNumber());
            ps.setString(4, guard.getNhifNumber());
            ps.setObject(5, guard.getDateOfBirth());
            ps.setString(6, guard.getGender());
            ps.setString(7, guard.getEmploymentType());
            ps.setBigDecimal(8, guard.getBasicSalary());
            ps.setString(9, guard.getBankName());
            ps.setString(10, guard.getBankAccount());
            ps.setString(11, guard.getEmergencyContactName());
            ps.setString(12, guard.getEmergencyContactPhone());
            ps.setString(13, guard.getPsvBadgeNumber());
            ps.setObject(14, guard.getPsvExpiry());
            ps.setBoolean(15, guard.isK9Handler());
            ps.setString(16, guard.getStatus());
            ps.setInt(17, guard.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("update guard error: {}", e.getMessage(), e);
        }
        return false;
    }

    public long countActive() {
        String sql = "SELECT COUNT(*) FROM guards WHERE status = 'ACTIVE'";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) {
            logger.error("countActive error: {}", e.getMessage(), e);
        }
        return 0;
    }

    private Guard mapRow(ResultSet rs) throws SQLException {
        Guard g = new Guard();
        g.setId(rs.getInt("id"));
        g.setUserId(rs.getInt("user_id"));
        g.setEmployeeNumber(rs.getString("employee_number"));
        g.setNationalId(rs.getString("national_id"));
        g.setKraPin(rs.getString("kra_pin"));
        g.setNssfNumber(rs.getString("nssf_number"));
        g.setNhifNumber(rs.getString("nhif_number"));
        Date dob = rs.getDate("date_of_birth");
        if (dob != null) g.setDateOfBirth(dob.toLocalDate());
        g.setGender(rs.getString("gender"));
        Date hire = rs.getDate("hire_date");
        if (hire != null) g.setHireDate(hire.toLocalDate());
        g.setEmploymentType(rs.getString("employment_type"));
        g.setBasicSalary(rs.getBigDecimal("basic_salary"));
        g.setBankName(rs.getString("bank_name"));
        g.setBankAccount(rs.getString("bank_account"));
        g.setEmergencyContactName(rs.getString("emergency_contact_name"));
        g.setEmergencyContactPhone(rs.getString("emergency_contact_phone"));
        g.setPsvBadgeNumber(rs.getString("psv_badge_number"));
        Date psv = rs.getDate("psv_expiry");
        if (psv != null) g.setPsvExpiry(psv.toLocalDate());
        g.setK9Handler(rs.getBoolean("is_k9_handler"));
        g.setStatus(rs.getString("status"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) g.setCreatedAt(created.toLocalDateTime());
        g.setFirstName(rs.getString("first_name"));
        g.setLastName(rs.getString("last_name"));
        g.setEmail(rs.getString("email"));
        g.setPhone(rs.getString("phone"));
        return g;
    }
}
