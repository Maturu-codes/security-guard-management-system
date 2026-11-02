<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Clients" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-building me-2 text-primary"></i>Clients & Sites</h1>
        <p class="text-muted mb-0">Manage client accounts and deployment sites</p>
    </div>
    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/clients/site/new" class="btn btn-outline-primary">
            <i class="fas fa-map-marker-alt me-2"></i>Add Site
        </a>
        <a href="${pageContext.request.contextPath}/clients/new" class="btn btn-primary">
            <i class="fas fa-plus me-2"></i>New Client
        </a>
    </div>
</div>

<!-- Clients Table -->
<div class="card border-0 shadow-sm mb-4">
    <div class="card-header fw-semibold"><i class="fas fa-building me-2"></i>All Clients</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                    <tr><th>Company</th><th>Contact Person</th><th>Phone</th><th>Contract</th><th>Sites</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty clients}">
                        <tr><td colspan="7" class="text-center text-muted py-5">
                            <i class="fas fa-building fa-3x mb-3 d-block opacity-25"></i>
                            No clients yet. <a href="${pageContext.request.contextPath}/clients/new">Add the first client</a>.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="c" items="${clients}">
                        <tr>
                            <td class="fw-semibold"><c:out value="${c.companyName}"/></td>
                            <td><c:out value="${c.contactPerson}"/></td>
                            <td><c:out value="${c.phone}"/></td>
                            <td>
                                <small>
                                    <c:out value="${c.contractStart}"/> –
                                    <c:out value="${not empty c.contractEnd ? c.contractEnd : 'Ongoing'}"/>
                                </small>
                            </td>
                            <td><span class="badge bg-primary">${c.siteCount} site(s)</span></td>
                            <td>
                                <span class="badge ${c.isActive ? 'bg-success' : 'bg-danger'}">
                                    ${c.isActive ? 'Active' : 'Inactive'}
                                </span>
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm">
                                    <a href="${pageContext.request.contextPath}/clients/view/${c.id}" class="btn btn-outline-primary"><i class="fas fa-eye"></i></a>
                                    <a href="${pageContext.request.contextPath}/clients/edit/${c.id}" class="btn btn-outline-secondary"><i class="fas fa-edit"></i></a>
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

<!-- All Sites -->
<div class="card border-0 shadow-sm">
    <div class="card-header fw-semibold"><i class="fas fa-map-marker-alt me-2"></i>All Sites</div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light"><tr><th>Site Name</th><th>Client</th><th>Type</th><th>Risk Level</th><th>Required Guards</th><th>Status</th></tr></thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty sites}">
                        <tr><td colspan="6" class="text-center text-muted py-4">No sites registered yet.</td></tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="s" items="${sites}">
                        <tr>
                            <td class="fw-semibold"><c:out value="${s.siteName}"/></td>
                            <td><c:out value="${s.companyName}"/></td>
                            <td><span class="badge bg-secondary"><c:out value="${s.siteType}"/></span></td>
                            <td>
                                <span class="badge ${s.riskLevel == 'HIGH' ? 'bg-danger' : s.riskLevel == 'MEDIUM' ? 'bg-warning text-dark' : 'bg-success'}">
                                    <c:out value="${s.riskLevel}"/>
                                </span>
                            </td>
                            <td>${s.requiredGuards}</td>
                            <td><span class="badge ${s.isActive ? 'bg-success' : 'bg-danger'}">${s.isActive ? 'Active' : 'Inactive'}</span></td>
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
