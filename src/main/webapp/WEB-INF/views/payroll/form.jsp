<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="New Payroll Period" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/payroll" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-coins me-2 text-success"></i>New Payroll Period</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:600px;">
    <div class="card-header fw-semibold bg-success text-white">
        <i class="fas fa-info-circle me-2"></i>Payroll will automatically calculate PAYE, NSSF (Tier I & II), NHIF, and liability deductions per Kenya law.
    </div>
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/payroll/create" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">
                <div class="col-12">
                    <label class="form-label fw-semibold">Period Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="periodName" required placeholder="e.g. March 2026 Payroll">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Start Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" name="startDate" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">End Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" name="endDate" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Pay Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" name="payDate" required>
                </div>
                <div class="col-12">
                    <div class="alert alert-info py-2 small mb-0">
                        <i class="fas fa-lightbulb me-2"></i>
                        After creating, click <strong>Process</strong> to auto-generate payslips for all active guards.
                        Then <strong>Approve</strong> to finalise.
                    </div>
                </div>
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/payroll" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-success px-4"><i class="fas fa-save me-2"></i>Create Period</button>
                </div>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
