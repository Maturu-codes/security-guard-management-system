<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="New Liability Report" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/liability" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-gavel me-2 text-danger"></i>New Liability Report</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:750px;">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/liability/create" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Guard <span class="text-danger">*</span></label>
                    <select class="form-select" name="guardId" required>
                        <option value="">Select guard...</option>
                        <c:forEach var="g" items="${guards}">
                            <option value="${g.id}"><c:out value="${g.fullName}"/> (<c:out value="${g.employeeNumber}"/>)</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Liability Type <span class="text-danger">*</span></label>
                    <select class="form-select" name="liabilityType" required>
                        <option value="">Select type...</option>
                        <option value="EQUIPMENT_DAMAGE">Equipment Damage</option>
                        <option value="EQUIPMENT_LOSS">Equipment Loss</option>
                        <option value="K9_INJURY">K9 Injury</option>
                        <option value="K9_NEGLIGENCE">K9 Negligence</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Severity</label>
                    <select class="form-select" name="severity">
                        <option value="MINOR">Minor</option>
                        <option value="MODERATE" selected>Moderate</option>
                        <option value="MAJOR">Major</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Estimated Cost (KES) <span class="text-danger">*</span></label>
                    <input type="number" class="form-control" name="estimatedCost" required min="0" step="0.01" placeholder="0.00">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Linked Incident ID <small class="text-muted">(optional)</small></label>
                    <input type="number" class="form-control" name="incidentId" min="1" placeholder="Incident #">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Linked Equipment ID <small class="text-muted">(optional)</small></label>
                    <input type="number" class="form-control" name="equipmentId" min="1" placeholder="Equipment #">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Linked K9 Dog ID <small class="text-muted">(optional)</small></label>
                    <input type="number" class="form-control" name="dogId" min="1" placeholder="K9 Dog #">
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Description <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="description" rows="3" required placeholder="Describe the incident and basis for liability..."></textarea>
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Evidence / Notes</label>
                    <textarea class="form-control" name="evidenceNotes" rows="2" placeholder="Witness names, photo references, report numbers..."></textarea>
                </div>
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/liability" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-danger px-4"><i class="fas fa-file-alt me-2"></i>Submit Report</button>
                </div>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
