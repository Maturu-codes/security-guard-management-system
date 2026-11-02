package com.sgms.dao;

import com.sgms.util.DatabaseUtil;
import com.sgms.util.PayrollCalculator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class PayrollDAO {

    private static final Logger logger = LoggerFactory.getLogger(PayrollDAO.class);

    public List<Map<String, Object>> findAllPeriods() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT pp.*, CONCAT(u.first_name,' ',u.last_name) as created_by_name, COUNT(ps.id) as payslip_count "
                + "FROM payroll_periods pp LEFT JOIN users u ON pp.created_by = u.id "
                + "LEFT JOIN payslips ps ON pp.id = ps.payroll_period_id GROUP BY pp.id ORDER BY pp.start_date DESC";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("periodName", rs.getString("period_name"));
                m.put("startDate", rs.getDate("start_date"));
                m.put("endDate", rs.getDate("end_date"));
                m.put("payDate", rs.getDate("pay_date"));
                m.put("status", rs.getString("status"));
                m.put("createdByName", rs.getString("created_by_name"));
                m.put("payslipCount", rs.getInt("payslip_count"));
                list.add(m);
            }
        } catch (SQLException e) {
            logger.error("findAllPeriods: {}", e.getMessage(), e);
        }
        return list;
    }

    public int createPeriod(String name, String startDate, String endDate, String payDate, int createdBy) {
        String sql = "INSERT INTO payroll_periods (period_name, start_date, end_date, pay_date, created_by) VALUES (?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setDate(2, startDate != null && !startDate.isBlank() ? java.sql.Date.valueOf(startDate) : null);
            ps.setDate(3, endDate != null && !endDate.isBlank() ? java.sql.Date.valueOf(endDate) : null);
            ps.setDate(4, payDate != null && !payDate.isBlank() ? java.sql.Date.valueOf(payDate) : null);
            ps.setInt(5, createdBy);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("createPeriod: {}", e.getMessage(), e);
        }
        return -1;
    }

    public boolean processPayroll(int periodId) {
        // Generate payslips for all active guards
        String guardsSql = "SELECT id, basic_salary FROM guards WHERE status = 'ACTIVE'";
        String insertSql = "INSERT INTO payslips (payroll_period_id, guard_id, basic_salary, allowances, overtime_pay, "
                + "gross_pay, nssf_tier1, nssf_tier2, nhif_deduction, paye_tax, total_statutory_deductions, "
                + "net_before_liability, liability_deduction, other_deductions, net_pay) "
                + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "
                + "ON DUPLICATE KEY UPDATE net_pay = VALUES(net_pay)";
        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement guardPs = conn.prepareStatement(guardsSql);
            ResultSet rs = guardPs.executeQuery();
            PreparedStatement insertPs = conn.prepareStatement(insertSql);
            while (rs.next()) {
                int guardId = rs.getInt("id");
                BigDecimal salary = rs.getBigDecimal("basic_salary");
                if (salary == null) {
                    salary = BigDecimal.ZERO;
                }

                // Get approved liability deductions for this guard
                BigDecimal liabilityDeduction = getPendingLiabilityDeduction(conn, guardId);

                PayrollCalculator.PayrollResult result = PayrollCalculator.calculate(
                        salary, BigDecimal.ZERO, BigDecimal.ZERO, liabilityDeduction, BigDecimal.ZERO);

                insertPs.setInt(1, periodId);
                insertPs.setInt(2, guardId);
                insertPs.setBigDecimal(3, result.basicSalary);
                insertPs.setBigDecimal(4, result.allowances);
                insertPs.setBigDecimal(5, result.overtimePay);
                insertPs.setBigDecimal(6, result.grossPay);
                insertPs.setBigDecimal(7, result.nssfTier1);
                insertPs.setBigDecimal(8, result.nssfTier2);
                insertPs.setBigDecimal(9, result.nhifDeduction);
                insertPs.setBigDecimal(10, result.payeTax);
                insertPs.setBigDecimal(11, result.totalStatutoryDeductions);
                insertPs.setBigDecimal(12, result.netBeforeLiability);
                insertPs.setBigDecimal(13, result.liabilityDeduction);
                insertPs.setBigDecimal(14, result.otherDeductions);
                insertPs.setBigDecimal(15, result.netPay);
                insertPs.addBatch();
            }
            insertPs.executeBatch();
            // Update period status to PROCESSING
            conn.prepareStatement("UPDATE payroll_periods SET status='PROCESSING' WHERE id=" + periodId).executeUpdate();
            return true;
        } catch (SQLException e) {
            logger.error("processPayroll: {}", e.getMessage(), e);
        }
        return false;
    }

    private BigDecimal getPendingLiabilityDeduction(Connection conn, int guardId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(approved_deduction),0) FROM liability_reports WHERE guard_id=? AND status='HR_APPROVED'";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, guardId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getBigDecimal(1);
        }
        return BigDecimal.ZERO;
    }

    public List<Map<String, Object>> getPayslips(int periodId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ps.*, CONCAT(u.first_name,' ',u.last_name) as guard_name, g.employee_number "
                + "FROM payslips ps JOIN guards g ON ps.guard_id = g.id JOIN users u ON g.user_id = u.id "
                + "WHERE ps.payroll_period_id = ? ORDER BY u.last_name, u.first_name";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, periodId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("guardId", rs.getInt("guard_id"));
                m.put("guardName", rs.getString("guard_name"));
                m.put("employeeNumber", rs.getString("employee_number"));
                m.put("basicSalary", rs.getBigDecimal("basic_salary"));
                m.put("grossPay", rs.getBigDecimal("gross_pay"));
                m.put("nssfTier1", rs.getBigDecimal("nssf_tier1"));
                m.put("nssfTier2", rs.getBigDecimal("nssf_tier2"));
                m.put("nhifDeduction", rs.getBigDecimal("nhif_deduction"));
                m.put("payeTax", rs.getBigDecimal("paye_tax"));
                m.put("totalStatutory", rs.getBigDecimal("total_statutory_deductions"));
                m.put("netBeforeLiability", rs.getBigDecimal("net_before_liability"));
                m.put("liabilityDeduction", rs.getBigDecimal("liability_deduction"));
                m.put("netPay", rs.getBigDecimal("net_pay"));
                m.put("paymentStatus", rs.getString("payment_status"));
                list.add(m);
            }
        } catch (SQLException e) {
            logger.error("getPayslips: {}", e.getMessage(), e);
        }
        return list;
    }

    public Map<String, Object> getPeriodById(int id) {
        String sql = "SELECT * FROM payroll_periods WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("periodName", rs.getString("period_name"));
                m.put("startDate", rs.getDate("start_date"));
                m.put("endDate", rs.getDate("end_date"));
                m.put("payDate", rs.getDate("pay_date"));
                m.put("status", rs.getString("status"));
                return m;
            }
        } catch (SQLException e) {
            logger.error("getPeriodById: {}", e.getMessage(), e);
        }
        return null;
    }

    public boolean approvePeriod(int periodId, int approvedBy) {
        String sql = "UPDATE payroll_periods SET status='APPROVED', approved_by=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setInt(2, periodId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("approvePeriod: {}", e.getMessage(), e);
        }
        return false;
    }
}
