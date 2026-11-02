<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Shift Details" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/shifts" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-calendar-days me-2 text-success"></i><c:out value="${shift.shiftName}"/></h1>
        <small class="text-muted"><c:out value="${shift.siteName}"/> &bull; ${shift.shiftDate} &bull; ${shift.startTime}–${shift.endTime}</small>
    </div>
    <span class="badge fs-6 ${shift.status == 'ACTIVE' ? 'bg-success' : shift.status == 'CANCELLED' ? 'bg-danger' : 'bg-secondary'} me-2">
        <c:out value="${shift.status}"/>
    </span>
    <a href="${pageContext.request.contextPath}/shifts/edit/${shift.id}" class="btn btn-outline-secondary btn-sm me-2"><i class="fas fa-edit me-1"></i>Edit</a>
    <a href="${pageContext.request.contextPath}/attendance/shift/${shift.id}" class="btn btn-success btn-sm"><i class="fas fa-clipboard-check me-1"></i>Attendance</a>
</div>

<div class="row g-4">
    <div class="col-lg-5">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold"><i class="fas fa-info-circle me-2"></i>Shift Info</div>
            <div class="card-body">
                <dl class="row small mb-0">
                    <dt class="col-5 text-muted">Site</dt><dd class="col-7"><c:out value="${shift.siteName}"/></dd>
                    <dt class="col-5 text-muted">Client</dt><dd class="col-7"><c:out value="${shift.clientName}"/></dd>
                    <dt class="col-5 text-muted">Date</dt><dd class="col-7">${shift.shiftDate}</dd>
                    <dt class="col-5 text-muted">Start Time</dt><dd class="col-7">${shift.startTime}</dd>
                    <dt class="col-5 text-muted">End Time</dt><dd class="col-7">${shift.endTime}</dd>
                    <dt class="col-5 text-muted">Required Guards</dt><dd class="col-7">${shift.requiredGuards}</dd>
                    <dt class="col-5 text-muted">Assigned</dt>
                    <dd class="col-7">
                        <span class="badge ${shift.assignedGuards >= shift.requiredGuards ? 'bg-success' : 'bg-warning text-dark'}">
                            ${shift.assignedGuards}/${shift.requiredGuards}
                        </span>
                    </dd>
                </dl>
            </div>
        </div>

        <!-- Assign Guard -->
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-user-plus me-2"></i>Assign Guard</div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/shifts/assign/${shift.id}" method="post">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                    <div class="mb-3">
                        <select class="form-select" name="guardId" required>
                            <option value="">Select guard...</option>
                            <c:forEach var="g" items="${availableGuards}">
                                <option value="${g.id}"><c:out value="${g.fullName}"/> (<c:out value="${g.employeeNumber}"/>)</option>
                            </c:forEach>
                        </select>
                    </div>
                    <button class="btn btn-success w-100"><i class="fas fa-user-plus me-2"></i>Assign</button>
                </form>
            </div>
        </div>
    </div>

    <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-users me-2"></i>Assigned Guards (${shift.assignedGuards})</div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty assignedGuards}">
                        <div class="text-center text-muted py-4"><i class="fas fa-user-slash fa-2x mb-2 d-block opacity-25"></i>No guards assigned yet.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="table-light"><tr><th>Employee #</th><th>Name</th><th>Phone</th><th>Status</th></tr></thead>
                                <tbody>
                                <c:forEach var="g" items="${assignedGuards}">
                                    <tr>
                                        <td><span class="badge bg-secondary"><c:out value="${g.employeeNumber}"/></span></td>
                                        <td><a href="${pageContext.request.contextPath}/guards/view/${g.id}"><c:out value="${g.fullName}"/></a></td>
                                        <td><c:out value="${g.phone}"/></td>
                                        <td><span class="badge bg-info text-dark"><c:out value="${g.status}"/></span></td>
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

<!-- Delete -->
<div class="mt-4">
    <form action="${pageContext.request.contextPath}/shifts/delete/${shift.id}" method="post" onsubmit="return confirm('Delete this shift?')">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
        <button class="btn btn-outline-danger btn-sm"><i class="fas fa-trash me-2"></i>Delete Shift</button>
    </form>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
