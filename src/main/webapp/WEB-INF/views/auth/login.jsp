<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — SGMS Kenya</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <style>
        body { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); min-height: 100vh; }
        .login-card { border: none; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.5); }
        .shield-icon { font-size: 3rem; color: #ffc107; }
        .btn-login { background: linear-gradient(135deg, #ffc107, #ff8c00); border: none; color: #1a1a2e; font-weight: 700; }
        .btn-login:hover { background: linear-gradient(135deg, #ff8c00, #ffc107); color: #1a1a2e; }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">
            <div class="card login-card">
                <div class="card-body p-5">
                    <div class="text-center mb-4">
                        <i class="fas fa-shield-halved shield-icon"></i>
                        <h2 class="mt-2 fw-bold">SGMS Kenya</h2>
                        <p class="text-muted small">Security Guards Management System</p>
                    </div>

                    <c:if test="${not empty requestScope.error}">
                        <div class="alert alert-danger py-2">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <c:out value="${requestScope.error}"/>
                        </div>
                    </c:if>
                    <c:if test="${param.logout eq 'true'}">
                        <div class="alert alert-info py-2">
                            <i class="fas fa-info-circle me-2"></i>You have been logged out.
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post" novalidate>
                        <!-- CSRF token -->
                        <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.csrfToken}'/>">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Username</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-user"></i></span>
                                <input type="text" class="form-control" name="username"
                                       value="<c:out value='${param.username}'/>"
                                       placeholder="Enter username" required autofocus
                                       autocomplete="username">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Password</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                <input type="password" class="form-control" name="password"
                                       placeholder="Enter password" required
                                       autocomplete="current-password" id="passwordField">
                                <button class="btn btn-outline-secondary" type="button"
                                        onclick="togglePwd()">
                                    <i class="fas fa-eye" id="pwdEyeIcon"></i>
                                </button>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-login w-100 py-2">
                            <i class="fas fa-right-to-bracket me-2"></i>Sign In
                        </button>
                    </form>

                    <div class="mt-4 text-center">
                        <small class="text-muted">
                            <i class="fas fa-lock me-1"></i>Secure HTTPS connection
                        </small>
                    </div>
                </div>
            </div>
            <p class="text-center text-white-50 mt-3 small">
                &copy; 2024 SGMS Kenya &mdash; All rights reserved
            </p>
        </div>
    </div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
<script>
function togglePwd() {
    const f = document.getElementById('passwordField');
    const i = document.getElementById('pwdEyeIcon');
    if (f.type === 'password') {
        f.type = 'text';
        i.className = 'fas fa-eye-slash';
    } else {
        f.type = 'password';
        i.className = 'fas fa-eye';
    }
}
</script>
</body>
</html>
