<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="K9 Profile" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex align-items-center mb-4">
    <a href="${pageContext.request.contextPath}/k9" class="btn btn-outline-secondary me-3"><i class="fas fa-arrow-left"></i></a>
    <div class="flex-grow-1">
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-dog me-2 text-warning"></i><c:out value="${dog.name}"/></h1>
        <small class="text-muted"><c:out value="${dog.breed}"/> &bull; <c:out value="${dog.gender}"/> &bull; DOB: ${dog.dateOfBirth}</small>
    </div>
    <span class="badge fs-6 ${dog.status == 'ACTIVE' ? 'bg-success' : dog.status == 'RETIRED' ? 'bg-secondary' : 'bg-warning text-dark'} me-2">
        <c:out value="${dog.status}"/>
    </span>
    <a href="${pageContext.request.contextPath}/k9/edit/${dog.id}" class="btn btn-outline-secondary btn-sm">
        <i class="fas fa-edit me-1"></i>Edit
    </a>
</div>

<div class="row g-4">
    <!-- Profile -->
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold"><i class="fas fa-id-card me-2"></i>K9 Profile</div>
            <div class="card-body">
                <dl class="row small mb-0">
                    <dt class="col-5 text-muted">Name</dt><dd class="col-7 fw-bold"><c:out value="${dog.name}"/></dd>
                    <dt class="col-5 text-muted">Breed</dt><dd class="col-7"><c:out value="${dog.breed}"/></dd>
                    <dt class="col-5 text-muted">Gender</dt><dd class="col-7"><c:out value="${dog.gender}"/></dd>
                    <dt class="col-5 text-muted">DOB</dt><dd class="col-7">${dog.dateOfBirth}</dd>
                    <dt class="col-5 text-muted">Chip #</dt><dd class="col-7"><code><c:out value="${not empty dog.chipNumber ? dog.chipNumber : 'N/A'}"/></code></dd>
                    <dt class="col-5 text-muted">Training</dt><dd class="col-7"><span class="badge bg-info text-dark"><c:out value="${dog.trainingLevel}"/></span></dd>
                    <dt class="col-5 text-muted">Spec.</dt><dd class="col-7"><c:out value="${dog.specialization}"/></dd>
                    <dt class="col-5 text-muted">Handler</dt>
                    <dd class="col-7"><c:out value="${not empty dog.currentHandlerName ? dog.currentHandlerName : 'Unassigned'}"/></dd>
                    <dt class="col-5 text-muted">Acquired</dt><dd class="col-7">${dog.acquiredDate}</dd>
                    <c:if test="${not empty dog.notes}">
                    <dt class="col-5 text-muted">Notes</dt><dd class="col-7"><c:out value="${dog.notes}"/></dd>
                    </c:if>
                </dl>
            </div>
        </div>

        <!-- Add Medical Record -->
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-syringe me-2 text-danger"></i>Add Medical Record</div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/k9/medical/${dog.id}" method="post">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Record Type</label>
                        <select class="form-select form-select-sm" name="recordType" required>
                            <option value="VACCINATION">Vaccination</option>
                            <option value="CHECKUP">Checkup</option>
                            <option value="TREATMENT">Treatment</option>
                            <option value="SURGERY">Surgery</option>
                            <option value="DEWORMING">Deworming</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Description</label>
                        <textarea class="form-control form-control-sm" name="description" rows="2" required></textarea>
                    </div>
                    <div class="mb-2">
                        <label class="form-label small fw-semibold">Vet Name</label>
                        <input type="text" class="form-control form-control-sm" name="vetName">
                    </div>
                    <div class="row g-2 mb-2">
                        <div class="col">
                            <label class="form-label small fw-semibold">Visit Date</label>
                            <input type="date" class="form-control form-control-sm" name="visitDate">
                        </div>
                        <div class="col">
                            <label class="form-label small fw-semibold">Next Visit</label>
                            <input type="date" class="form-control form-control-sm" name="nextVisitDate">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Cost (KES)</label>
                        <input type="number" class="form-control form-control-sm" name="cost" min="0" step="0.01">
                    </div>
                    <button class="btn btn-danger btn-sm w-100"><i class="fas fa-plus me-2"></i>Add Record</button>
                </form>
            </div>
        </div>
    </div>

    <!-- Medical & Training Records -->
    <div class="col-lg-8">
        <!-- Medical History -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header fw-semibold"><i class="fas fa-heartbeat me-2 text-danger"></i>Medical History</div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty medicalRecords}">
                        <div class="text-center text-muted py-4">No medical records yet.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0 small">
                                <thead class="table-light"><tr><th>Type</th><th>Description</th><th>Vet</th><th>Date</th><th>Next Visit</th><th>Cost (KES)</th></tr></thead>
                                <tbody>
                                <c:forEach var="mr" items="${medicalRecords}">
                                    <tr>
                                        <td><span class="badge bg-danger"><c:out value="${mr.recordType}"/></span></td>
                                        <td><c:out value="${mr.description}"/></td>
                                        <td><c:out value="${mr.vetName}"/></td>
                                        <td>${mr.visitDate}</td>
                                        <td><c:out value="${not empty mr.nextVisitDate ? mr.nextVisitDate : '—'}"/></td>
                                        <td><c:out value="${not empty mr.cost ? mr.cost : '—'}"/></td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Training Records -->
        <div class="card border-0 shadow-sm">
            <div class="card-header fw-semibold"><i class="fas fa-graduation-cap me-2 text-info"></i>Training History</div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty trainingRecords}">
                        <div class="text-center text-muted py-4">No training records yet.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover mb-0 small">
                                <thead class="table-light"><tr><th>Type</th><th>Trainer</th><th>Start</th><th>End</th><th>Result</th><th>Certificate</th></tr></thead>
                                <tbody>
                                <c:forEach var="tr" items="${trainingRecords}">
                                    <tr>
                                        <td><span class="badge bg-info text-dark"><c:out value="${tr.trainingType}"/></span></td>
                                        <td><c:out value="${tr.trainerName}"/></td>
                                        <td>${tr.startDate}</td>
                                        <td>${tr.endDate}</td>
                                        <td>
                                            <span class="badge ${tr.result == 'PASS' ? 'bg-success' : tr.result == 'FAIL' ? 'bg-danger' : 'bg-secondary'}">
                                                <c:out value="${tr.result}"/>
                                            </span>
                                        </td>
                                        <td><code><c:out value="${not empty tr.certificateNumber ? tr.certificateNumber : '—'}"/></code></td>
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
