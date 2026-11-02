<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty guard}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Guard' : 'Add Guard'}" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/guards" class="btn btn-outline-secondary me-3">
        <i class="fas fa-arrow-left me-1"></i>Back
    </a>
    <div>
        <h1 class="h3 fw-bold mb-0">
            <i class="fas fa-${isEdit ? 'user-pen' : 'user-plus'} me-2 text-primary"></i>
            ${isEdit ? 'Edit Guard' : 'Add New Guard'}
        </h1>
    </div>
</div>

<form action="${pageContext.request.contextPath}/guards/${isEdit ? 'update/'.concat(guard.id) : 'create'}"
      method="post" novalidate class="needs-validation">
    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">

    <div class="row g-4">
        <!-- Personal Info -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-primary text-white fw-semibold">
                    <i class="fas fa-user me-2"></i>Personal Information
                </div>
                <div class="card-body">
                    <c:if test="${not isEdit}">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">First Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="firstName" required
                                   value="<c:out value='${guard.firstName}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Last Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="lastName" required
                                   value="<c:out value='${guard.lastName}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Username <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="username" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" name="email" required
                                   value="<c:out value='${guard.email}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Phone</label>
                            <input type="tel" class="form-control" name="phone"
                                   placeholder="+254..." value="<c:out value='${guard.phone}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Temp Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" name="tempPassword" required minlength="8">
                            <div class="form-text">Min 8 characters. Guard must change on first login.</div>
                        </div>
                    </div>
                    </c:if>

                    <div class="row g-3 mt-0">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">National ID <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="nationalId" required
                                   value="<c:out value='${guard.nationalId}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Gender</label>
                            <select class="form-select" name="gender">
                                <option value="">Select...</option>
                                <option value="MALE" ${guard.gender == 'MALE' ? 'selected' : ''}>Male</option>
                                <option value="FEMALE" ${guard.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                                <option value="OTHER" ${guard.gender == 'OTHER' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Date of Birth</label>
                            <input type="date" class="form-control" name="dateOfBirth"
                                   value="${guard.dateOfBirth}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Employee Number <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="employeeNumber" required
                                   value="<c:out value='${guard.employeeNumber}'/>">
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Employment Info -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-success text-white fw-semibold">
                    <i class="fas fa-briefcase me-2"></i>Employment Details
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Hire Date <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" name="hireDate" required
                                   value="${guard.hireDate}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Employment Type</label>
                            <select class="form-select" name="employmentType">
                                <option value="PERMANENT" ${guard.employmentType == 'PERMANENT' ? 'selected' : ''}>Permanent</option>
                                <option value="CONTRACT" ${guard.employmentType == 'CONTRACT' ? 'selected' : ''}>Contract</option>
                                <option value="CASUAL" ${guard.employmentType == 'CASUAL' ? 'selected' : ''}>Casual</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Basic Salary (KES)</label>
                            <input type="number" class="form-control" name="basicSalary" min="0" step="0.01"
                                   value="${guard.basicSalary}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Status</label>
                            <select class="form-select" name="status">
                                <option value="ACTIVE" ${guard.status == 'ACTIVE' || empty guard.status ? 'selected' : ''}>Active</option>
                                <option value="ON_LEAVE" ${guard.status == 'ON_LEAVE' ? 'selected' : ''}>On Leave</option>
                                <option value="SUSPENDED" ${guard.status == 'SUSPENDED' ? 'selected' : ''}>Suspended</option>
                                <option value="TERMINATED" ${guard.status == 'TERMINATED' ? 'selected' : ''}>Terminated</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">KRA PIN</label>
                            <input type="text" class="form-control" name="kraPin"
                                   value="<c:out value='${guard.kraPin}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">NSSF Number</label>
                            <input type="text" class="form-control" name="nssfNumber"
                                   value="<c:out value='${guard.nssfNumber}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">NHIF Number</label>
                            <input type="text" class="form-control" name="nhifNumber"
                                   value="<c:out value='${guard.nhifNumber}'/>">
                        </div>
                        <div class="col-md-6 d-flex align-items-end">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="k9Handler"
                                       name="isK9Handler" value="on"
                                       ${guard.k9Handler ? 'checked' : ''}>
                                <label class="form-check-label fw-semibold" for="k9Handler">
                                    <i class="fas fa-dog me-1 text-warning"></i>K9 Handler
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- PSV License -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-warning text-dark fw-semibold">
                    <i class="fas fa-id-card me-2"></i>PSV License (PSRA)
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">PSV Badge Number</label>
                        <input type="text" class="form-control" name="psvBadgeNumber"
                               value="<c:out value='${guard.psvBadgeNumber}'/>">
                    </div>
                    <div class="mb-0">
                        <label class="form-label fw-semibold">PSV Expiry Date</label>
                        <input type="date" class="form-control" name="psvExpiry"
                               value="${guard.psvExpiry}">
                    </div>
                </div>
            </div>
        </div>

        <!-- Bank Details -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-info text-white fw-semibold">
                    <i class="fas fa-building-columns me-2"></i>Banking Details
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Bank Name</label>
                        <input type="text" class="form-control" name="bankName"
                               value="<c:out value='${guard.bankName}'/>">
                    </div>
                    <div class="mb-0">
                        <label class="form-label fw-semibold">Account Number</label>
                        <input type="text" class="form-control" name="bankAccount"
                               value="<c:out value='${guard.bankAccount}'/>">
                    </div>
                </div>
            </div>
        </div>

        <!-- Emergency Contact -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-danger text-white fw-semibold">
                    <i class="fas fa-phone-volume me-2"></i>Emergency Contact
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Contact Name</label>
                        <input type="text" class="form-control" name="emergencyContactName"
                               value="<c:out value='${guard.emergencyContactName}'/>">
                    </div>
                    <div class="mb-0">
                        <label class="form-label fw-semibold">Contact Phone</label>
                        <input type="tel" class="form-control" name="emergencyContactPhone"
                               placeholder="+254..."
                               value="<c:out value='${guard.emergencyContactPhone}'/>">
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12">
            <div class="d-flex gap-3 justify-content-end">
                <a href="${pageContext.request.contextPath}/guards" class="btn btn-outline-secondary px-4">
                    Cancel
                </a>
                <button type="submit" class="btn btn-primary px-5">
                    <i class="fas fa-save me-2"></i>${isEdit ? 'Update Guard' : 'Create Guard'}
                </button>
            </div>
        </div>
    </div>
</form>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
