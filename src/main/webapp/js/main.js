/**
 * SGMS - Security Guards Management System
 * Main JavaScript
 */

// Bootstrap form validation
(function () {
    'use strict';
    const forms = document.querySelectorAll('.needs-validation');
    Array.from(forms).forEach(form => {
        form.addEventListener('submit', event => {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });
})();

// Auto-dismiss alerts after 5 seconds
document.addEventListener('DOMContentLoaded', () => {
    const alerts = document.querySelectorAll('.alert.alert-success');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            if (bsAlert) bsAlert.close();
        }, 5000);
    });

    // Set datetime-local fields to now if empty
    document.querySelectorAll('input[type="datetime-local"]').forEach(el => {
        if (!el.value) {
            const now = new Date();
            now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
            el.value = now.toISOString().slice(0, 16);
        }
    });
});

// Confirm dangerous actions
document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
        const msg = el.dataset.confirm || 'Are you sure?';
        if (!confirm(msg)) e.preventDefault();
    });
});
