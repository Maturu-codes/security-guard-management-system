package com.sgms.dao;

import com.sgms.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.*;

public class ClientDAO {
    private static final Logger logger = LoggerFactory.getLogger(ClientDAO.class);

    public List<Map<String,Object>> findAll() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT c.*, COUNT(s.id) as site_count FROM clients c LEFT JOIN sites s ON c.id = s.client_id GROUP BY c.id ORDER BY c.company_name";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("companyName", rs.getString("company_name"));
                m.put("contactPerson", rs.getString("contact_person"));
                m.put("email", rs.getString("email"));
                m.put("phone", rs.getString("phone"));
                m.put("address", rs.getString("address"));
                m.put("contractStart", rs.getDate("contract_start"));
                m.put("contractEnd", rs.getDate("contract_end"));
                m.put("isActive", rs.getBoolean("is_active"));
                m.put("siteCount", rs.getInt("site_count"));
                list.add(m);
            }
        } catch (SQLException e) { logger.error("findAll clients: {}", e.getMessage(), e); }
        return list;
    }

    public Map<String,Object> findById(int id) {
        String sql = "SELECT * FROM clients WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("companyName", rs.getString("company_name"));
                m.put("contactPerson", rs.getString("contact_person"));
                m.put("email", rs.getString("email"));
                m.put("phone", rs.getString("phone"));
                m.put("address", rs.getString("address"));
                m.put("contractStart", rs.getDate("contract_start"));
                m.put("contractEnd", rs.getDate("contract_end"));
                m.put("isActive", rs.getBoolean("is_active"));
                return m;
            }
        } catch (SQLException e) { logger.error("findById client: {}", e.getMessage(), e); }
        return null;
    }

    public int create(String companyName, String contactPerson, String email, String phone,
                      String address, String contractStart, String contractEnd) {
        String sql = "INSERT INTO clients (company_name, contact_person, email, phone, address, contract_start, contract_end) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, companyName);
            ps.setString(2, contactPerson);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, address);
            ps.setDate(6, contractStart != null && !contractStart.isBlank()
        ? java.sql.Date.valueOf(contractStart)
        : null);

ps.setDate(7, contractEnd != null && !contractEnd.isBlank()
        ? java.sql.Date.valueOf(contractEnd)
        : null);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { logger.error("create client: {}", e.getMessage(), e); }
        return -1;
    }

    public boolean update(int id, String companyName, String contactPerson, String email,
                          String phone, String address, String contractStart, String contractEnd, boolean isActive) {
        String sql = "UPDATE clients SET company_name=?, contact_person=?, email=?, phone=?, address=?, contract_start=?, contract_end=?, is_active=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, companyName); ps.setString(2, contactPerson);
            ps.setString(3, email); ps.setString(4, phone); ps.setString(5, address);
            ps.setDate(6, contractStart != null && !contractStart.isBlank()
        ? java.sql.Date.valueOf(contractStart)
        : null);

ps.setDate(7, contractEnd != null && !contractEnd.isBlank()
        ? java.sql.Date.valueOf(contractEnd)
        : null);
            ps.setBoolean(8, isActive); ps.setInt(9, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { logger.error("update client: {}", e.getMessage(), e); }
        return false;
    }

    public List<Map<String,Object>> findSitesByClient(int clientId) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM sites WHERE client_id = ? ORDER BY site_name";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clientId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("siteName", rs.getString("site_name"));
                m.put("address", rs.getString("address"));
                m.put("siteType", rs.getString("site_type"));
                m.put("riskLevel", rs.getString("risk_level"));
                m.put("requiredGuards", rs.getInt("required_guards"));
                m.put("isActive", rs.getBoolean("is_active"));
                list.add(m);
            }
        } catch (SQLException e) { logger.error("findSitesByClient: {}", e.getMessage(), e); }
        return list;
    }

    public List<Map<String,Object>> findAllSites() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT s.*, c.company_name FROM sites s JOIN clients c ON s.client_id = c.id ORDER BY s.site_name";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("siteName", rs.getString("site_name"));
                m.put("clientId", rs.getInt("client_id"));
                m.put("companyName", rs.getString("company_name"));
                m.put("address", rs.getString("address"));
                m.put("siteType", rs.getString("site_type"));
                m.put("riskLevel", rs.getString("risk_level"));
                m.put("requiredGuards", rs.getInt("required_guards"));
                m.put("isActive", rs.getBoolean("is_active"));
                list.add(m);
            }
        } catch (SQLException e) { logger.error("findAllSites: {}", e.getMessage(), e); }
        return list;
    }

    public int createSite(int clientId, String siteName, String address, String siteType,
                          String riskLevel, int requiredGuards) {
        String sql = "INSERT INTO sites (client_id, site_name, address, site_type, risk_level, required_guards) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, clientId); ps.setString(2, siteName); ps.setString(3, address);
            ps.setString(4, siteType); ps.setString(5, riskLevel); ps.setInt(6, requiredGuards);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { logger.error("createSite: {}", e.getMessage(), e); }
        return -1;
    }

    public long countActive() {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM clients WHERE is_active=1");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { logger.error("countActive clients: {}", e.getMessage()); }
        return 0;
    }
}
