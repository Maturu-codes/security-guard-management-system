<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Client Details" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/clients" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-building me-2 text-primary"></i><c:out value="${client.companyName}"/></h1>
        <small class="text-muted">Contact: <c:out value="${client.contactPerson}"/> &bull; <c:out value="${client.phone}"/></small>
    </div>
    <span class="badge fs-6 ${client.isActive ? 'bg-success' : 'bg-danger'} me-2">${client.isActive ? 'Active' : 'Inactive'}</span>
    <a href="${pageContext.request.contextPath}/clients/edit/${client.id}" class="btn btn-outline-secondary btn-sm"><i class="fas fa-edit me-1"></i>Edit</a>
</div>

<div class="row g-4">
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold"><i class="fas fa-info-circle me-2"></i>Client Info</div>
            <div class="card-body">
                <dl class="row small mb-0">
                    <dt class="col-5 text-muted">Company</dt><dd class="col-7 fw-bold"><c:out value="${client.companyName}"/></dd>
                    <dt class="col-5 text-muted">Contact</dt><dd class="col-7"><c:out value="${client.contactPerson}"/></dd>
                    <dt class="col-5 text-muted">Email</dt><dd class="col-7"><c:out value="${client.email}"/></dd>
                    <dt class="col-5 text-muted">Phone</dt><dd class="col-7"><c:out value="${client.phone}"/></dd>
                    <dt class="col-5 text-muted">Address</dt><dd class="col-7"><c:out value="${client.address}"/></dd>
                    <dt class="col-5 text-muted">Contract Start</dt><dd class="col-7">${client.contractStart}</dd>
                    <dt class="col-5 text-muted">Contract End</dt>
                    <dd class="col-7"><c:out value="${not empty client.contractEnd ? client.contractEnd : 'Ongoing'}"/></dd>
                </dl>
            </div>
        </div>

        <!-- Add Site -->
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-map-marker-alt me-2 text-success"></i>Add Site</div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/clients/site/create" method="post">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                    <input type="hidden" name="clientId" value="${client.id}">
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Site Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-sm" name="siteName" required placeholder="e.g. HQ Main Gate">
                    </div>
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Address</label>
                        <input type="text" class="form-control form-control-sm" name="address" placeholder="Location address">
                    </div>
                    <div class="row g-2 mb-2">
                        <div class="col">
                            <label class="form-label small fw-semibold">Type</label>
                            <select class="form-select form-select-sm" name="siteType">
                                <option value="RESIDENTIAL">Residential</option>
                                <option value="COMMERCIAL">Commercial</option>
                                <option value="INDUSTRIAL">Industrial</option>
                                <option value="GOVERNMENT">Government</option>
                                <option value="EDUCATIONAL">Educational</option>
                                <option value="HEALTHCARE">Healthcare</option>
                                <option value="OTHER">Other</option>
                            </select>
                        </div>
                        <div class="col">
                            <label class="form-label small fw-semibold">Risk Level</label>
                            <select class="form-select form-select-sm" name="riskLevel">
                                <option value="LOW">Low</option>
                                <option value="MEDIUM" selected>Medium</option>
                                <option value="HIGH">High</option>
                                <option value="CRITICAL">Critical</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Required Guards</label>
                        <input type="number" class="form-control form-control-sm" name="requiredGuards" min="1" value="1">
                    </div>
                    <button class="btn btn-success btn-sm w-100"><i class="fas fa-plus me-2"></i>Add Site</button>
                </form>
            </div>
        </div>
    </div>

    <div class="col-lg-8">
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold d-flex justify-content-between">
                <span><i class="fas fa-map-marker-alt me-2"></i>Sites (${sites.size()})</span>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty sites}">
                        <div class="text-center text-muted py-5">
                            <i class="fas fa-map-marker-alt fa-3x mb-3 d-block opacity-25"></i>
                            No sites registered for this client yet.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="table-light"><tr><th>Site Name</th><th>Address</th><th>Type</th><th>Risk</th><th>Guards Req.</th><th>Active</th></tr></thead>
                                <tbody>
                                <c:forEach var="site" items="${sites}">
                                    <tr>
                                        <td class="fw-semibold"><c:out value="${site.siteName}"/></td>
                                        <td><small><c:out value="${site.address}"/></small></td>
                                        <td><span class="badge bg-secondary"><c:out value="${site.siteType}"/></span></td>
                                        <td>
                                            <span class="badge ${site.riskLevel == 'HIGH' || site.riskLevel == 'CRITICAL' ? 'bg-danger' : site.riskLevel == 'MEDIUM' ? 'bg-warning text-dark' : 'bg-success'}">
                                                <c:out value="${site.riskLevel}"/>
                                            </span>
                                        </td>
                                        <td>${site.requiredGuards}</td>
                                        <td><span class="badge ${site.isActive ? 'bg-success' : 'bg-danger'}">${site.isActive ? 'Yes' : 'No'}</span></td>
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
