-- ============================================================
-- SECURITY GUARDS MANAGEMENT SYSTEM (SGMS)
-- MySQL Schema - Kenya Compliant
-- ============================================================

CREATE DATABASE IF NOT EXISTS sgms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sgms;

-- ============================================================
-- USERS & ROLES
-- ============================================================
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (name, description) VALUES
('SUPER_ADMIN', 'Full system access'),
('COMPANY_ADMIN', 'Company-level administration'),
('OPERATIONS_MANAGER', 'Manages operations, shifts, deployments'),
('SUPERVISOR', 'Supervises guards and sites'),
('GUARD', 'Field security guard'),
('CLIENT', 'Client portal access');

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    csrf_token VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- ============================================================
-- CLIENTS & SITES
-- ============================================================
CREATE TABLE clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150),
    email VARCHAR(150),
    phone VARCHAR(20),
    address TEXT,
    contract_start DATE,
    contract_end DATE,
    is_active BOOLEAN DEFAULT TRUE,
    user_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE sites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    site_name VARCHAR(200) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    site_type ENUM('COMMERCIAL','RESIDENTIAL','INDUSTRIAL','GOVERNMENT','OTHER') DEFAULT 'COMMERCIAL',
    risk_level ENUM('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT('MEDIUM'),
    required_guards INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- ============================================================
-- GUARDS
-- ============================================================
CREATE TABLE guards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    employee_number VARCHAR(50) UNIQUE NOT NULL,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    kra_pin VARCHAR(20),
    nssf_number VARCHAR(30),
    nhif_number VARCHAR(30),
    date_of_birth DATE,
    gender ENUM('MALE','FEMALE','OTHER'),
    hire_date DATE NOT NULL,
    employment_type ENUM('PERMANENT','CONTRACT','CASUAL') DEFAULT 'PERMANENT',
    basic_salary DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    bank_name VARCHAR(100),
    bank_account VARCHAR(50),
    emergency_contact_name VARCHAR(150),
    emergency_contact_phone VARCHAR(20),
    psv_badge_number VARCHAR(50) COMMENT 'Private Security license number',
    psv_expiry DATE,
    is_k9_handler BOOLEAN DEFAULT FALSE,
    status ENUM('ACTIVE','SUSPENDED','TERMINATED','ON_LEAVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================================
-- SHIFTS & SCHEDULING
-- ============================================================
CREATE TABLE shifts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    shift_name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    shift_date DATE NOT NULL,
    required_guards INT DEFAULT 1,
    status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES sites(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE shift_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    guard_id INT NOT NULL,
    assigned_by INT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ASSIGNED','CONFIRMED','NO_SHOW','COMPLETED','SWAPPED') DEFAULT 'ASSIGNED',
    UNIQUE KEY unique_shift_guard (shift_id, guard_id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (guard_id) REFERENCES guards(id),
    FOREIGN KEY (assigned_by) REFERENCES users(id)
);

-- ============================================================
-- ATTENDANCE
-- ============================================================
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guard_id INT NOT NULL,
    shift_id INT NOT NULL,
    check_in_time TIMESTAMP NULL,
    check_out_time TIMESTAMP NULL,
    check_in_method ENUM('GPS','QR_CODE','BIOMETRIC','MANUAL') DEFAULT 'MANUAL',
    check_in_latitude DECIMAL(10,8),
    check_in_longitude DECIMAL(11,8),
    check_out_latitude DECIMAL(10,8),
    check_out_longitude DECIMAL(11,8),
    check_in_verified BOOLEAN DEFAULT FALSE,
    status ENUM('PRESENT','ABSENT','LATE','EARLY_DEPARTURE','EXCUSED') DEFAULT 'ABSENT',
    notes TEXT,
    recorded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guard_id) REFERENCES guards(id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- ============================================================
-- PATROLS
-- ============================================================
CREATE TABLE patrol_checkpoints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    qr_code VARCHAR(255) UNIQUE,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (site_id) REFERENCES sites(id)
);

CREATE TABLE patrol_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guard_id INT NOT NULL,
    shift_id INT NOT NULL,
    checkpoint_id INT NOT NULL,
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    notes TEXT,
    FOREIGN KEY (guard_id) REFERENCES guards(id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (checkpoint_id) REFERENCES patrol_checkpoints(id)
);

-- ============================================================
-- INCIDENTS
-- ============================================================
CREATE TABLE incidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    guard_id INT NOT NULL,
    shift_id INT,
    incident_type ENUM('THEFT','TRESPASSING','ASSAULT','VANDALISM','FIRE','MEDICAL','K9_INCIDENT','EQUIPMENT_DAMAGE','OTHER') NOT NULL,
    severity ENUM('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT 'MEDIUM',
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    incident_datetime TIMESTAMP NOT NULL,
    location_details TEXT,
    action_taken TEXT,
    police_report_number VARCHAR(100),
    status ENUM('OPEN','UNDER_REVIEW','RESOLVED','CLOSED','ESCALATED') DEFAULT 'OPEN',
    reported_by INT,
    reviewed_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES sites(id),
    FOREIGN KEY (guard_id) REFERENCES guards(id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (reported_by) REFERENCES users(id),
    FOREIGN KEY (reviewed_by) REFERENCES users(id)
);

-- ============================================================
-- SECURITY EQUIPMENT
-- ============================================================
CREATE TABLE equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_type ENUM('BATON','FIREARM','HANDCUFFS','RADIO','BODY_CAMERA','TORCH','PEPPER_SPRAY','UNIFORM','OTHER') NOT NULL,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    make_model VARCHAR(150),
    description TEXT,
    condition_state ENUM('EXCELLENT','GOOD','FAIR','DAMAGED','DECOMMISSIONED') DEFAULT 'GOOD',
    acquisition_date DATE,
    acquisition_cost DECIMAL(10,2),
    license_number VARCHAR(100),
    license_expiry DATE,
    requires_license BOOLEAN DEFAULT FALSE,
    current_assignee_id INT NULL COMMENT 'Guard currently holding this equipment',
    current_site_id INT NULL,
    status ENUM('AVAILABLE','ASSIGNED','MAINTENANCE','LOST','DECOMMISSIONED') DEFAULT 'AVAILABLE',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (current_assignee_id) REFERENCES guards(id) ON DELETE SET NULL,
    FOREIGN KEY (current_site_id) REFERENCES sites(id) ON DELETE SET NULL
);

CREATE TABLE equipment_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id INT NOT NULL,
    guard_id INT NOT NULL,
    site_id INT,
    shift_id INT,
    issued_by INT,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    returned_at TIMESTAMP NULL,
    received_by INT NULL,
    condition_on_issue ENUM('EXCELLENT','GOOD','FAIR','DAMAGED') DEFAULT 'GOOD',
    condition_on_return ENUM('EXCELLENT','GOOD','FAIR','DAMAGED') NULL,
    notes TEXT,
    status ENUM('ISSUED','RETURNED','LOST','DAMAGED') DEFAULT 'ISSUED',
    FOREIGN KEY (equipment_id) REFERENCES equipment(id),
    FOREIGN KEY (guard_id) REFERENCES guards(id),
    FOREIGN KEY (site_id) REFERENCES sites(id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (issued_by) REFERENCES users(id),
    FOREIGN KEY (received_by) REFERENCES users(id)
);

CREATE TABLE equipment_maintenance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_id INT NOT NULL,
    maintenance_type ENUM('ROUTINE','REPAIR','INSPECTION','CALIBRATION') NOT NULL,
    description TEXT,
    maintenance_date DATE NOT NULL,
    cost DECIMAL(10,2),
    performed_by VARCHAR(150),
    next_maintenance_date DATE,
    notes TEXT,
    recorded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (equipment_id) REFERENCES equipment(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- ============================================================
-- K9 UNITS
-- ============================================================
CREATE TABLE k9_dogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    breed VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender ENUM('MALE','FEMALE') NOT NULL,
    chip_number VARCHAR(100) UNIQUE,
    training_level ENUM('BASIC','INTERMEDIATE','ADVANCED','SPECIALIST') DEFAULT 'BASIC',
    specialization ENUM('PATROL','DETECTION','TRACKING','ATTACK','MULTI') DEFAULT 'PATROL',
    current_handler_id INT NULL,
    status ENUM('ACTIVE','IN_TRAINING','MEDICAL_LEAVE','RETIRED','DECEASED') DEFAULT 'ACTIVE',
    acquired_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (current_handler_id) REFERENCES guards(id) ON DELETE SET NULL
);

CREATE TABLE k9_training_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dog_id INT NOT NULL,
    training_type VARCHAR(150) NOT NULL,
    trainer_name VARCHAR(150),
    start_date DATE NOT NULL,
    end_date DATE,
    result ENUM('PASSED','FAILED','IN_PROGRESS') DEFAULT 'IN_PROGRESS',
    certificate_number VARCHAR(100),
    expiry_date DATE,
    notes TEXT,
    recorded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dog_id) REFERENCES k9_dogs(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id)
);

CREATE TABLE k9_medical_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dog_id INT NOT NULL,
    record_type ENUM('VACCINATION','CHECKUP','TREATMENT','SURGERY','DEWORMING') NOT NULL,
    description TEXT NOT NULL,
    vet_name VARCHAR(150),
    visit_date DATE NOT NULL,
    next_visit_date DATE,
    cost DECIMAL(10,2),
    notes TEXT,
    recorded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dog_id) REFERENCES k9_dogs(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id)
);

CREATE TABLE k9_deployments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dog_id INT NOT NULL,
    handler_id INT NOT NULL,
    site_id INT NOT NULL,
    shift_id INT,
    deployed_at TIMESTAMP NOT NULL,
    retrieved_at TIMESTAMP NULL,
    purpose TEXT,
    incident_id INT NULL,
    notes TEXT,
    created_by INT,
    FOREIGN KEY (dog_id) REFERENCES k9_dogs(id),
    FOREIGN KEY (handler_id) REFERENCES guards(id),
    FOREIGN KEY (site_id) REFERENCES sites(id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- ============================================================
-- EMPLOYEE LIABILITY & DEDUCTIONS
-- ============================================================
CREATE TABLE liability_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guard_id INT NOT NULL,
    incident_id INT NULL,
    equipment_id INT NULL,
    dog_id INT NULL,
    liability_type ENUM('EQUIPMENT_DAMAGE','EQUIPMENT_LOSS','K9_INJURY','K9_NEGLIGENCE','OTHER') NOT NULL,
    description TEXT NOT NULL,
    severity ENUM('MINOR','MODERATE','MAJOR') DEFAULT 'MODERATE',
    estimated_cost DECIMAL(10,2) NOT NULL,
    approved_deduction DECIMAL(10,2) NULL,
    evidence_notes TEXT,
    status ENUM('PENDING','SUPERVISOR_APPROVED','MANAGER_APPROVED','HR_APPROVED','REJECTED','APPLIED') DEFAULT 'PENDING',
    supervisor_id INT NULL,
    supervisor_notes TEXT,
    supervisor_reviewed_at TIMESTAMP NULL,
    manager_id INT NULL,
    manager_notes TEXT,
    manager_reviewed_at TIMESTAMP NULL,
    hr_id INT NULL,
    hr_notes TEXT,
    hr_reviewed_at TIMESTAMP NULL,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (guard_id) REFERENCES guards(id),
    FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE SET NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE SET NULL,
    FOREIGN KEY (dog_id) REFERENCES k9_dogs(id) ON DELETE SET NULL,
    FOREIGN KEY (supervisor_id) REFERENCES users(id),
    FOREIGN KEY (manager_id) REFERENCES users(id),
    FOREIGN KEY (hr_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- ============================================================
-- PAYROLL
-- ============================================================
CREATE TABLE payroll_periods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    period_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    status ENUM('DRAFT','PROCESSING','APPROVED','PAID') DEFAULT 'DRAFT',
    created_by INT,
    approved_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

CREATE TABLE payslips (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payroll_period_id INT NOT NULL,
    guard_id INT NOT NULL,
    basic_salary DECIMAL(10,2) NOT NULL,
    allowances DECIMAL(10,2) DEFAULT 0.00,
    overtime_pay DECIMAL(10,2) DEFAULT 0.00,
    gross_pay DECIMAL(10,2) NOT NULL,
    -- Kenyan statutory deductions
    nssf_tier1 DECIMAL(10,2) DEFAULT 0.00 COMMENT 'NSSF Tier I: 6% of pensionable pay up to KES 6,000',
    nssf_tier2 DECIMAL(10,2) DEFAULT 0.00 COMMENT 'NSSF Tier II: 6% between KES 6,000 and KES 18,000',
    nhif_deduction DECIMAL(10,2) DEFAULT 0.00 COMMENT 'NHIF based on income bracket',
    paye_tax DECIMAL(10,2) DEFAULT 0.00 COMMENT 'PAYE per KRA bands',
    total_statutory_deductions DECIMAL(10,2) DEFAULT 0.00,
    net_before_liability DECIMAL(10,2) NOT NULL,
    liability_deduction DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Max 30% of net salary',
    other_deductions DECIMAL(10,2) DEFAULT 0.00,
    net_pay DECIMAL(10,2) NOT NULL,
    payment_status ENUM('PENDING','PAID','ON_HOLD') DEFAULT 'PENDING',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_payslip (payroll_period_id, guard_id),
    FOREIGN KEY (payroll_period_id) REFERENCES payroll_periods(id),
    FOREIGN KEY (guard_id) REFERENCES guards(id)
);

CREATE TABLE liability_deduction_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    liability_report_id INT NOT NULL,
    payslip_id INT NOT NULL,
    amount_deducted DECIMAL(10,2) NOT NULL,
    installment_number INT DEFAULT 1,
    total_installments INT DEFAULT 1,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (liability_report_id) REFERENCES liability_reports(id),
    FOREIGN KEY (payslip_id) REFERENCES payslips(id)
);

-- ============================================================
-- AUDIT LOG
-- ============================================================
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_user_action (user_id, action),
    INDEX idx_created (created_at)
);

-- ============================================================
-- DEFAULT ADMIN USER (password: Admin@1234)
-- ============================================================
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, role_id)
VALUES ('admin', 'admin@sgms.co.ke',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewWbQ1L5Ql1UeZ2G',
        'System', 'Administrator', '+254700000000', 1);
