<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Equipment" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-gun me-2 text-dark"></i>Equipment Tracker</h1>
        <p class="text-muted mb-0">Manage weapons, radios, uniforms and all guard equipment</p>
    </div>
    <a href="${pageContext.request.contextPath}/equipment/new" class="btn btn-dark">
        <i class="fas fa-plus me-2"></i>Add Equipment
    </a>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
    <div class="col-sm-4">
        <div class="card border-0 shadow-sm text-center py-3 border-start border-success border-4">
            <div class="h3 fw-bold text-success mb-0">${totalAvailable}</div>
            <small class="text-muted">Available</small>
        </div>
    </div>
    <div class="col-sm-4">
        <div class="card border-0 shadow-sm text-center py-3 border-start border-warning border-4">
            <div class="h3 fw-bold text-warning mb-0">${totalAssigned}</div>
            <small class="text-muted">Assigned</small>
        </div>
    </div>
    <div class="col-sm-4">
        <div class="card border-0 shadow-sm text-center py-3 border-start border-dark border-4">
            <div class="h3 fw-bold text-dark mb-0">${equipmentList.size()}</div>
            <small class="text-muted">Total Items</small>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>Type</th><th>Serial #</th><th>Make / Model</th>
                        <th>Condition</th><th>Assigned To</th><th>License Expiry</th>
                        <th>Status</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty equipmentList}">
                        <tr><td colspan="8" class="text-center text-muted py-5">
                            <i class="fas fa-box-open fa-3x mb-3 d-block opacity-25"></i>
                            No equipment registered. <a href="${pageContext.request.contextPath}/equipment/new">Add the first item</a>.
                        </td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="item" items="${equipmentList}">
                            <tr>
                                <td>
                                    <span class="badge bg-dark">
                                        <c:out value="${item.equipmentType}"/>
                                    </span>
                                </td>

                                <td>
                                    <code><c:out value="${item.serialNumber}"/></code>
                                </td>

                                <td>
                                    <c:out value="${item.makeModel}"/>
                                </td>

                                <!-- CONDITION STATE -->
                                <td>
                                    <c:choose>
                                        <c:when test='${item.conditionState == "EXCELLENT"}'>
                                            <span class="badge bg-success">
                                                <c:out value="${item.conditionState}"/>
                                            </span>
                                        </c:when>
                                        <c:when test='${item.conditionState == "GOOD"}'>
                                            <span class="badge bg-info text-dark">
                                                <c:out value="${item.conditionState}"/>
                                            </span>
                                        </c:when>
                                        <c:when test='${item.conditionState == "FAIR"}'>
                                            <span class="badge bg-warning text-dark">
                                                <c:out value="${item.conditionState}"/>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">
                                                <c:out value="${item.conditionState}"/>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- CURRENT ASSIGNEE -->
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty item.currentAssigneeName}">
                                            <i class="fas fa-user me-1 text-muted"></i>
                                            <c:out value="${item.currentAssigneeName}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- LICENSE EXPIRY -->
                                <td>
                                    <c:choose>
                                        <c:when test="${item.requiresLicense and not empty item.licenseExpiry}">
                                            <span class="small">
                                                <c:out value="${item.licenseExpiry}"/>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">N/A</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- STATUS -->
                                <td>
                                    <c:choose>
                                        <c:when test='${item.status == "AVAILABLE"}'>
                                            <span class="badge bg-success">
                                                <c:out value="${item.status}"/>
                                            </span>
                                        </c:when>
                                        <c:when test='${item.status == "ASSIGNED"}'>
                                            <span class="badge bg-warning text-dark">
                                                <c:out value="${item.status}"/>
                                            </span>
                                        </c:when>
                                        <c:when test='${item.status == "MAINTENANCE"}'>
                                            <span class="badge bg-info text-dark">
                                                <c:out value="${item.status}"/>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">
                                                <c:out value="${item.status}"/>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- ACTION -->
                                <td>
                                    <a href="${pageContext.request.contextPath}/equipment/view/${item.id}"
                                       class="btn btn-sm btn-outline-primary">
                                        <i class="fas fa-eye"></i>
                                    </a>
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

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>