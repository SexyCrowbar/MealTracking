import { renderUI, navigateTo } from './ui.js';
import { initStorage, getSettings } from './storage.js';

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
    state.settings = getSettings();

    // Setup Navigation
    window.addEventListener('hashchange', handleRouting);

    // Initial Route
    handleRouting();
}

function handleRouting() {
    const hash = window.location.hash.replace('#', '') || 'plan';
    state.currentRoute = hash;

    // Update UI
    document.querySelectorAll('.nav-item').forEach(el => {
        el.classList.toggle('active', el.dataset.target === hash);
    });

    renderUI(hash);
}

// Start
document.addEventListener('DOMContentLoaded', init);
