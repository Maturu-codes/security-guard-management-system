package com.sgms.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

public class Shift {
    private int id;
    private int siteId;
    private String siteName;
    private String clientName;
    private String shiftName;
    private LocalTime startTime;
    private LocalTime endTime;
    private LocalDate shiftDate;
    private int requiredGuards;
    private int assignedGuards;
    private String status;
    private Integer createdBy;
    private LocalDateTime createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getSiteId() { return siteId; }
    public void setSiteId(int siteId) { this.siteId = siteId; }
    public String getSiteName() { return siteName; }
    public void setSiteName(String siteName) { this.siteName = siteName; }
    public String getClientName() { return clientName; }
    public void setClientName(String clientName) { this.clientName = clientName; }
    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }
    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }
    public LocalDate getShiftDate() { return shiftDate; }
    public void setShiftDate(LocalDate shiftDate) { this.shiftDate = shiftDate; }
    public int getRequiredGuards() { return requiredGuards; }
    public void setRequiredGuards(int requiredGuards) { this.requiredGuards = requiredGuards; }
    public int getAssignedGuards() { return assignedGuards; }
    public void setAssignedGuards(int assignedGuards) { this.assignedGuards = assignedGuards; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
