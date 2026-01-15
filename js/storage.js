const STORAGE_KEYS = {
    SETTINGS: 'meal_tracker_settings',
    PROFILE: 'meal_tracker_profile',
    LOGS: 'meal_tracker_logs',
    WEIGHT: 'meal_tracker_weight'
};

const DEFAULT_SETTINGS = {
    apiKey: '',
    geminiModel: 'gemini-1.5-flash',
    showMacros: false,
    showGI: false,
    diabeticMode: false,
    insulinRatio: 0,
    allergens: ''
};

const DAY_IN_MS = 24 * 60 * 60 * 1000;
const RETENTION_DAYS = 30;

export function initStorage() {
    if (!localStorage.getItem(STORAGE_KEYS.SETTINGS)) {
        localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(DEFAULT_SETTINGS));
    }
    pruneOldData();
}

function pruneOldData() {
    const cutoffDate = new Date(Date.now() - (RETENTION_DAYS * DAY_IN_MS));

    // Prune Logs
    const logs = JSON.parse(localStorage.getItem(STORAGE_KEYS.LOGS) || '[]');
    const newLogs = logs.filter(log => new Date(log.date) > cutoffDate);
    if (logs.length !== newLogs.length) {
        localStorage.setItem(STORAGE_KEYS.LOGS, JSON.stringify(newLogs));
        console.log(`Pruned ${logs.length - newLogs.length} old meal logs.`);
    }

    // Prune Weight
    const weights = JSON.parse(localStorage.getItem(STORAGE_KEYS.WEIGHT) || '[]');
    const newWeights = weights.filter(w => new Date(w.date) > cutoffDate);
    if (weights.length !== newWeights.length) {
        localStorage.setItem(STORAGE_KEYS.WEIGHT, JSON.stringify(newWeights));
        console.log(`Pruned ${weights.length - newWeights.length} old weight entries.`);
    }
}

export function getSettings() {
    const s = localStorage.getItem(STORAGE_KEYS.SETTINGS);
    return s ? JSON.parse(s) : DEFAULT_SETTINGS;
}

export function saveSettings(settings) {
    localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
}

export function getUserProfile() {
    const p = localStorage.getItem(STORAGE_KEYS.PROFILE);
    return p ? JSON.parse(p) : null;
}

export function saveUserProfile(profile) {
    localStorage.setItem(STORAGE_KEYS.PROFILE, JSON.stringify(profile));
}
