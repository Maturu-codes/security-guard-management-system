<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Liability Reports" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-gavel me-2 text-danger"></i>Liability Management</h1>
        <p class="text-muted mb-0">
            Track guard liability deductions — equipment damage, loss, K9 negligence
            <c:if test="${pendingCount > 0}">
                &bull; <span class="badge bg-warning text-dark">${pendingCount} pending review</span>
            </c:if>
        </p>
    </div>
    <a href="${pageContext.request.contextPath}/liability/new" class="btn btn-danger">
        <i class="fas fa-plus me-2"></i>New Liability Report
    </a>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                    <tr><th>Guard</th><th>Type</th><th>Description</th><th>Severity</th><th>Est. Cost</th><th>Approved Ded.</th><th>Status</th><th>Date</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty reports}">
                        <tr><td colspan="9" class="text-center text-muted py-5">
                            <i class="fas fa-gavel fa-3x mb-3 d-block opacity-25"></i>
                            No liability reports. <a href="${pageContext.request.contextPath}/liability/new">Create the first report</a>.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="r" items="${reports}">
                        <tr>
                            <td>
                                <div class="fw-semibold"><c:out value="${r.guardName}"/></div>
                                <small class="text-muted"><c:out value="${r.employeeNumber}"/></small>
                            </td>
                            <td><span class="badge bg-dark"><c:out value="${r.liabilityType}"/></span></td>
                            <td><small><c:out value="${r.description}" escapeXml="true"/></small></td>
                            <td>
                                <span class="badge ${r.severity == 'MAJOR' ? 'bg-danger' : r.severity == 'MODERATE' ? 'bg-warning text-dark' : 'bg-info text-dark'}">
                                    <c:out value="${r.severity}"/>
                                </span>
                            </td>
                            <td>KES <fmt:formatNumber value="${r.estimatedCost}" pattern="#,##0"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty r.approvedDeduction and r.approvedDeduction > 0}">
                                        <span class="text-danger fw-semibold">KES <fmt:formatNumber value="${r.approvedDeduction}" pattern="#,##0"/></span>
                                    </c:when>
                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge ${r.status == 'HR_APPROVED' ? 'bg-success' : r.status == 'REJECTED' ? 'bg-danger' : r.status == 'PENDING' ? 'bg-warning text-dark' : 'bg-info text-dark'}">
                                    <c:out value="${r.status}"/>
                                </span>
                            </td>
                            <td><small><c:out value="${r.createdAt}"/></small></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/liability/view/${r.id}" class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-eye"></i>
                                </a>
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
