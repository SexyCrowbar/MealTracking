import { renderUI } from './ui.js';
import { initStorage } from './storage.js';
import { t } from './translations.js';

// App State
const state = {
    currentRoute: 'plan',
    userProfile: null,
    settings: null
};

// Initialization
async function init() {
    console.log('App initializing...');

    // Load data
    state.settings = initStorage(); // Assuming getSettings is replaced by initStorage returning settings

    // Setup Navigation
    // Add click listeners for nav items
    document.querySelectorAll('.nav-item').forEach(link => {
        link.addEventListener('click', (e) => {
            // Remove active class from all
            document.querySelectorAll('.nav-item').forEach(l => l.classList.remove('active'));
            // Add active to clicked
            e.target.closest('.nav-item').classList.add('active');
        });
    });

    // Update Nav Text
    updateNavDropdowns();

    // Routing
    window.addEventListener('hashchange', () => {
        const route = window.location.hash.replace('#', '') || 'plan';
        renderUI(route);
        updateActiveNav(route);
    });

    // Initial Route
    const initialRoute = window.location.hash.replace('#', '') || 'plan';
    renderUI(initialRoute);
    updateActiveNav(initialRoute);
}

function updateActiveNav(route) {
    document.querySelectorAll('.nav-item').forEach(el => {
        const targetHash = el.getAttribute('href').replace('#', '');
        el.classList.toggle('active', targetHash === route);
    });
}

function updateNavDropdowns() {
    // We assume nav items have IDs or specific structure in index.html,
    // or we just select by href since they are simple links
    const navMap = {
        '#plan': t('nav_plan'),
        '#record': t('nav_record'),
        '#progress': t('nav_progress'),
        '#settings': t('nav_settings')
    };

    document.querySelectorAll('.nav-item').forEach(link => {
        const hash = link.getAttribute('href');
        const span = link.querySelector('span'); // The text span
        if (hash && navMap[hash] && span) {
            span.textContent = navMap[hash];
        }
    });
}

// Start
document.addEventListener('DOMContentLoaded', init);
