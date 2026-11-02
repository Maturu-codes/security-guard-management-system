<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html><head>
<meta charset="UTF-8"><title>500 Server Error - SGMS</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh">
<div class="container text-center py-5">
    <i class="fas fa-circle-exclamation fa-5x text-danger mb-4"></i>
    <h1 class="display-4 fw-bold">500</h1>
    <h2>Internal Server Error</h2>
    <p class="text-muted">Something went wrong. Please try again or contact your administrator.</p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary mt-3">
        <i class="fas fa-home me-2"></i>Return to Dashboard
    </a>
</div>
</body></html>
