package com.sgms.model;

import java.time.LocalDateTime;

public class Incident {
    private int id;
    private int siteId;
    private String siteName;
    private int guardId;
    private String guardName;
    private Integer shiftId;
    private String incidentType;
    private String severity;
    private String title;
    private String description;
    private LocalDateTime incidentDatetime;
    private String locationDetails;
    private String actionTaken;
    private String policeReportNumber;
    private String status;
    private Integer reportedBy;
    private String reportedByName;
    private Integer reviewedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getSiteId() { return siteId; }
    public void setSiteId(int siteId) { this.siteId = siteId; }
    public String getSiteName() { return siteName; }
    public void setSiteName(String siteName) { this.siteName = siteName; }
    public int getGuardId() { return guardId; }
    public void setGuardId(int guardId) { this.guardId = guardId; }
    public String getGuardName() { return guardName; }
    public void setGuardName(String guardName) { this.guardName = guardName; }
    public Integer getShiftId() { return shiftId; }
    public void setShiftId(Integer shiftId) { this.shiftId = shiftId; }
    public String getIncidentType() { return incidentType; }
    public void setIncidentType(String incidentType) { this.incidentType = incidentType; }
    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getIncidentDatetime() { return incidentDatetime; }
    public void setIncidentDatetime(LocalDateTime incidentDatetime) { this.incidentDatetime = incidentDatetime; }
    public String getLocationDetails() { return locationDetails; }
    public void setLocationDetails(String locationDetails) { this.locationDetails = locationDetails; }
    public String getActionTaken() { return actionTaken; }
    public void setActionTaken(String actionTaken) { this.actionTaken = actionTaken; }
    public String getPoliceReportNumber() { return policeReportNumber; }
    public void setPoliceReportNumber(String policeReportNumber) { this.policeReportNumber = policeReportNumber; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getReportedBy() { return reportedBy; }
    public void setReportedBy(Integer reportedBy) { this.reportedBy = reportedBy; }
    public String getReportedByName() { return reportedByName; }
    public void setReportedByName(String reportedByName) { this.reportedByName = reportedByName; }
    public Integer getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(Integer reviewedBy) { this.reviewedBy = reviewedBy; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
