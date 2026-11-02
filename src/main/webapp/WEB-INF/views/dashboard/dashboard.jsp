<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Dashboard" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 mb-0 fw-bold"><i class="fas fa-gauge me-2 text-warning"></i>Dashboard</h1>
        <p class="text-muted mb-0">Welcome back, <c:out value="${sessionScope.userFullName}"/>!</p>
    </div>
    <div class="text-muted small">
        <i class="fas fa-calendar me-1"></i>
        <%= new java.text.SimpleDateFormat("EEEE, dd MMMM yyyy").format(new java.util.Date()) %>
    </div>
</div>

<!-- KPI Cards -->
<div class="row g-4 mb-4">
    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100 border-start border-primary border-4">
            <div class="card-body">
                <div class="d-flex align-items-center">
                    <div class="flex-grow-1">
                        <div class="text-muted small text-uppercase fw-semibold">Active Guards</div>
                        <div class="h2 fw-bold mb-0 text-primary">${totalActiveGuards}</div>
                    </div>
                    <div class="ms-3">
                        <i class="fas fa-user-shield fa-2x text-primary opacity-50"></i>
                    </div>
                </div>
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/guards" class="text-decoration-none small">
                        View all guards <i class="fas fa-arrow-right ms-1"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100 border-start border-danger border-4">
            <div class="card-body">
                <div class="d-flex align-items-center">
                    <div class="flex-grow-1">
                        <div class="text-muted small text-uppercase fw-semibold">Open Incidents</div>
                        <div class="h2 fw-bold mb-0 text-danger">${openIncidents}</div>
                    </div>
                    <div class="ms-3">
                        <i class="fas fa-triangle-exclamation fa-2x text-danger opacity-50"></i>
                    </div>
                </div>
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/incidents" class="text-decoration-none small">
                        View incidents <i class="fas fa-arrow-right ms-1"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100 border-start border-success border-4">
            <div class="card-body">
                <div class="d-flex align-items-center">
                    <div class="flex-grow-1">
                        <div class="text-muted small text-uppercase fw-semibold">Active Shifts</div>
                        <div class="h2 fw-bold mb-0 text-success">—</div>
                    </div>
                    <div class="ms-3">
                        <i class="fas fa-clock fa-2x text-success opacity-50"></i>
                    </div>
                </div>
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/shifts" class="text-decoration-none small">
                        View shifts <i class="fas fa-arrow-right ms-1"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm h-100 border-start border-warning border-4">
            <div class="card-body">
                <div class="d-flex align-items-center">
                    <div class="flex-grow-1">
                        <div class="text-muted small text-uppercase fw-semibold">K9 Units</div>
                        <div class="h2 fw-bold mb-0 text-warning">—</div>
                    </div>
                    <div class="ms-3">
                        <i class="fas fa-dog fa-2x text-warning opacity-50"></i>
                    </div>
                </div>
                <div class="mt-2">
                    <a href="${pageContext.request.contextPath}/k9" class="text-decoration-none small">
                        View K9 units <i class="fas fa-arrow-right ms-1"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Quick Actions + Critical Incidents -->
<div class="row g-4">
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold border-0 pb-0">
                <i class="fas fa-bolt me-2 text-warning"></i>Quick Actions
            </div>
            <div class="card-body">
                <div class="d-grid gap-2">
                    <a href="${pageContext.request.contextPath}/incidents/new" class="btn btn-outline-danger">
                        <i class="fas fa-triangle-exclamation me-2"></i>Report Incident
                    </a>
                    <a href="${pageContext.request.contextPath}/attendance" class="btn btn-outline-success">
                        <i class="fas fa-clipboard-check me-2"></i>Record Attendance
                    </a>
                    <a href="${pageContext.request.contextPath}/guards/new" class="btn btn-outline-primary">
                        <i class="fas fa-user-plus me-2"></i>Add Guard
                    </a>
                    <a href="${pageContext.request.contextPath}/shifts/new" class="btn btn-outline-secondary">
                        <i class="fas fa-calendar-plus me-2"></i>Schedule Shift
                    </a>
                    <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-dark">
                        <i class="fas fa-toolbox me-2"></i>Equipment Tracker
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-8">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white fw-semibold border-0 pb-0">
                <i class="fas fa-siren-on me-2 text-danger"></i>Critical / Escalated Incidents
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty criticalIncidents}">
                        <div class="text-center text-muted py-5">
                            <i class="fas fa-check-circle fa-3x mb-3 text-success"></i>
                            <p>No critical open incidents. All clear!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Title</th>
                                        <th>Site</th>
                                        <th>Severity</th>
                                        <th>Status</th>
                                        <th>Date</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="inc" items="${criticalIncidents}">
                                    <tr>
                                        <td class="fw-semibold"><c:out value="${inc.title}"/></td>
                                        <td><c:out value="${inc.siteName}"/></td>
                                        <td>
                                            <span class="badge ${inc.severity == 'CRITICAL' ? 'bg-danger' : 'bg-warning text-dark'}">
                                                <c:out value="${inc.severity}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge ${inc.status == 'ESCALATED' ? 'bg-danger' : 'bg-secondary'}">
                                                <c:out value="${inc.status}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${inc.incidentDatetime}" pattern="dd/MM/yy HH:mm"/>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/incidents/view/${inc.id}"
                                               class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- Module Navigation Grid -->
<div class="row g-3 mt-2">
    <div class="col-12"><h5 class="fw-bold text-muted">All Modules</h5></div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/guards" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-user-shield fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Guards</div>
                <small class="text-muted">Manage security personnel</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/shifts" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-calendar-days fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Shifts</div>
                <small class="text-muted">Schedule &amp; deployments</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/attendance" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-clipboard-check fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Attendance</div>
                <small class="text-muted">Time &amp; attendance</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/incidents" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-triangle-exclamation fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Incidents</div>
                <small class="text-muted">Report &amp; track</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/equipment" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-gun fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Equipment</div>
                <small class="text-muted">Track gear &amp; weapons</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/k9" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-dog fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">K9 Units</div>
                <small class="text-muted">Dog units &amp; handlers</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/clients" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-building fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Clients</div>
                <small class="text-muted">Sites &amp; contracts</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/payroll" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-coins fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Payroll</div>
                <small class="text-muted">Kenya-compliant payroll</small>
            </div>
        </a>
    </div>

    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
        <a href="${pageContext.request.contextPath}/liability" class="text-decoration-none">
            <div class="card border-0 shadow-sm text-center py-3 h-100 module-card">
                <i class="fas fa-gavel fa-2x mb-2 text-primary"></i>
                <div class="fw-semibold">Liability</div>
                <small class="text-muted">Deduction management</small>
            </div>
        </a>
    </div>

</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
