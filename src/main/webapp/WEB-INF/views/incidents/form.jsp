<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Report Incident" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary me-3">
        <i class="fas fa-arrow-left me-1"></i>Back
    </a>
    <h1 class="h3 fw-bold mb-0">
        <i class="fas fa-triangle-exclamation me-2 text-danger"></i>Report Incident
    </h1>
</div>

<form action="${pageContext.request.contextPath}/incidents/create" method="post" novalidate class="needs-validation">
    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-danger text-white fw-semibold">
                    <i class="fas fa-file-circle-exclamation me-2"></i>Incident Details
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label fw-semibold">Incident Title <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="title" required maxlength="200"
                                   placeholder="Brief description of the incident">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Incident Type <span class="text-danger">*</span></label>
                            <select class="form-select" name="incidentType" required>
                                <option value="">Select type...</option>
                                <option>THEFT</option>
                                <option>TRESPASSING</option>
                                <option>ASSAULT</option>
                                <option>VANDALISM</option>
                                <option>FIRE</option>
                                <option>MEDICAL</option>
                                <option>K9_INCIDENT</option>
                                <option>EQUIPMENT_DAMAGE</option>
                                <option>OTHER</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Severity <span class="text-danger">*</span></label>
                            <select class="form-select" name="severity" required>
                                <option value="LOW">Low</option>
                                <option value="MEDIUM" selected>Medium</option>
                                <option value="HIGH">High</option>
                                <option value="CRITICAL">Critical</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Reporting Guard <span class="text-danger">*</span></label>
                            <select class="form-select" name="guardId" required>
                                <option value="">Select guard...</option>
                                <c:forEach var="g" items="${guards}">
                                    <option value="${g.id}">
                                        <c:out value="${g.fullName}"/> (<c:out value="${g.employeeNumber}"/>)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Site ID <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="siteId" required min="1"
                                   placeholder="Enter site ID">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Incident Date &amp; Time <span class="text-danger">*</span></label>
                            <input type="datetime-local" class="form-control" name="incidentDatetime" required
                                   value="${pageContext.response.characterEncoding}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Police Report Number</label>
                            <input type="text" class="form-control" name="policeReportNumber"
                                   placeholder="OB/XXX/2024">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Full Description <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="description" rows="5" required
                                      placeholder="Provide a detailed account of what happened..."></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Location Details</label>
                            <input type="text" class="form-control" name="locationDetails"
                                   placeholder="Specific location within the site">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Action Taken</label>
                            <textarea class="form-control" name="actionTaken" rows="3"
                                      placeholder="What immediate actions were taken?"></textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card border-0 shadow-sm mb-3 border-danger border-top border-3">
                <div class="card-body">
                    <h6 class="fw-bold text-danger"><i class="fas fa-info-circle me-2"></i>Reporting Guidelines</h6>
                    <ul class="list-unstyled small text-muted">
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Report all incidents immediately</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Be specific about time and location</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Include all parties involved</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Note any witnesses present</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Attach police OB number if applicable</li>
                    </ul>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body">
                    <div class="alert alert-warning mb-3 py-2 small">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <strong>CRITICAL</strong> incidents trigger immediate escalation to management.
                    </div>
                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-danger btn-lg">
                            <i class="fas fa-paper-plane me-2"></i>Submit Incident Report
                        </button>
                        <a href="${pageContext.request.contextPath}/incidents" class="btn btn-outline-secondary">
                            Cancel
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
