import { renderPlanScreen } from './screens/plan.js';
import { t } from './translations.js';
import { renderRecordScreen } from './screens/record.js';
import { renderProgressScreen } from './screens/progress.js';
import { renderSettingsScreen } from './screens/settings.js';

const mainContent = document.getElementById('main-content');

export function renderUI(route) {
    mainContent.innerHTML = '';

    switch (route) {
        case 'plan':
            mainContent.appendChild(renderPlanScreen());
            break;
        case 'record':
            mainContent.appendChild(renderRecordScreen());
            break;
        case 'progress':
            mainContent.appendChild(renderProgressScreen());
            break;
        case 'settings':
            mainContent.appendChild(renderSettingsScreen());
            break;
        default:
            mainContent.innerHTML = '<h1>404 - Not Found</h1>';
    }
}

// Initial render
renderUI(window.location.hash.replace('#', '') || 'plan');

/* --- Notifications & Modals --- */
export function showToast(message, type = 'success') {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    // Simple icon based on type
    const icon = type === 'success' ? '✅' : '⚠️';
    toast.innerHTML = `<span>${icon}</span> <span>${message}</span>`;

    container.appendChild(toast);

    // Auto remove
    setTimeout(() => {
        toast.style.animation = 'fadeOut 0.3s ease-out forwards';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

export function showConfirm(message, onConfirm) {
    const modal = document.createElement('div');
    modal.className = 'modal-overlay fade-in';
    modal.innerHTML = `
        <div class="modal-content">
            <h3 style="margin-bottom:10px;">${t('confirm')}</h3>
            <p>${message}</p>
            <div class="modal-actions">
                <button id="btnCancel" class="btn btn-secondary">${t('cancel')}</button>
                <button id="btnConfirm" class="btn">${t('confirm')}</button>
            </div>
        </div>
    `;
    document.body.appendChild(modal);

    const close = () => {
        modal.classList.remove('fade-in');
        setTimeout(() => modal.remove(), 200);
    };

    modal.querySelector('#btnCancel').addEventListener('click', close);
    modal.querySelector('#btnConfirm').addEventListener('click', () => {
        onConfirm();
        close();
    });
}

export function navigateTo(route) {
    window.location.hash = route;
}
