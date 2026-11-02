<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>${not empty pageTitle ? pageTitle : 'SGMS'} — Security Guards Management System</title>

    <!-- Bootstrap 5 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/dashboard">
            <i class="fas fa-shield-halved me-2 text-warning"></i>SGMS Kenya
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarMain">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/dashboard') ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/dashboard">
                        <i class="fas fa-gauge me-1"></i>Dashboard
                    </a>
                </li>
                <c:if test="${sessionScope.userRole != 'CLIENT'}">
                <li class="nav-item">
                    <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/guards') ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/guards">
                        <i class="fas fa-user-shield me-1"></i>Guards
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-calendar-days me-1"></i>Operations
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/shifts">
                            <i class="fas fa-clock me-2"></i>Shifts</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/attendance">
                            <i class="fas fa-clipboard-check me-2"></i>Attendance</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/patrols">
                            <i class="fas fa-route me-2"></i>Patrols</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/incidents">
                            <i class="fas fa-triangle-exclamation me-2"></i>Incidents</a></li>
                    </ul>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-toolbox me-1"></i>Assets
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/equipment">
                            <i class="fas fa-gun me-2"></i>Equipment</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/k9">
                            <i class="fas fa-dog me-2"></i>K9 Units</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/clients">
                            <i class="fas fa-building me-2"></i>Clients &amp; Sites</a></li>
                    </ul>
                </li>
                </c:if>
                <c:if test="${sessionScope.userRole == 'SUPER_ADMIN' || sessionScope.userRole == 'COMPANY_ADMIN'}">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-coins me-1"></i>Payroll
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/payroll">
                            <i class="fas fa-list me-2"></i>Payroll Periods</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/payroll/new">
                            <i class="fas fa-plus me-2"></i>Process Payroll</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/liability">
                            <i class="fas fa-gavel me-2"></i>Liability Reports</a></li>
                    </ul>
                </li>
                </c:if>
            </ul>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-circle-user me-1"></i>
                        <c:out value="${sessionScope.userFullName}"/>
                        <span class="badge bg-warning text-dark ms-1 small">
                            <c:out value="${sessionScope.userRole}"/>
                        </span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                            <i class="fas fa-user me-2"></i>My Profile</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-right-from-bracket me-2"></i>Logout</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main content wrapper -->
<div class="content-wrapper">
    <div class="container-fluid py-3">

        <!-- Flash messages -->
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <c:out value="${sessionScope.successMsg}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <c:out value="${requestScope.error}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
