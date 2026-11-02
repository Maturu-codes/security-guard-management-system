<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Payroll" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-coins me-2 text-success"></i>Payroll Management</h1>
        <p class="text-muted mb-0">Kenya-compliant payroll — PAYE, NSSF (Tier I & II), NHIF</p>
    </div>
    <a href="${pageContext.request.contextPath}/payroll/new" class="btn btn-success">
        <i class="fas fa-plus me-2"></i>New Payroll Period
    </a>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                    <tr><th>Period Name</th><th>Start Date</th><th>End Date</th><th>Pay Date</th><th>Payslips</th><th>Created By</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty periods}">
                        <tr><td colspan="8" class="text-center text-muted py-5">
                            <i class="fas fa-coins fa-3x mb-3 d-block opacity-25"></i>
                            No payroll periods yet. <a href="${pageContext.request.contextPath}/payroll/new">Create the first period</a>.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="p" items="${periods}">
                        <tr>
                            <td class="fw-semibold"><c:out value="${p.periodName}"/></td>
                            <td>${p.startDate}</td>
                            <td>${p.endDate}</td>
                            <td>${p.payDate}</td>
                            <td><span class="badge bg-primary">${p.payslipCount}</span></td>
                            <td><c:out value="${p.createdByName}"/></td>
                            <td>
                                <span class="badge ${p.status == 'APPROVED' ? 'bg-success' : p.status == 'PROCESSING' ? 'bg-info text-dark' : p.status == 'DRAFT' ? 'bg-secondary' : 'bg-warning text-dark'}">
                                    <c:out value="${p.status}"/>
                                </span>
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm">
                                    <a href="${pageContext.request.contextPath}/payroll/view/${p.id}" class="btn btn-outline-primary"><i class="fas fa-eye"></i></a>
                                    <c:if test="${p.status == 'DRAFT'}">
                                    <form action="${pageContext.request.contextPath}/payroll/process/${p.id}" method="post" class="d-inline">
                                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                        <button class="btn btn-outline-info" title="Process payroll" onclick="return confirm('Process payroll for this period?')">
                                            <i class="fas fa-play"></i>
                                        </button>
                                    </form>
                                    </c:if>
                                    <c:if test="${p.status == 'PROCESSING'}">
                                    <form action="${pageContext.request.contextPath}/payroll/approve/${p.id}" method="post" class="d-inline">
                                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                                        <button class="btn btn-outline-success" title="Approve payroll" onclick="return confirm('Approve and finalise this payroll?')">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>
                                    </c:if>
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
