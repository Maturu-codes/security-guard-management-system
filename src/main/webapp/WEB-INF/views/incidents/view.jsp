<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Incident #${incident.id}" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary me-3">
        <i class="fas fa-arrow-left me-1"></i>Back
    </a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0">
            <i class="fas fa-triangle-exclamation me-2 text-danger"></i>
            Incident #${incident.id}
        </h1>
        <p class="text-muted mb-0"><c:out value="${incident.title}"/></p>
    </div>
    <span class="badge fs-6 ${incident.severity == 'CRITICAL' ? 'bg-danger' :
        incident.severity == 'HIGH' ? 'bg-warning text-dark' : 'bg-secondary'} me-2">
        <c:out value="${incident.severity}"/>
    </span>
    <span class="badge fs-6 ${incident.status == 'OPEN' ? 'bg-danger' :
        incident.status == 'RESOLVED' ? 'bg-success' : 'bg-secondary'}">
        <c:out value="${incident.status}"/>
    </span>
</div>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold">
                <i class="fas fa-file-alt me-2"></i>Incident Report
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">TYPE</label>
                        <div><span class="badge bg-secondary"><c:out value="${incident.incidentType}"/></span></div>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">DATE &amp; TIME</label>
                        <div><fmt:formatDate value="${incident.incidentDatetime}" pattern="dd MMM yyyy, HH:mm"/></div>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">SITE</label>
                        <div class="fw-semibold"><c:out value="${incident.siteName}"/></div>
                    </div>
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">GUARD</label>
                        <div class="fw-semibold"><c:out value="${incident.guardName}"/></div>
                    </div>
                    <c:if test="${not empty incident.locationDetails}">
                    <div class="col-12">
                        <label class="text-muted small fw-semibold">LOCATION</label>
                        <div><c:out value="${incident.locationDetails}"/></div>
                    </div>
                    </c:if>
                    <div class="col-12">
                        <label class="text-muted small fw-semibold">DESCRIPTION</label>
                        <div class="p-3 bg-light rounded"><c:out value="${incident.description}"/></div>
                    </div>
                    <c:if test="${not empty incident.actionTaken}">
                    <div class="col-12">
                        <label class="text-muted small fw-semibold">ACTION TAKEN</label>
                        <div class="p-3 bg-light rounded"><c:out value="${incident.actionTaken}"/></div>
                    </div>
                    </c:if>
                    <c:if test="${not empty incident.policeReportNumber}">
                    <div class="col-md-6">
                        <label class="text-muted small fw-semibold">POLICE OB NUMBER</label>
                        <div><span class="badge bg-dark"><c:out value="${incident.policeReportNumber}"/></span></div>
                    </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <!-- Status management (for supervisors and above) -->
        <c:if test="${sessionScope.userRole != 'CLIENT' && sessionScope.userRole != 'GUARD'}">
        <div class="card border-0 shadow-sm mb-3">
            <div class="card-header fw-semibold">
                <i class="fas fa-sliders me-2"></i>Manage Status
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/incidents/updateStatus/${incident.id}" method="post">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Change Status</label>
                        <select class="form-select" name="status">
                            <option value="OPEN" ${incident.status == 'OPEN' ? 'selected' : ''}>Open</option>
                            <option value="UNDER_REVIEW" ${incident.status == 'UNDER_REVIEW' ? 'selected' : ''}>Under Review</option>
                            <option value="ESCALATED" ${incident.status == 'ESCALATED' ? 'selected' : ''}>Escalated</option>
                            <option value="RESOLVED" ${incident.status == 'RESOLVED' ? 'selected' : ''}>Resolved</option>
                            <option value="CLOSED" ${incident.status == 'CLOSED' ? 'selected' : ''}>Closed</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-save me-2"></i>Update Status
                    </button>
                </form>
            </div>
        </div>
        </c:if>

        <!-- Metadata -->
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold">
                <i class="fas fa-circle-info me-2"></i>Metadata
            </div>
            <div class="card-body">
                <div class="mb-2">
                    <span class="text-muted small">Reported by:</span>
                    <div class="fw-semibold"><c:out value="${incident.reportedByName}"/></div>
                </div>
                <div class="mb-2">
                    <span class="text-muted small">Created at:</span>
                    <div><fmt:formatDate value="${incident.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                </div>
                <c:if test="${not empty incident.updatedAt}">
                <div>
                    <span class="text-muted small">Last updated:</span>
                    <div><fmt:formatDate value="${incident.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
