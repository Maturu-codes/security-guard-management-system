<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Payroll Period" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/payroll" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-coins me-2 text-success"></i><c:out value="${period.periodName}"/></h1>
        <small class="text-muted">${period.startDate} to ${period.endDate} &bull; Pay date: ${period.payDate}</small>
    </div>
    <span class="badge fs-6 ${period.status == 'APPROVED' ? 'bg-success' : period.status == 'PROCESSING' ? 'bg-info text-dark' : 'bg-secondary'} me-3">
        <c:out value="${period.status}"/>
    </span>
    <c:if test="${period.status == 'DRAFT'}">
    <form action="${pageContext.request.contextPath}/payroll/process/${period.id}" method="post" class="d-inline me-2">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
        <button class="btn btn-info" onclick="return confirm('Generate payslips for all active guards?')">
            <i class="fas fa-play me-2"></i>Process Payroll
        </button>
    </form>
    </c:if>
    <c:if test="${period.status == 'PROCESSING'}">
    <form action="${pageContext.request.contextPath}/payroll/approve/${period.id}" method="post" class="d-inline">
        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
        <button class="btn btn-success" onclick="return confirm('Approve and finalise this payroll?')">
            <i class="fas fa-check me-2"></i>Approve & Finalise
        </button>
    </form>
    </c:if>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
        <span><i class="fas fa-file-invoice-dollar me-2"></i>Payslips (${payslips.size()})</span>
        <c:if test="${not empty payslips}">
            <span class="text-muted small">
                Total Net: KES
                <c:set var="totalNet" value="0"/>
                <c:forEach var="ps" items="${payslips}">
                    <c:set var="totalNet" value="${totalNet + ps.netPay}"/>
                </c:forEach>
                <fmt:formatNumber value="${totalNet}" pattern="#,##0.00"/>
            </span>
        </c:if>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty payslips}">
                <div class="text-center text-muted py-5">
                    <i class="fas fa-file-invoice fa-3x mb-3 d-block opacity-25"></i>
                    <p>No payslips generated yet.</p>
                    <c:if test="${period.status == 'DRAFT'}">
                        <form action="${pageContext.request.contextPath}/payroll/process/${period.id}" method="post">
                            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                            <button class="btn btn-info"><i class="fas fa-play me-2"></i>Process Now</button>
                        </form>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover mb-0 small">
                        <thead class="table-dark">
                            <tr>
                                <th>Employee #</th>
                                <th>Guard Name</th>
                                <th class="text-end">Basic</th>
                                <th class="text-end">Gross</th>
                                <th class="text-end">NSSF</th>
                                <th class="text-end">NHIF</th>
                                <th class="text-end">PAYE</th>
                                <th class="text-end">Liability</th>
                                <th class="text-end text-success fw-bold">Net Pay</th>
                                <th>Pay Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="ps" items="${payslips}">
                            <tr>
                                <td><span class="badge bg-secondary"><c:out value="${ps.employeeNumber}"/></span></td>
                                <td class="fw-semibold"><c:out value="${ps.guardName}"/></td>
                                <td class="text-end"><fmt:formatNumber value="${ps.basicSalary}" pattern="#,##0"/></td>
                                <td class="text-end"><fmt:formatNumber value="${ps.grossPay}" pattern="#,##0"/></td>
                                <td class="text-end text-danger">
                                    <fmt:formatNumber value="${ps.nssfTier1 + ps.nssfTier2}" pattern="#,##0"/>
                                </td>
                                <td class="text-end text-danger"><fmt:formatNumber value="${ps.nhifDeduction}" pattern="#,##0"/></td>
                                <td class="text-end text-danger"><fmt:formatNumber value="${ps.payeTax}" pattern="#,##0"/></td>
                                <td class="text-end text-danger">
                                    <c:if test="${ps.liabilityDeduction > 0}">
                                        <fmt:formatNumber value="${ps.liabilityDeduction}" pattern="#,##0"/>
                                    </c:if>
                                    <c:if test="${ps.liabilityDeduction == 0}">—</c:if>
                                </td>
                                <td class="text-end fw-bold text-success">
                                    <fmt:formatNumber value="${ps.netPay}" pattern="#,##0.00"/>
                                </td>
                                <td>
                                    <span class="badge ${ps.paymentStatus == 'PAID' ? 'bg-success' : 'bg-secondary'}">
                                        <c:out value="${ps.paymentStatus}"/>
                                    </span>
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
