package com.sgms.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Equipment {
    private int id;
    private String equipmentType;
    private String serialNumber;
    private String makeModel;
    private String description;
    private String conditionState;
    private LocalDate acquisitionDate;
    private BigDecimal acquisitionCost;
    private String licenseNumber;
    private LocalDate licenseExpiry;
    private boolean requiresLicense;
    private Integer currentAssigneeId;
    private String currentAssigneeName;
    private Integer currentSiteId;
    private String currentSiteName;
    private String status;
    private String notes;
    private LocalDateTime createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getEquipmentType() { return equipmentType; }
    public void setEquipmentType(String equipmentType) { this.equipmentType = equipmentType; }
    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }
    public String getMakeModel() { return makeModel; }
    public void setMakeModel(String makeModel) { this.makeModel = makeModel; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getConditionState() { return conditionState; }
    public void setConditionState(String conditionState) { this.conditionState = conditionState; }
    public LocalDate getAcquisitionDate() { return acquisitionDate; }
    public void setAcquisitionDate(LocalDate acquisitionDate) { this.acquisitionDate = acquisitionDate; }
    public BigDecimal getAcquisitionCost() { return acquisitionCost; }
    public void setAcquisitionCost(BigDecimal acquisitionCost) { this.acquisitionCost = acquisitionCost; }
    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) { this.licenseNumber = licenseNumber; }
    public LocalDate getLicenseExpiry() { return licenseExpiry; }
    public void setLicenseExpiry(LocalDate licenseExpiry) { this.licenseExpiry = licenseExpiry; }
    public boolean isRequiresLicense() { return requiresLicense; }
    public void setRequiresLicense(boolean requiresLicense) { this.requiresLicense = requiresLicense; }
    public Integer getCurrentAssigneeId() { return currentAssigneeId; }
    public void setCurrentAssigneeId(Integer currentAssigneeId) { this.currentAssigneeId = currentAssigneeId; }
    public String getCurrentAssigneeName() { return currentAssigneeName; }
    public void setCurrentAssigneeName(String currentAssigneeName) { this.currentAssigneeName = currentAssigneeName; }
    public Integer getCurrentSiteId() { return currentSiteId; }
    public void setCurrentSiteId(Integer currentSiteId) { this.currentSiteId = currentSiteId; }
    public String getCurrentSiteName() { return currentSiteName; }
    public void setCurrentSiteName(String currentSiteName) { this.currentSiteName = currentSiteName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
