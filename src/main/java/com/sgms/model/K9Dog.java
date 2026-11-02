package com.sgms.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class K9Dog {
    private int id;
    private String name;
    private String breed;
    private LocalDate dateOfBirth;
    private String gender;
    private String chipNumber;
    private String trainingLevel;
    private String specialization;
    private Integer currentHandlerId;
    private String currentHandlerName;
    private String status;
    private LocalDate acquiredDate;
    private String notes;
    private LocalDateTime createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getBreed() { return breed; }
    public void setBreed(String breed) { this.breed = breed; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getChipNumber() { return chipNumber; }
    public void setChipNumber(String chipNumber) { this.chipNumber = chipNumber; }
    public String getTrainingLevel() { return trainingLevel; }
    public void setTrainingLevel(String trainingLevel) { this.trainingLevel = trainingLevel; }
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    public Integer getCurrentHandlerId() { return currentHandlerId; }
    public void setCurrentHandlerId(Integer currentHandlerId) { this.currentHandlerId = currentHandlerId; }
    public String getCurrentHandlerName() { return currentHandlerName; }
    public void setCurrentHandlerName(String currentHandlerName) { this.currentHandlerName = currentHandlerName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDate getAcquiredDate() { return acquiredDate; }
    public void setAcquiredDate(LocalDate acquiredDate) { this.acquiredDate = acquiredDate; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
