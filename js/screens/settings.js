import { testApiKey } from '../api.js';
import { getUserProfile, saveUserProfile, getSettings, saveSettings } from '../storage.js';
import { showToast } from '../ui.js';

import { t, setLang, getLang } from '../translations.js';
import { ACTIVITY_LEVELS } from '../utils.js';

export function renderSettingsScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';

    const settings = getSettings();
    const profile = getUserProfile() || {
        age: 30, gender: 'male', height: 175, weight: 80, goalWeight: 75, activity: 'sedentary'
    };
    const currentLang = getLang();

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">${t('screen_title_settings')}</h1>
        </div>
        
        <!-- Language Section -->
         <div class="card">
            <div class="form-group">
                <label class="form-label">${t('language')}</label>
                <select id="langSelect" class="form-select">
                    <option value="en" ${currentLang === 'en' ? 'selected' : ''}>English</option>
                    <option value="uk" ${currentLang === 'uk' ? 'selected' : ''}>Українська</option>
                </select>
            </div>
        </div>
        
        <!-- API Section -->
        <div class="card api-key-section">
            <h3 style="margin-bottom:10px;">${t('ai_config')}</h3>
            <div class="form-group">
                <label class="form-label">${t('gemini_api_key')}</label>
                <input type="password" id="apiKey" class="form-input" value="${settings.apiKey || ''}" placeholder="Paste your API key here">
            </div>
            
             <div class="form-group">
                <label class="form-label">${t('model')}</label>
                <select id="geminiModel" class="form-select">
                    <option value="gemini-3-flash-preview" ${settings.geminiModel === 'gemini-3-flash-preview' ? 'selected' : ''}>Gemini 3 Flash (Preview)</option>
                    <option value="gemini-3-pro-preview" ${settings.geminiModel === 'gemini-3-pro-preview' ? 'selected' : ''}>Gemini 3 Pro (Preview)</option>
                    <option value="gemini-2.5-flash" ${settings.geminiModel === 'gemini-2.5-flash' ? 'selected' : ''}>Gemini 2.5 Flash (Stable)</option>
                    <option value="gemini-2.5-pro" ${settings.geminiModel === 'gemini-2.5-pro' ? 'selected' : ''}>Gemini 2.5 Pro (Stable)</option>
                    <option value="gemini-2.0-flash" ${settings.geminiModel === 'gemini-2.0-flash' ? 'selected' : ''}>Gemini 2.0 Flash</option>
                    <option value="gemini-1.5-flash" ${settings.geminiModel === 'gemini-1.5-flash' ? 'selected' : ''}>Gemini 1.5 Flash</option>
                    <option value="gemini-1.5-pro" ${settings.geminiModel === 'gemini-1.5-pro' ? 'selected' : ''}>Gemini 1.5 Pro</option>
                </select>
            </div>

            <button id="btnTestKey" class="btn btn-secondary" style="width:100%">${t('test_key')}</button>
        </div>

        <!-- Profile Section -->
        <div class="card">
            <h3 style="margin-bottom:10px;">${t('user_profile')}</h3>
            <div class="form-group">
                <label class="form-label">${t('age')}</label>
                <input type="number" id="pAge" class="form-input" value="${profile.age}">
            </div>
            <div class="form-group">
                <label class="form-label">${t('gender')}</label>
                <select id="pGender" class="form-select">
                    <option value="male" ${profile.gender === 'male' ? 'selected' : ''}>Male</option>
                    <option value="female" ${profile.gender === 'female' ? 'selected' : ''}>Female</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">${t('height')}</label>
                <input type="number" id="pHeight" class="form-input" value="${profile.height}">
            </div>
             <div class="form-group">
                <label class="form-label">${t('weight')}</label>
                <input type="number" id="pWeight" class="form-input" value="${profile.weight}">
            </div>
             <div class="form-group">
                <label class="form-label">${t('goal_weight')}</label>
                <input type="number" id="pGoalWeight" class="form-input" value="${profile.goalWeight}">
            </div>
            <div class="form-group">
                <label class="form-label">${t('activity_level')}</label>
                <select id="pActivity" class="form-select">
                    ${Object.keys(ACTIVITY_LEVELS).map(k =>
        `<option value="${k}" ${profile.activity === k ? 'selected' : ''}>${t(k)}</option>`
    ).join('')}
                </select>
            </div>
        </div>

        <!-- Preferences -->
        <div class="card">
            <h3 style="margin-bottom:10px;">${t('preferences')}</h3>
            <div class="toggle-switch">
                <span>${t('show_macros')}</span>
                <input type="checkbox" id="showMacros" class="toggle-input" ${settings.showMacros ? 'checked' : ''}>
            </div>
            <div class="toggle-switch">
                <span>${t('show_gi')}</span>
                <input type="checkbox" id="showGI" class="toggle-input" ${settings.showGI ? 'checked' : ''}>
            </div>
             <div class="toggle-switch">
                <span>${t('diabetic_mode')}</span>
                <input type="checkbox" id="diabeticMode" class="toggle-input" ${settings.diabeticMode ? 'checked' : ''}>
            </div>
            
            <div id="insulinRatioContainer" class="form-group" style="margin-top:10px; display:${settings.diabeticMode ? 'block' : 'none'};">
                <label class="form-label">${t('insulin_ratio')}</label>
                <input type="number" id="insulinRatio" class="form-input" value="${settings.insulinRatio || ''}" placeholder="e.g. 10">
            </div>

            <div class="form-group" style="margin-top:10px;">
                <label class="form-label">${t('allergens')}</label>
                <input type="text" id="allergens" class="form-input" value="${settings.allergens}" placeholder="e.g. Peanuts, Gluten">
            </div>
        </div>

        <button id="btnSave" class="btn" style="width:100%; margin-bottom:20px;">${t('save_settings')}</button>
    `;

    // Event Listeners
    container.querySelector('#btnTestKey').addEventListener('click', async (e) => {
        const btn = e.target;
        const key = container.querySelector('#apiKey').value;
        const model = container.querySelector('#geminiModel').value;

        btn.textContent = t('testing');
        const success = await testApiKey(key, model);
        btn.textContent = success ? t('success') : t('failed');
        setTimeout(() => btn.textContent = t('test_key'), 3000);
    });

    // Toggle Diabetic Mode Input
    container.querySelector('#diabeticMode').addEventListener('change', (e) => {
        const inputContainer = container.querySelector('#insulinRatioContainer');
        inputContainer.style.display = e.target.checked ? 'block' : 'none';
    });

    container.querySelector('#btnSave').addEventListener('click', () => {
        // Save Settings
        const newSettings = {
            apiKey: container.querySelector('#apiKey').value,
            geminiModel: container.querySelector('#geminiModel').value,
            showMacros: container.querySelector('#showMacros').checked,
            showGI: container.querySelector('#showGI').checked,
            diabeticMode: container.querySelector('#diabeticMode').checked,
            insulinRatio: parseFloat(container.querySelector('#insulinRatio').value) || 0,
            allergens: container.querySelector('#allergens').value
        };
        saveSettings(newSettings);

        // Save Profile
        const newProfile = {
            age: parseInt(container.querySelector('#pAge').value),
            gender: container.querySelector('#pGender').value,
            height: parseFloat(container.querySelector('#pHeight').value),
            weight: parseFloat(container.querySelector('#pWeight').value),
            goalWeight: parseFloat(container.querySelector('#pGoalWeight').value),
            activity: container.querySelector('#pActivity').value
        };
        saveUserProfile(newProfile);

        const newLang = container.querySelector('#langSelect').value;
        if (newLang !== currentLang) {
            setLang(newLang);
            // Reload page to apply language changes cleanly across all modules
            location.reload();
            return;
        }

        showToast(t('settings_saved'), 'success');
    });

    return container;
}
