<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty shift}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Shift' : 'New Shift'}" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/shifts" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-calendar-plus me-2 text-success"></i>${isEdit ? 'Edit Shift' : 'Schedule New Shift'}</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:700px;">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/shifts/${isEdit ? 'update/'.concat(shift.id) : 'create'}" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">
                <div class="col-12">
                    <label class="form-label fw-semibold">Shift Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="shiftName" required
                           value="<c:out value='${shift.shiftName}'/>" placeholder="e.g. Night Shift A">
                </div>
                <div class="col-12">
                    <label class="form-label fw-semibold">Site <span class="text-danger">*</span></label>
                    <select class="form-select" name="siteId" required>
                        <option value="">Select site...</option>
                        <c:forEach var="site" items="${sites}">
                            <option value="${site.id}" ${shift.siteId == site.id ? 'selected' : ''}>
                                <c:out value="${site.siteName}"/> — <c:out value="${site.companyName}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Shift Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" name="shiftDate" required value="${shift.shiftDate}">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Start Time <span class="text-danger">*</span></label>
                    <input type="time" class="form-control" name="startTime" required value="${shift.startTime}">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">End Time <span class="text-danger">*</span></label>
                    <input type="time" class="form-control" name="endTime" required value="${shift.endTime}">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Required Guards</label>
                    <input type="number" class="form-control" name="requiredGuards" min="1" value="${not empty shift.requiredGuards ? shift.requiredGuards : 1}">
                </div>
                <c:if test="${isEdit}">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Status</label>
                    <select class="form-select" name="status">
                        <option value="SCHEDULED" ${shift.status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                        <option value="ACTIVE" ${shift.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="COMPLETED" ${shift.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        <option value="CANCELLED" ${shift.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>
                </c:if>
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/shifts" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-success px-4">
                        <i class="fas fa-save me-2"></i>${isEdit ? 'Update' : 'Create Shift'}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
