<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Record Attendance" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/attendance" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-clipboard-check me-2 text-success"></i>Record Attendance</h1>
        <small class="text-muted"><c:out value="${shift.shiftName}"/> &bull; <c:out value="${shift.siteName}"/> &bull; ${shift.shiftDate}</small>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header fw-semibold">
        <i class="fas fa-users me-2"></i>Guards — ${shift.startTime} to ${shift.endTime}
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty assignedGuards}">
                <div class="text-center text-muted py-5">
                    <i class="fas fa-user-slash fa-3x mb-3 d-block opacity-25"></i>
                    No guards assigned to this shift. <a href="${pageContext.request.contextPath}/shifts/view/${shift.id}">Assign guards first</a>.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table mb-0">
                        <thead class="table-dark"><tr><th>Guard</th><th>Check In</th><th>Check Out</th><th>Status</th><th>Actions</th></tr></thead>
                        <tbody>
                        <c:forEach var="g" items="${assignedGuards}">
                            <%-- Find matching attendance record --%>
                            <c:set var="attRec" value="${null}"/>
                            <c:forEach var="ar" items="${attendanceRecords}">
                                <c:if test="${ar.guardId == g.id}"><c:set var="attRec" value="${ar}"/></c:if>
                            </c:forEach>
                            <tr>
                                <td>
                                    <div class="fw-semibold"><c:out value="${g.fullName}"/></div>
                                    <small class="text-muted"><c:out value="${g.employeeNumber}"/></small>
                                </td>
                                <td><small><c:out value="${attRec.checkInTime}"/></small></td>
                                <td><small><c:out value="${attRec.checkOutTime}"/></small></td>
                                <td>
                                    <span class="badge ${attRec.status == 'PRESENT' ? 'bg-success' : attRec.status == 'ABSENT' ? 'bg-danger' : 'bg-secondary'}">
                                        <c:out value="${not empty attRec.status ? attRec.status : 'NOT_RECORDED'}"/>
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex gap-1 flex-wrap">
                                        <form action="${pageContext.request.contextPath}/attendance/checkin" method="post" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                            <input type="hidden" name="guardId" value="${g.id}">
                                            <input type="hidden" name="shiftId" value="${shift.id}">
                                            <button class="btn btn-sm btn-success" title="Check In"><i class="fas fa-sign-in-alt me-1"></i>In</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/attendance/checkout" method="post" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                            <input type="hidden" name="guardId" value="${g.id}">
                                            <input type="hidden" name="shiftId" value="${shift.id}">
                                            <button class="btn btn-sm btn-warning" title="Check Out"><i class="fas fa-sign-out-alt me-1"></i>Out</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/attendance/absent" method="post" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                            <input type="hidden" name="guardId" value="${g.id}">
                                            <input type="hidden" name="shiftId" value="${shift.id}">
                                            <input type="hidden" name="notes" value="Marked absent by supervisor">
                                            <button class="btn btn-sm btn-danger" title="Mark Absent"><i class="fas fa-times me-1"></i>Absent</button>
                                        </form>
                                    </div>
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
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
