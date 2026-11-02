<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Add Site" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/clients" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-map-marker-alt me-2 text-success"></i>Add New Site</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:650px;">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/clients/site/create" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">
                <div class="col-12">
                    <label class="form-label fw-semibold">Client <span class="text-danger">*</span></label>
                    <select class="form-select" name="clientId" required>
                        <option value="">Select client...</option>
                        <c:forEach var="cl" items="${clients}">
                            <option value="${cl.id}"><c:out value="${cl.companyName}"/></option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Site Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="siteName" required placeholder="e.g. Westlands Branch">
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Address</label>
                    <input type="text" class="form-control" name="address" placeholder="Physical address">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Site Type</label>
                    <select class="form-select" name="siteType">
                        <option value="RESIDENTIAL">Residential</option>
                        <option value="COMMERCIAL" selected>Commercial</option>
                        <option value="INDUSTRIAL">Industrial</option>
                        <option value="GOVERNMENT">Government</option>
                        <option value="EDUCATIONAL">Educational</option>
                        <option value="HEALTHCARE">Healthcare</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Risk Level</label>
                    <select class="form-select" name="riskLevel">
                        <option value="LOW">Low</option>
                        <option value="MEDIUM" selected>Medium</option>
                        <option value="HIGH">High</option>
                        <option value="CRITICAL">Critical</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Required Guards</label>
                    <input type="number" class="form-control" name="requiredGuards" min="1" value="1">
                </div>
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/clients" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-success px-4"><i class="fas fa-save me-2"></i>Create Site</button>
                </div>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
