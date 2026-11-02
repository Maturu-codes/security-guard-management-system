<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Guard Profile" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/guards" class="btn btn-outline-secondary me-3">
        <i class="fas fa-arrow-left me-1"></i>Back
    </a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0">
            <i class="fas fa-user-shield me-2 text-primary"></i>
            <c:out value="${guard.fullName}"/>
        </h1>
        <small class="text-muted">Employee #<c:out value="${guard.employeeNumber}"/></small>
    </div>
    <c:if test="${guard.k9Handler}">
        <span class="badge bg-warning text-dark me-2"><i class="fas fa-dog me-1"></i>K9 Handler</span>
    </c:if>
    <span class="badge fs-6 ${guard.status == 'ACTIVE' ? 'bg-success' :
        guard.status == 'SUSPENDED' ? 'bg-warning text-dark' :
        guard.status == 'TERMINATED' ? 'bg-danger' : 'bg-secondary'}">
        <c:out value="${guard.status}"/>
    </span>
    <c:if test="${sessionScope.userRole != 'CLIENT' && sessionScope.userRole != 'GUARD'}">
    <a href="${pageContext.request.contextPath}/guards/edit/${guard.id}" class="btn btn-outline-primary ms-2">
        <i class="fas fa-edit me-1"></i>Edit
    </a>
    </c:if>
</div>

<div class="row g-4">
    <!-- Personal Info -->
    <div class="col-md-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-primary text-white fw-semibold py-2">
                <i class="fas fa-user me-2"></i>Personal
            </div>
            <div class="card-body small">
                <dl class="row mb-0">
                    <dt class="col-6 text-muted">National ID</dt>
                    <dd class="col-6"><c:out value="${guard.nationalId}"/></dd>
                    <dt class="col-6 text-muted">Gender</dt>
                    <dd class="col-6"><c:out value="${guard.gender}"/></dd>
                    <dt class="col-6 text-muted">Date of Birth</dt>
                    <dd class="col-6">${guard.dateOfBirth}</dd>
                    <dt class="col-6 text-muted">Email</dt>
                    <dd class="col-6 text-break"><c:out value="${guard.email}"/></dd>
                    <dt class="col-6 text-muted">Phone</dt>
                    <dd class="col-6"><c:out value="${guard.phone}"/></dd>
                </dl>
            </div>
        </div>
    </div>

    <!-- Employment -->
    <div class="col-md-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-success text-white fw-semibold py-2">
                <i class="fas fa-briefcase me-2"></i>Employment
            </div>
            <div class="card-body small">
                <dl class="row mb-0">
                    <dt class="col-6 text-muted">Hire Date</dt>
                    <dd class="col-6">${guard.hireDate}</dd>
                    <dt class="col-6 text-muted">Type</dt>
                    <dd class="col-6"><c:out value="${guard.employmentType}"/></dd>
                    <dt class="col-6 text-muted">Basic Salary</dt>
                    <dd class="col-6 fw-bold text-success">
                        KES <fmt:formatNumber value="${guard.basicSalary}" pattern="#,##0.00"/>
                    </dd>
                    <dt class="col-6 text-muted">KRA PIN</dt>
                    <dd class="col-6"><c:out value="${guard.kraPin}"/></dd>
                    <dt class="col-6 text-muted">NSSF No.</dt>
                    <dd class="col-6"><c:out value="${guard.nssfNumber}"/></dd>
                    <dt class="col-6 text-muted">NHIF No.</dt>
                    <dd class="col-6"><c:out value="${guard.nhifNumber}"/></dd>
                </dl>
            </div>
        </div>
    </div>

    <!-- PSV License -->
    <div class="col-md-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-warning text-dark fw-semibold py-2">
                <i class="fas fa-id-card me-2"></i>License &amp; Banking
            </div>
            <div class="card-body small">
                <dl class="row mb-0">
                    <dt class="col-6 text-muted">PSV Badge</dt>
                    <dd class="col-6"><c:out value="${guard.psvBadgeNumber}"/></dd>
                    <dt class="col-6 text-muted">PSV Expiry</dt>
                    <dd class="col-6">
                        <c:out value="${guard.psvExpiry}"/>
                    </dd>
                    <dt class="col-12 text-muted mt-2">Banking</dt>
                    <dt class="col-6 text-muted">Bank</dt>
                    <dd class="col-6"><c:out value="${guard.bankName}"/></dd>
                    <dt class="col-6 text-muted">Account</dt>
                    <dd class="col-6"><c:out value="${guard.bankAccount}"/></dd>
                </dl>
            </div>
        </div>
    </div>

    <!-- Emergency Contact -->
    <div class="col-md-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-danger text-white fw-semibold py-2">
                <i class="fas fa-phone-volume me-2"></i>Emergency Contact
            </div>
            <div class="card-body small">
                <dl class="row mb-0">
                    <dt class="col-6 text-muted">Name</dt>
                    <dd class="col-6"><c:out value="${guard.emergencyContactName}"/></dd>
                    <dt class="col-6 text-muted">Phone</dt>
                    <dd class="col-6"><c:out value="${guard.emergencyContactPhone}"/></dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
