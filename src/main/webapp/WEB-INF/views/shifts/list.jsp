<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Shifts" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-calendar-days me-2 text-success"></i>Shift Management</h1>
        <p class="text-muted mb-0">Schedule and manage guard deployments</p>
    </div>
    <a href="${pageContext.request.contextPath}/shifts/new" class="btn btn-success">
        <i class="fas fa-calendar-plus me-2"></i>New Shift
    </a>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Shift Name</th><th>Site / Client</th><th>Date</th>
                        <th>Time</th><th>Guards</th><th>Status</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty shifts}">
                        <tr><td colspan="7" class="text-center text-muted py-5">
                            <i class="fas fa-calendar fa-3x mb-3 d-block opacity-25"></i>
                            No shifts scheduled. <a href="${pageContext.request.contextPath}/shifts/new">Create the first shift</a>.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="s" items="${shifts}">
                        <tr>
                            <td class="fw-semibold"><c:out value="${s.shiftName}"/></td>
                            <td>
                                <div><c:out value="${s.siteName}"/></div>
                                <small class="text-muted"><c:out value="${s.clientName}"/></small>
                            </td>
                            <td>${s.shiftDate}</td>
                            <td><small>${s.startTime} – ${s.endTime}</small></td>
                            <td>
                                <span class="badge ${s.assignedGuards >= s.requiredGuards ? 'bg-success' : 'bg-warning text-dark'}">
                                    ${s.assignedGuards}/${s.requiredGuards}
                                </span>
                            </td>
                            <td>
                                <span class="badge ${s.status == 'ACTIVE' ? 'bg-success' : s.status == 'COMPLETED' ? 'bg-secondary' : s.status == 'CANCELLED' ? 'bg-danger' : 'bg-info text-dark'}">
                                    <c:out value="${s.status}"/>
                                </span>
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm">
                                    <a href="${pageContext.request.contextPath}/shifts/view/${s.id}" class="btn btn-outline-primary"><i class="fas fa-eye"></i></a>
                                    <a href="${pageContext.request.contextPath}/attendance/shift/${s.id}" class="btn btn-outline-success" title="Attendance"><i class="fas fa-clipboard-check"></i></a>
                                    <a href="${pageContext.request.contextPath}/shifts/edit/${s.id}" class="btn btn-outline-secondary"><i class="fas fa-edit"></i></a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
