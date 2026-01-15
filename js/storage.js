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

export function initStorage() {
    if (!localStorage.getItem(STORAGE_KEYS.SETTINGS)) {
        localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(DEFAULT_SETTINGS));
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
