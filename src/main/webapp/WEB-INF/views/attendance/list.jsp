<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Attendance" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-clipboard-check me-2 text-success"></i>Attendance</h1>
        <p class="text-muted mb-0">Track guard check-ins and check-outs</p>
    </div>
</div>

<!-- Today's Shifts -->
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header fw-semibold bg-success text-white">
        <i class="fas fa-calendar-day me-2"></i>Today's Shifts — Click to Record Attendance
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty todayShifts}">
                <div class="text-center text-muted py-4">No shifts scheduled for today.</div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light"><tr><th>Shift</th><th>Site</th><th>Time</th><th>Guards</th><th>Action</th></tr></thead>
                        <tbody>
                        <c:forEach var="s" items="${todayShifts}">
                            <tr>
                                <td class="fw-semibold"><c:out value="${s.shiftName}"/></td>
                                <td><c:out value="${s.siteName}"/></td>
                                <td>${s.startTime}–${s.endTime}</td>
                                <td><span class="badge ${s.assignedGuards >= s.requiredGuards ? 'bg-success' : 'bg-warning text-dark'}">${s.assignedGuards}/${s.requiredGuards}</span></td>
                                <td><a href="${pageContext.request.contextPath}/attendance/shift/${s.id}" class="btn btn-sm btn-success"><i class="fas fa-clipboard-check me-1"></i>Record</a></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Recent Records -->
<div class="card border-0 shadow-sm">
    <div class="card-header fw-semibold"><i class="fas fa-history me-2"></i>Recent Attendance Records</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark"><tr><th>Guard</th><th>Shift</th><th>Site</th><th>Check In</th><th>Check Out</th><th>Method</th><th>Status</th></tr></thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty records}">
                        <tr><td colspan="7" class="text-center text-muted py-4">No attendance records found.</td></tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="r" items="${records}">
                        <tr>
                            <td><c:out value="${r.guardName}"/><br><small class="text-muted"><c:out value="${r.employeeNumber}"/></small></td>
                            <td><c:out value="${r.shiftName}"/></td>
                            <td><c:out value="${r.siteName}"/></td>
                            <td><small><c:out value="${r.checkInTime}"/></small></td>
                            <td><small><c:out value="${r.checkOutTime}"/></small></td>
                            <td><span class="badge bg-secondary"><c:out value="${r.checkInMethod}"/></span></td>
                            <td>
                                <span class="badge ${r.status == 'PRESENT' ? 'bg-success' : r.status == 'ABSENT' ? 'bg-danger' : r.status == 'LATE' ? 'bg-warning text-dark' : 'bg-secondary'}">
                                    <c:out value="${r.status}"/>
                                </span>
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
