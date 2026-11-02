<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty client}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Client' : 'New Client'}" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/clients" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-building me-2 text-primary"></i>${isEdit ? 'Edit Client' : 'New Client'}</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:750px;">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/clients/${isEdit ? 'update/'.concat(client.id) : 'create'}" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Company Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="companyName" required value="<c:out value='${client.companyName}'/>">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Contact Person</label>
                    <input type="text" class="form-control" name="contactPerson" value="<c:out value='${client.contactPerson}'/>">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Email</label>
                    <input type="email" class="form-control" name="email" value="<c:out value='${client.email}'/>">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Phone</label>
                    <input type="text" class="form-control" name="phone" value="<c:out value='${client.phone}'/>" placeholder="+254700000000">
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Address</label>
                    <textarea class="form-control" name="address" rows="2"><c:out value="${client.address}"/></textarea>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Contract Start</label>
                    <input type="date" class="form-control" name="contractStart" value="${client.contractStart}">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Contract End <small class="text-muted">(leave blank for ongoing)</small></label>
                    <input type="date" class="form-control" name="contractEnd" value="${client.contractEnd}">
                </div>
                <c:if test="${isEdit}">
                <div class="col-12">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="isActive" id="isActive" ${client.isActive ? 'checked' : ''}>
                        <label class="form-check-label" for="isActive">Active Client</label>
                    </div>
                </div>
                </c:if>
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/clients" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4">
                        <i class="fas fa-save me-2"></i>${isEdit ? 'Update' : 'Create Client'}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
