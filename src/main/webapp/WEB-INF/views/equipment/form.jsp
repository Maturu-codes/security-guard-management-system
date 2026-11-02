<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty equipment}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Equipment' : 'Add Equipment'}" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i> Back</a>
    <h1 class="h3 fw-bold mb-0"><i class="fas fa-gun me-2 text-dark"></i>${isEdit ? 'Edit Equipment' : 'Add New Equipment'}</h1>
</div>

<div class="card border-0 shadow-sm" style="max-width:750px;">
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/equipment/${isEdit ? 'update/'.concat(equipment.id) : 'create'}" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
            <div class="row g-3">

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Equipment Type <span class="text-danger">*</span></label>
                    <select class="form-select" name="equipmentType" required>
                        <option value="">Select type...</option>
                        <c:forEach var="t" items="${['FIREARM','RADIO','VEHICLE','UNIFORM','BATON','HANDCUFFS','TORCH','BINOCULARS','CCTV','OTHER']}">
                            <option value="${t}" ${equipment.equipmentType == t ? 'selected' : ''}>${t}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Serial Number <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="serialNumber" required
                           value="<c:out value='${equipment.serialNumber}'/>"
                           ${isEdit ? 'readonly' : ''} placeholder="Unique serial number">
                    <c:if test="${isEdit}"><div class="form-text">Serial number cannot be changed after creation.</div></c:if>
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Make / Model</label>
                    <input type="text" class="form-control" name="makeModel"
                           value="<c:out value='${equipment.makeModel}'/>" placeholder="e.g. Glock 17">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Condition</label>
                    <select class="form-select" name="conditionState">
                        <c:forEach var="c" items="${['EXCELLENT','GOOD','FAIR','POOR']}">
                            <option value="${c}" ${equipment.conditionState == c ? 'selected' : ''}>${c}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Acquisition Date</label>
                    <input type="date" class="form-control" name="acquisitionDate" value="${equipment.acquisitionDate}">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Acquisition Cost (KES)</label>
                    <input type="number" class="form-control" name="acquisitionCost" min="0" step="0.01"
                           value="${equipment.acquisitionCost}">
                </div>

                <div class="col-12">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="requiresLicense" id="requiresLicense"
                               ${equipment.requiresLicense ? 'checked' : ''} onchange="toggleLicense(this)">
                        <label class="form-check-label" for="requiresLicense">Requires License / Permit</label>
                    </div>
                </div>

                <div id="licenseFields" class="${equipment.requiresLicense ? '' : 'd-none'}">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">License Number</label>
                            <input type="text" class="form-control" name="licenseNumber" value="<c:out value='${equipment.licenseNumber}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">License Expiry</label>
                            <input type="date" class="form-control" name="licenseExpiry" value="${equipment.licenseExpiry}">
                        </div>
                    </div>
                </div>

                <c:if test="${isEdit}">
                <div class="col-md-6">
                    <label class="form-label fw-semibold">Status</label>
                    <select class="form-select" name="status">
                        <c:forEach var="s" items="${['AVAILABLE','ASSIGNED','MAINTENANCE','DECOMMISSIONED']}">
                            <option value="${s}" ${equipment.status == s ? 'selected' : ''}>${s}</option>
                        </c:forEach>
                    </select>
                </div>
                </c:if>

                <div class="col-12">
                    <label class="form-label fw-semibold">Description / Notes</label>
                    <textarea class="form-control" name="description" rows="2" placeholder="Additional details..."><c:out value="${equipment.description}"/></textarea>
                </div>

                <div class="col-12">
                    <label class="form-label fw-semibold">Notes</label>
                    <textarea class="form-control" name="notes" rows="2"><c:out value="${equipment.notes}"/></textarea>
                </div>

                <div class="col-12 d-flex gap-2 justify-content-end">
                    <a href="${pageContext.request.contextPath}/equipment" class="btn btn-outline-secondary">Cancel</a>
                    <button type="submit" class="btn btn-dark px-4">
                        <i class="fas fa-save me-2"></i>${isEdit ? 'Update' : 'Add Equipment'}
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
function toggleLicense(cb) {
    document.getElementById('licenseFields').classList.toggle('d-none', !cb.checked);
}
</script>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
