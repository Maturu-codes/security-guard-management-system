<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Equipment Details" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-gun me-2 text-dark"></i><c:out value="${equipment.makeModel}"/></h1>
        <small class="text-muted"><c:out value="${equipment.equipmentType}"/> &bull; S/N: <code><c:out value="${equipment.serialNumber}"/></code></small>
    </div>
    <span class="badge fs-6 ${equipment.status == 'AVAILABLE' ? 'bg-success' : equipment.status == 'ASSIGNED' ? 'bg-warning text-dark' : 'bg-secondary'} me-2">
        <c:out value="${equipment.status}"/>
    </span>
    <a href="${pageContext.request.contextPath}/equipment/edit/${equipment.id}" class="btn btn-outline-secondary btn-sm">
        <i class="fas fa-edit me-1"></i>Edit
    </a>
</div>

<div class="row g-4">
    <!-- Details -->
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold"><i class="fas fa-info-circle me-2"></i>Details</div>
            <div class="card-body">
                <dl class="row small mb-0">
                    <dt class="col-5 text-muted">Type</dt><dd class="col-7"><c:out value="${equipment.equipmentType}"/></dd>
                    <dt class="col-5 text-muted">Serial #</dt><dd class="col-7"><code><c:out value="${equipment.serialNumber}"/></code></dd>
                    <dt class="col-5 text-muted">Make/Model</dt><dd class="col-7"><c:out value="${equipment.makeModel}"/></dd>
                    <dt class="col-5 text-muted">Condition</dt>
                    <dd class="col-7">
                        <span class="badge ${equipment.conditionState == 'EXCELLENT' ? 'bg-success' : equipment.conditionState == 'GOOD' ? 'bg-info text-dark' : equipment.conditionState == 'FAIR' ? 'bg-warning text-dark' : 'bg-danger'}">
                            <c:out value="${equipment.conditionState}"/>
                        </span>
                    </dd>
                    <dt class="col-5 text-muted">Acquired</dt><dd class="col-7">${equipment.acquisitionDate}</dd>
                    <dt class="col-5 text-muted">Cost</dt><dd class="col-7">KES <c:out value="${equipment.acquisitionCost}"/></dd>
                    <c:if test="${equipment.requiresLicense}">
                    <dt class="col-5 text-muted">License #</dt><dd class="col-7"><c:out value="${equipment.licenseNumber}"/></dd>
                    <dt class="col-5 text-muted">Lic. Expiry</dt><dd class="col-7">${equipment.licenseExpiry}</dd>
                    </c:if>
                    <dt class="col-5 text-muted">Assigned To</dt>
                    <dd class="col-7"><c:out value="${not empty equipment.currentAssigneeName ? equipment.currentAssigneeName : '—'}"/></dd>
                    <c:if test="${not empty equipment.description}">
                    <dt class="col-5 text-muted">Description</dt><dd class="col-7"><c:out value="${equipment.description}"/></dd>
                    </c:if>
                    <c:if test="${not empty equipment.notes}">
                    <dt class="col-5 text-muted">Notes</dt><dd class="col-7"><c:out value="${equipment.notes}"/></dd>
                    </c:if>
                </dl>
            </div>
        </div>

        <!-- Issue / Return -->
        <c:choose>
            <c:when test="${equipment.status == 'AVAILABLE'}">
                <div class="card border-0 shadow-sm border-top border-success border-3">
                    <div class="card-header fw-semibold text-success"><i class="fas fa-share me-2"></i>Issue to Guard</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/equipment/issue/${equipment.id}" method="post">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                            <div class="mb-2">
                                <label class="form-label small fw-semibold">Guard</label>
                                <select class="form-select form-select-sm" name="guardId" required>
                                    <option value="">Select guard...</option>
                                    <c:forEach var="g" items="${guards}">
                                        <option value="${g.id}"><c:out value="${g.fullName}"/> (<c:out value="${g.employeeNumber}"/>)</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-semibold">Condition on Issue</label>
                                <select class="form-select form-select-sm" name="conditionOnIssue">
                                    <option value="EXCELLENT">Excellent</option>
                                    <option value="GOOD" selected>Good</option>
                                    <option value="FAIR">Fair</option>
                                </select>
                            </div>
                            <button class="btn btn-success btn-sm w-100"><i class="fas fa-share me-2"></i>Issue Equipment</button>
                        </form>
                    </div>
                </div>
            </c:when>
            <c:when test="${equipment.status == 'ASSIGNED'}">
                <div class="card border-0 shadow-sm border-top border-warning border-3">
                    <div class="card-header fw-semibold text-warning"><i class="fas fa-reply me-2"></i>Return Equipment</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/equipment/return/${equipment.id}" method="post">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                            <div class="mb-3">
                                <label class="form-label small fw-semibold">Condition on Return</label>
                                <select class="form-select form-select-sm" name="conditionOnReturn">
                                    <option value="EXCELLENT">Excellent</option>
                                    <option value="GOOD" selected>Good</option>
                                    <option value="FAIR">Fair</option>
                                    <option value="POOR">Poor — Damaged</option>
                                </select>
                            </div>
                            <button class="btn btn-warning btn-sm w-100"><i class="fas fa-reply me-2"></i>Process Return</button>
                        </form>
                    </div>
                </div>
            </c:when>
        </c:choose>
    </div>

    <!-- Assignment History -->
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-history me-2"></i>Assignment History</div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty assignmentHistory}">
                        <div class="text-center text-muted py-4">No assignment history yet.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0 small">
                                <thead class="table-light"><tr><th>Guard</th><th>Issued</th><th>Returned</th><th>Condition Out</th><th>Condition In</th><th>Status</th></tr></thead>
                                <tbody>
                                <c:forEach var="h" items="${assignmentHistory}">
                                    <tr>
                                        <td><c:out value="${h.guardName}"/></td>
                                        <td><c:out value="${h.issuedAt}"/></td>
                                        <td><c:out value="${not empty h.returnedAt ? h.returnedAt : '—'}"/></td>
                                        <td><span class="badge bg-secondary"><c:out value="${h.conditionOnIssue}"/></span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty h.conditionOnReturn}">
                                                    <span class="badge ${h.conditionOnReturn == 'POOR' ? 'bg-danger' : 'bg-success'}">
                                                        <c:out value="${h.conditionOnReturn}"/>
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="badge ${h.status == 'ISSUED' ? 'bg-warning text-dark' : 'bg-success'}"><c:out value="${h.status}"/></span></td>
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
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
