<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="K9 Units" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-dog me-2 text-warning"></i>K9 Units</h1>
        <p class="text-muted mb-0">${activeCount} active K9 units</p>
    </div>
    <a href="${pageContext.request.contextPath}/k9/new" class="btn btn-warning text-dark">
        <i class="fas fa-plus me-2"></i>Register K9 Unit
    </a>
</div>

<div class="row g-4">
<c:choose>
    <c:when test="${empty dogs}">
        <div class="col-12 text-center text-muted py-5">
            <i class="fas fa-dog fa-4x mb-3 d-block opacity-25"></i>
            <p>No K9 units registered. <a href="${pageContext.request.contextPath}/k9/new">Register the first unit</a>.</p>
        </div>
    </c:when>
    <c:otherwise>
    <c:forEach var="dog" items="${dogs}">
        <div class="col-md-6 col-xl-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <div class="d-flex align-items-center mb-3">
                        <div class="rounded-circle bg-warning bg-opacity-10 d-flex align-items-center justify-content-center me-3"
                             style="width:52px;height:52px;">
                            <i class="fas fa-dog fa-lg text-warning"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0"><c:out value="${dog.name}"/></h5>
                            <small class="text-muted"><c:out value="${dog.breed}"/> &bull; <c:out value="${dog.gender}"/></small>
                        </div>
                        <span class="badge ms-auto ${dog.status == 'ACTIVE' ? 'bg-success' : dog.status == 'RETIRED' ? 'bg-secondary' : 'bg-danger'}">
                            <c:out value="${dog.status}"/>
                        </span>
                    </div>
                    <div class="small text-muted mb-3">
                        <div><i class="fas fa-graduation-cap me-2"></i>Level: <strong><c:out value="${dog.trainingLevel}"/></strong></div>
                        <div><i class="fas fa-crosshairs me-2"></i>Spec: <strong><c:out value="${dog.specialization}"/></strong></div>
                        <div><i class="fas fa-user me-2"></i>Handler:
                            <strong><c:out value="${not empty dog.currentHandlerName ? dog.currentHandlerName : 'Unassigned'}"/></strong>
                        </div>
                        <c:if test="${not empty dog.chipNumber}">
                        <div><i class="fas fa-microchip me-2"></i>Chip: <code><c:out value="${dog.chipNumber}"/></code></div>
                        </c:if>
                        <div><i class="fas fa-calendar me-2"></i>DOB: ${dog.dateOfBirth}</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/k9/view/${dog.id}" class="btn btn-outline-warning btn-sm w-100">
                        <i class="fas fa-eye me-2"></i>View Full Profile
                    </a>
                </div>
            </div>
        </div>
    </c:forEach>
    </c:otherwise>
</c:choose>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
