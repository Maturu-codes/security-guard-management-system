package com.sgms.dao;

import com.sgms.model.K9Dog;
import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.*;

public class K9DAO {
    private static final Logger logger = LoggerFactory.getLogger(K9DAO.class);

    private static final String SELECT_BASE =
        "SELECT d.*, CONCAT(u.first_name,' ',u.last_name) as handler_name " +
        "FROM k9_dogs d LEFT JOIN guards g ON d.current_handler_id = g.id LEFT JOIN users u ON g.user_id = u.id ";

    public List<K9Dog> findAll() {
        List<K9Dog> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "ORDER BY d.name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { logger.error("findAll k9: {}", e.getMessage(), e); }
        return list;
    }

    public K9Dog findById(int id) {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BASE + "WHERE d.id = ?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { logger.error("findById k9: {}", e.getMessage(), e); }
        return null;
    }

    public int create(K9Dog dog) {
        String sql = "INSERT INTO k9_dogs (name, breed, date_of_birth, gender, chip_number, training_level, specialization, current_handler_id, status, acquired_date, notes) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dog.getName());
            ps.setString(2, dog.getBreed());
            ps.setObject(3, dog.getDateOfBirth());
            ps.setString(4, dog.getGender());
            ps.setString(5, dog.getChipNumber());
            ps.setString(6, dog.getTrainingLevel());
            ps.setString(7, dog.getSpecialization());
            ps.setObject(8, dog.getCurrentHandlerId());
            ps.setString(9, dog.getStatus() != null ? dog.getStatus() : "ACTIVE");
            ps.setObject(10, dog.getAcquiredDate());
            ps.setString(11, dog.getNotes());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { logger.error("create k9: {}", e.getMessage(), e); }
        return -1;
    }

    public boolean update(K9Dog dog) {
        String sql = "UPDATE k9_dogs SET name=?, breed=?, date_of_birth=?, gender=?, chip_number=?, training_level=?, specialization=?, current_handler_id=?, status=?, notes=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dog.getName()); ps.setString(2, dog.getBreed());
            ps.setObject(3, dog.getDateOfBirth()); ps.setString(4, dog.getGender());
            ps.setString(5, dog.getChipNumber()); ps.setString(6, dog.getTrainingLevel());
            ps.setString(7, dog.getSpecialization()); ps.setObject(8, dog.getCurrentHandlerId());
            ps.setString(9, dog.getStatus()); ps.setString(10, dog.getNotes());
            ps.setInt(11, dog.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("update k9: {}", e.getMessage(), e); }
        return false;
    }

    public List<Map<String,Object>> getMedicalRecords(int dogId) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM k9_medical_records WHERE dog_id = ? ORDER BY visit_date DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dogId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("recordType", rs.getString("record_type"));
                m.put("description", rs.getString("description"));
                m.put("vetName", rs.getString("vet_name"));
                m.put("visitDate", rs.getDate("visit_date"));
                m.put("nextVisitDate", rs.getDate("next_visit_date"));
                m.put("cost", rs.getBigDecimal("cost"));
                list.add(m);
            }
        } catch (SQLException e) { logger.error("getMedicalRecords: {}", e.getMessage(), e); }
        return list;
    }

    public boolean addMedicalRecord(int dogId, String recordType, String description,
                                     String vetName, String visitDate, String nextVisitDate,
                                     java.math.BigDecimal cost, int recordedBy) {
        String sql = "INSERT INTO k9_medical_records (dog_id, record_type, description, vet_name, visit_date, next_visit_date, cost, recorded_by) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dogId); ps.setString(2, recordType); ps.setString(3, description);
            ps.setString(4, vetName);
            ps.setDate(5, visitDate != null && !visitDate.isBlank()
        ? java.sql.Date.valueOf(visitDate)
        : null);

ps.setDate(6, nextVisitDate != null && !nextVisitDate.isBlank()
        ? java.sql.Date.valueOf(nextVisitDate)
        : null);
            ps.setBigDecimal(7, cost); ps.setInt(8, recordedBy);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("addMedicalRecord: {}", e.getMessage(), e); }
        return false;
    }

    public List<Map<String,Object>> getTrainingRecords(int dogId) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM k9_training_records WHERE dog_id = ? ORDER BY start_date DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dogId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("trainingType", rs.getString("training_type"));
                m.put("trainerName", rs.getString("trainer_name"));
                m.put("startDate", rs.getDate("start_date"));
                m.put("endDate", rs.getDate("end_date"));
                m.put("result", rs.getString("result"));
                m.put("certificateNumber", rs.getString("certificate_number"));
                list.add(m);
            }
        } catch (SQLException e) { logger.error("getTrainingRecords: {}", e.getMessage(), e); }
        return list;
    }

    public long countActive() {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM k9_dogs WHERE status='ACTIVE'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countActive k9: {}", e.getMessage()); }
        return 0;
    }

    private K9Dog mapRow(ResultSet rs) throws SQLException {
        K9Dog d = new K9Dog();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setBreed(rs.getString("breed"));
        java.sql.Date dob = rs.getDate("date_of_birth");
        if (dob != null) d.setDateOfBirth(dob.toLocalDate());
        d.setGender(rs.getString("gender"));
        d.setChipNumber(rs.getString("chip_number"));
        d.setTrainingLevel(rs.getString("training_level"));
        d.setSpecialization(rs.getString("specialization"));
        int handlerId = rs.getInt("current_handler_id");
        if (!rs.wasNull()) d.setCurrentHandlerId(handlerId);
        d.setCurrentHandlerName(rs.getString("handler_name"));
        d.setStatus(rs.getString("status"));
        java.sql.Date acq = rs.getDate("acquired_date");
        if (acq != null) d.setAcquiredDate(acq.toLocalDate());
        d.setNotes(rs.getString("notes"));
        return d;
    }
}
