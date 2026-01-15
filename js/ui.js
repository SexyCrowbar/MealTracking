import { renderPlanScreen } from './screens/plan.js';
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

export function navigateTo(route) {
    window.location.hash = route;
}
