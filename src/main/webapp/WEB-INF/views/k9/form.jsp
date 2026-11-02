<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty dog}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit K9 Unit' : 'Register K9 Unit'}" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/k9" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-dog me-2 text-warning"></i>${isEdit ? 'Edit K9 Unit' : 'Register New K9 Unit'}</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:750px;">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/k9/${isEdit ? 'update/'.concat(dog.id) : 'create'}" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Dog Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="name" required value="<c:out value='${dog.name}'/>">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Breed <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="breed" required value="<c:out value='${dog.breed}'/>" placeholder="e.g. German Shepherd">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Date of Birth</label>
                    <input type="date" class="form-control" name="dateOfBirth" value="${dog.dateOfBirth}">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Gender</label>
                    <select class="form-select" name="gender">
                        <option value="MALE" ${dog.gender == 'MALE' ? 'selected' : ''}>Male</option>
                        <option value="FEMALE" ${dog.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold">Acquired Date</label>
                    <input type="date" class="form-control" name="acquiredDate" value="${dog.acquiredDate}">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Microchip Number</label>
                    <input type="text" class="form-control" name="chipNumber" value="<c:out value='${dog.chipNumber}'/>" placeholder="ISO chip number">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Handler</label>
                    <select class="form-select" name="currentHandlerId">
                        <option value="">Unassigned</option>
                        <c:forEach var="h" items="${handlers}">
                            <option value="${h.id}" ${dog.currentHandlerId == h.id ? 'selected' : ''}>
                                <c:out value="${h.fullName}"/> (<c:out value="${h.employeeNumber}"/>)
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Training Level</label>
                    <select class="form-select" name="trainingLevel">
                        <c:forEach var="l" items="${['BASIC','INTERMEDIATE','ADVANCED','SPECIALIST']}">
                            <option value="${l}" ${dog.trainingLevel == l ? 'selected' : ''}>${l}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Specialization</label>
                    <select class="form-select" name="specialization">
                        <c:forEach var="sp" items="${['PATROL','DETECTION','TRACKING','PROTECTION','SEARCH_RESCUE','MULTI_PURPOSE']}">
                            <option value="${sp}" ${dog.specialization == sp ? 'selected' : ''}>${sp}</option>
                        </c:forEach>
                    </select>
                </div>
                <c:if test="${isEdit}">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Status</label>
                    <select class="form-select" name="status">
                        <c:forEach var="s" items="${['ACTIVE','TRAINING','MEDICAL_LEAVE','RETIRED','DECEASED']}">
                            <option value="${s}" ${dog.status == s ? 'selected' : ''}>${s}</option>
                        </c:forEach>
                    </select>
                </div>
                </c:if>
                <div class="col-12">
                    <label class="form-label fw-semibold">Notes</label>
                    <textarea class="form-control" name="notes" rows="3"><c:out value="${dog.notes}"/></textarea>
                </div>
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/k9" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-warning text-dark px-4">
                        <i class="fas fa-save me-2"></i>${isEdit ? 'Update' : 'Register K9 Unit'}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
