<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Incidents" scope="request"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h1 class="h3 fw-bold mb-0"><i class="fas fa-triangle-exclamation me-2 text-danger"></i>Incidents</h1>
        <p class="text-muted mb-0">Report and track security incidents</p>
    </div>
    <a href="${pageContext.request.contextPath}/incidents/new" class="btn btn-danger">
        <i class="fas fa-plus me-2"></i>Report Incident
    </a>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Type</th>
                        <th>Site</th>
                        <th>Guard</th>
                        <th>Severity</th>
                        <th>Status</th>
                        <th>Date/Time</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty incidents}">
                        <tr>
                            <td colspan="9" class="text-center text-muted py-5">
                                <i class="fas fa-check-circle fa-3x mb-3 d-block text-success opacity-50"></i>
                                No incidents recorded.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="inc" items="${incidents}">
                        <tr>
                            <td class="text-muted small">#${inc.id}</td>
                            <td class="fw-semibold"><c:out value="${inc.title}"/></td>
                            <td>
                                <span class="badge bg-secondary">
                                    <c:out value="${inc.incidentType}"/>
                                </span>
                            </td>
                            <td><c:out value="${inc.siteName}"/></td>
                            <td><c:out value="${inc.guardName}"/></td>
                            <td>
                                <span class="badge ${inc.severity == 'CRITICAL' ? 'bg-danger' :
                                    inc.severity == 'HIGH' ? 'bg-warning text-dark' :
                                    inc.severity == 'MEDIUM' ? 'bg-info text-dark' : 'bg-light text-dark'}">
                                    <c:out value="${inc.severity}"/>
                                </span>
                            </td>
                            <td>
                                <span class="badge ${inc.status == 'OPEN' ? 'bg-danger' :
                                    inc.status == 'ESCALATED' ? 'bg-dark' :
                                    inc.status == 'RESOLVED' ? 'bg-success' :
                                    inc.status == 'UNDER_REVIEW' ? 'bg-warning text-dark' : 'bg-secondary'}">
                                    <c:out value="${inc.status}"/>
                                </span>
                            </td>
                            <td>
                                <fmt:formatDate value="${inc.incidentDatetime}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/incidents/view/${inc.id}"
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
