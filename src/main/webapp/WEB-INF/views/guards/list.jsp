<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Guards" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-user-shield me-2 text-primary"></i>Guards</h1>
        <p class="text-muted mb-0">Manage all security personnel</p>
    </div>
    <c:if test="${sessionScope.userRole != 'CLIENT' && sessionScope.userRole != 'GUARD'}">
    <a href="${pageContext.request.contextPath}/guards/new" class="btn btn-primary">
        <i class="fas fa-user-plus me-2"></i>Add Guard
    </a>
    </c:if>
</div>

<!-- Search/Filter Bar -->
<div class="card border-0 shadow-sm mb-4">
    <div class="card-body py-2">
        <div class="row g-2 align-items-center">
            <div class="col-md-4">
                <input type="text" class="form-control" id="guardSearch" placeholder="Search by name, ID...">
            </div>
            <div class="col-md-2">
                <select class="form-select" id="statusFilter">
                    <option value="">All Statuses</option>
                    <option>ACTIVE</option>
                    <option>SUSPENDED</option>
                    <option>ON_LEAVE</option>
                    <option>TERMINATED</option>
                </select>
            </div>
            <div class="col-md-2">
                <select class="form-select" id="typeFilter">
                    <option value="">All Types</option>
                    <option>PERMANENT</option>
                    <option>CONTRACT</option>
                    <option>CASUAL</option>
                </select>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0" id="guardsTable">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Employee No.</th>
                        <th>Full Name</th>
                        <th>National ID</th>
                        <th>Phone</th>
                        <th>Employment</th>
                        <th>Salary (KES)</th>
                        <th>PSV Expiry</th>
                        <th>K9</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty guards}">
                        <tr>
                            <td colspan="11" class="text-center text-muted py-5">
                                <i class="fas fa-users fa-3x mb-3 d-block opacity-25"></i>
                                No guards found. <a href="${pageContext.request.contextPath}/guards/new">Add the first guard</a>.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="g" items="${guards}" varStatus="vs">
                        <tr>
                            <td class="text-muted small">${vs.count}</td>
                            <td><span class="badge bg-secondary"><c:out value="${g.employeeNumber}"/></span></td>
                            <td class="fw-semibold">
                                <a href="${pageContext.request.contextPath}/guards/view/${g.id}" class="text-decoration-none">
                                    <c:out value="${g.fullName}"/>
                                </a>
                            </td>
                            <td><c:out value="${g.nationalId}"/></td>
                            <td><c:out value="${g.phone}"/></td>
                            <td>
                                <span class="badge ${g.employmentType == 'PERMANENT' ? 'bg-success' :
                                    g.employmentType == 'CONTRACT' ? 'bg-info text-dark' : 'bg-warning text-dark'}">
                                    <c:out value="${g.employmentType}"/>
                                </span>
                            </td>
                            <td><fmt:formatNumber value="${g.basicSalary}" type="number" minFractionDigits="0" maxFractionDigits="0"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty g.psvExpiry}">—</c:when>
                                    <c:otherwise><fmt:formatDate value="${g.psvExpiry}" pattern="dd/MM/yyyy"/></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${g.k9Handler}">
                                    <i class="fas fa-dog text-warning" title="K9 Handler"></i>
                                </c:if>
                            </td>
                            <td>
                                <span class="badge ${g.status == 'ACTIVE' ? 'bg-success' :
                                    g.status == 'SUSPENDED' ? 'bg-warning text-dark' :
                                    g.status == 'TERMINATED' ? 'bg-danger' : 'bg-secondary'}">
                                    <c:out value="${g.status}"/>
                                </span>
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm">
                                    <a href="${pageContext.request.contextPath}/guards/view/${g.id}"
                                       class="btn btn-outline-primary" title="View">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <c:if test="${sessionScope.userRole != 'CLIENT' && sessionScope.userRole != 'GUARD'}">
                                    <a href="${pageContext.request.contextPath}/guards/edit/${g.id}"
                                       class="btn btn-outline-secondary" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
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

<script>
document.getElementById('guardSearch').addEventListener('input', filterTable);
document.getElementById('statusFilter').addEventListener('change', filterTable);
document.getElementById('typeFilter').addEventListener('change', filterTable);

function filterTable() {
    const search = document.getElementById('guardSearch').value.toLowerCase();
    const status = document.getElementById('statusFilter').value.toLowerCase();
    const type = document.getElementById('typeFilter').value.toLowerCase();
    const rows = document.querySelectorAll('#guardsTable tbody tr');
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        const match = text.includes(search) &&
            (status === '' || text.includes(status)) &&
            (type === '' || text.includes(type));
        row.style.display = match ? '' : 'none';
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
