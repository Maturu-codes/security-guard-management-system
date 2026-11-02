package com.sgms.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Guard {
    private int id;
    private int userId;
    private String employeeNumber;
    private String nationalId;
    private String kraPin;
    private String nssfNumber;
    private String nhifNumber;
    private LocalDate dateOfBirth;
    private String gender;
    private LocalDate hireDate;
    private String employmentType;
    private BigDecimal basicSalary;
    private String bankName;
    private String bankAccount;
    private String emergencyContactName;
    private String emergencyContactPhone;
    private String psvBadgeNumber;
    private LocalDate psvExpiry;
    private boolean k9Handler;
    private String status;
    private LocalDateTime createdAt;

    // Joined from users table
    private String firstName;
    private String lastName;
    private String email;
    private String phone;

    public String getFullName() {
        return firstName + " " + lastName;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getEmployeeNumber() { return employeeNumber; }
    public void setEmployeeNumber(String employeeNumber) { this.employeeNumber = employeeNumber; }
    public String getNationalId() { return nationalId; }
    public void setNationalId(String nationalId) { this.nationalId = nationalId; }
    public String getKraPin() { return kraPin; }
    public void setKraPin(String kraPin) { this.kraPin = kraPin; }
    public String getNssfNumber() { return nssfNumber; }
    public void setNssfNumber(String nssfNumber) { this.nssfNumber = nssfNumber; }
    public String getNhifNumber() { return nhifNumber; }
    public void setNhifNumber(String nhifNumber) { this.nhifNumber = nhifNumber; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public LocalDate getHireDate() { return hireDate; }
    public void setHireDate(LocalDate hireDate) { this.hireDate = hireDate; }
    public String getEmploymentType() { return employmentType; }
    public void setEmploymentType(String employmentType) { this.employmentType = employmentType; }
    public BigDecimal getBasicSalary() { return basicSalary; }
    public void setBasicSalary(BigDecimal basicSalary) { this.basicSalary = basicSalary; }
    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }
    public String getBankAccount() { return bankAccount; }
    public void setBankAccount(String bankAccount) { this.bankAccount = bankAccount; }
    public String getEmergencyContactName() { return emergencyContactName; }
    public void setEmergencyContactName(String emergencyContactName) { this.emergencyContactName = emergencyContactName; }
    public String getEmergencyContactPhone() { return emergencyContactPhone; }
    public void setEmergencyContactPhone(String emergencyContactPhone) { this.emergencyContactPhone = emergencyContactPhone; }
    public String getPsvBadgeNumber() { return psvBadgeNumber; }
    public void setPsvBadgeNumber(String psvBadgeNumber) { this.psvBadgeNumber = psvBadgeNumber; }
    public LocalDate getPsvExpiry() { return psvExpiry; }
    public void setPsvExpiry(LocalDate psvExpiry) { this.psvExpiry = psvExpiry; }
    public boolean isK9Handler() { return k9Handler; }
    public void setK9Handler(boolean k9Handler) { this.k9Handler = k9Handler; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
