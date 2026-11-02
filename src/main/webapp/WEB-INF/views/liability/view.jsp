<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Liability Report" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/liability" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-gavel me-2 text-danger"></i>Liability Report #${report.id}</h1>
        <small class="text-muted"><c:out value="${report.liabilityType}"/> &bull; Guard: <c:out value="${report.guardName}"/></small>
    </div>
    <span class="badge fs-6 ${report.status == 'HR_APPROVED' ? 'bg-success' : report.status == 'REJECTED' ? 'bg-danger' : report.status == 'PENDING' ? 'bg-warning text-dark' : 'bg-info text-dark'}">
        <c:out value="${report.status}"/>
    </span>
</div>

<div class="row g-4">
    <div class="col-lg-5">
        <!-- Report Details -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold"><i class="fas fa-info-circle me-2"></i>Report Details</div>
            <div class="card-body">
                <dl class="row small mb-0">
                    <dt class="col-5 text-muted">Guard</dt>
                    <dd class="col-7 fw-bold"><c:out value="${report.guardName}"/> (<c:out value="${report.employeeNumber}"/>)</dd>
                    <dt class="col-5 text-muted">Type</dt><dd class="col-7"><span class="badge bg-dark"><c:out value="${report.liabilityType}"/></span></dd>
                    <dt class="col-5 text-muted">Severity</dt>
                    <dd class="col-7">
                        <span class="badge ${report.severity == 'MAJOR' ? 'bg-danger' : report.severity == 'MODERATE' ? 'bg-warning text-dark' : 'bg-info text-dark'}">
                            <c:out value="${report.severity}"/>
                        </span>
                    </dd>
                    <dt class="col-5 text-muted">Estimated Cost</dt>
                    <dd class="col-7">KES <fmt:formatNumber value="${report.estimatedCost}" pattern="#,##0.00"/></dd>
                    <dt class="col-5 text-muted">Approved Deduction</dt>
                    <dd class="col-7">
                        <c:choose>
                            <c:when test="${not empty report.approvedDeduction and report.approvedDeduction > 0}">
                                <span class="text-danger fw-bold">KES <fmt:formatNumber value="${report.approvedDeduction}" pattern="#,##0.00"/></span>
                            </c:when>
                            <c:otherwise><span class="text-muted">Not yet approved</span></c:otherwise>
                        </c:choose>
                    </dd>
                    <dt class="col-5 text-muted">Status</dt>
                    <dd class="col-7"><span class="badge ${report.status == 'HR_APPROVED' ? 'bg-success' : report.status == 'REJECTED' ? 'bg-danger' : 'bg-warning text-dark'}"><c:out value="${report.status}"/></span></dd>
                    <dt class="col-5 text-muted">Date</dt><dd class="col-7"><c:out value="${report.createdAt}"/></dd>
                </dl>
                <hr>
                <div class="small">
                    <div class="fw-semibold mb-1">Description:</div>
                    <p class="text-muted"><c:out value="${report.description}"/></p>
                    <c:if test="${not empty report.evidenceNotes}">
                        <div class="fw-semibold mb-1">Evidence / Notes:</div>
                        <p class="text-muted"><c:out value="${report.evidenceNotes}"/></p>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Review Panel -->
        <c:if test="${report.status == 'PENDING' or report.status == 'SUPERVISOR_APPROVED' or report.status == 'MANAGER_APPROVED'}">
        <div class="card border-0 shadow-sm border-top border-success border-3">
            <div class="card-header fw-semibold text-success"><i class="fas fa-check-circle me-2"></i>Review This Report</div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/liability/approve/${report.id}" method="post" class="mb-3">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Approved Deduction (KES)</label>
                        <input type="number" class="form-control form-control-sm" name="approvedDeduction"
                               value="${report.estimatedCost}" min="0" step="0.01" required>
                        <div class="form-text">Leave at estimated cost or adjust. Capped at 30% of net salary by law.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Notes</label>
                        <textarea class="form-control form-control-sm" name="notes" rows="2"></textarea>
                    </div>
                    <button class="btn btn-success btn-sm w-100 mb-2" onclick="return confirm('Approve this liability report?')">
                        <i class="fas fa-check me-2"></i>Approve
                    </button>
                </form>
                <form action="${pageContext.request.contextPath}/liability/reject/${report.id}" method="post">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Rejection Reason</label>
                        <textarea class="form-control form-control-sm" name="notes" rows="2"></textarea>
                    </div>
                    <button class="btn btn-outline-danger btn-sm w-100" onclick="return confirm('Reject this report?')">
                        <i class="fas fa-times me-2"></i>Reject
                    </button>
                </form>
            </div>
        </div>
        </c:if>
    </div>

    <!-- Approval Trail -->
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-stream me-2"></i>Approval Trail</div>
            <div class="card-body">
                <div class="timeline-steps">
                    <!-- Step 1: Submitted -->
                    <div class="d-flex mb-3">
                        <div class="me-3 text-center" style="min-width:36px;">
                            <div class="rounded-circle bg-success d-flex align-items-center justify-content-center text-white" style="width:36px;height:36px;">
                                <i class="fas fa-check fa-sm"></i>
                            </div>
                        </div>
                        <div>
                            <div class="fw-semibold">Submitted</div>
                            <small class="text-muted"><c:out value="${report.createdAt}"/></small>
                        </div>
                    </div>
                    <!-- Step 2: Supervisor -->
                    <div class="d-flex mb-3">
                        <div class="me-3 text-center" style="min-width:36px;">
                            <div class="rounded-circle ${report.status == 'SUPERVISOR_APPROVED' or report.status == 'MANAGER_APPROVED' or report.status == 'HR_APPROVED' ? 'bg-success' : report.status == 'REJECTED' ? 'bg-danger' : 'bg-secondary'} d-flex align-items-center justify-content-center text-white" style="width:36px;height:36px;">
                                <i class="fas fa-user fa-sm"></i>
                            </div>
                        </div>
                        <div>
                            <div class="fw-semibold">Supervisor Review</div>
                            <c:if test="${not empty report.supervisorNotes}">
                                <small class="text-muted"><c:out value="${report.supervisorNotes}"/></small>
                            </c:if>
                            <c:if test="${empty report.supervisorNotes}">
                                <small class="text-muted">Pending</small>
                            </c:if>
                        </div>
                    </div>
                    <!-- Step 3: Manager -->
                    <div class="d-flex mb-3">
                        <div class="me-3 text-center" style="min-width:36px;">
                            <div class="rounded-circle ${report.status == 'MANAGER_APPROVED' or report.status == 'HR_APPROVED' ? 'bg-success' : 'bg-secondary'} d-flex align-items-center justify-content-center text-white" style="width:36px;height:36px;">
                                <i class="fas fa-user-tie fa-sm"></i>
                            </div>
                        </div>
                        <div>
                            <div class="fw-semibold">Operations Manager</div>
                            <c:if test="${not empty report.managerNotes}">
                                <small class="text-muted"><c:out value="${report.managerNotes}"/></small>
                            </c:if>
                            <c:if test="${empty report.managerNotes}">
                                <small class="text-muted">Pending</small>
                            </c:if>
                        </div>
                    </div>
                    <!-- Step 4: HR Final -->
                    <div class="d-flex">
                        <div class="me-3 text-center" style="min-width:36px;">
                            <div class="rounded-circle ${report.status == 'HR_APPROVED' ? 'bg-success' : 'bg-secondary'} d-flex align-items-center justify-content-center text-white" style="width:36px;height:36px;">
                                <i class="fas fa-building fa-sm"></i>
                            </div>
                        </div>
                        <div>
                            <div class="fw-semibold">HR / Admin Final Approval</div>
                            <c:if test="${not empty report.hrNotes}">
                                <small class="text-muted"><c:out value="${report.hrNotes}"/></small>
                            </c:if>
                            <c:if test="${empty report.hrNotes}">
                                <small class="text-muted">Pending</small>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
