import { getSettings, saveSettings, getUserProfile, saveUserProfile } from '../storage.js';
import { testApiKey } from '../api.js';
import { ACTIVITY_LEVELS } from '../utils.js';

export function renderSettingsScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';

    const settings = getSettings();
    const profile = getUserProfile() || {
        age: 30, gender: 'male', height: 175, weight: 80, goalWeight: 75, activity: 'sedentary'
    };

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">Settings</h1>
        </div>
        
        <!-- API Section -->
        <div class="card api-key-section">
            <h3 style="margin-bottom:10px;">🤖 AI Configuration</h3>
            <div class="form-group">
                <label class="form-label">Gemini API Key</label>
                <input type="password" id="apiKey" class="form-input" value="${settings.apiKey || ''}" placeholder="Paste your API key here">
            </div>
            
             <div class="form-group">
                <label class="form-label">Model</label>
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

            <button id="btnTestKey" class="btn btn-secondary" style="width:100%">Test Key</button>
        </div>

        <!-- Profile Section -->
        <div class="card">
            <h3 style="margin-bottom:10px;">👤 User Profile</h3>
            <div class="form-group">
                <label class="form-label">Age</label>
                <input type="number" id="pAge" class="form-input" value="${profile.age}">
            </div>
            <div class="form-group">
                <label class="form-label">Gender</label>
                <select id="pGender" class="form-select">
                    <option value="male" ${profile.gender === 'male' ? 'selected' : ''}>Male</option>
                    <option value="female" ${profile.gender === 'female' ? 'selected' : ''}>Female</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Height (cm)</label>
                <input type="number" id="pHeight" class="form-input" value="${profile.height}">
            </div>
             <div class="form-group">
                <label class="form-label">Current Weight (kg)</label>
                <input type="number" id="pWeight" class="form-input" value="${profile.weight}">
            </div>
             <div class="form-group">
                <label class="form-label">Goal Weight (kg)</label>
                <input type="number" id="pGoalWeight" class="form-input" value="${profile.goalWeight}">
            </div>
            <div class="form-group">
                <label class="form-label">Activity Level</label>
                <select id="pActivity" class="form-select">
                    ${Object.keys(ACTIVITY_LEVELS).map(k =>
        `<option value="${k}" ${profile.activity === k ? 'selected' : ''}>${k.charAt(0).toUpperCase() + k.slice(1)}</option>`
    ).join('')}
                </select>
            </div>
        </div>

        <!-- Preferences -->
        <div class="card">
            <h3 style="margin-bottom:10px;">⚙️ Preferences</h3>
            <div class="toggle-switch">
                <span>Show Macros</span>
                <input type="checkbox" id="showMacros" class="toggle-input" ${settings.showMacros ? 'checked' : ''}>
            </div>
            <div class="toggle-switch">
                <span>Show Glycemic Index</span>
                <input type="checkbox" id="showGI" class="toggle-input" ${settings.showGI ? 'checked' : ''}>
            </div>
             <div class="toggle-switch">
                <span>Diabetic Mode</span>
                <input type="checkbox" id="diabeticMode" class="toggle-input" ${settings.diabeticMode ? 'checked' : ''}>
            </div>
            
            <div class="form-group" style="margin-top:10px;">
                <label class="form-label">Allergens (comma separated)</label>
                <input type="text" id="allergens" class="form-input" value="${settings.allergens}" placeholder="e.g. Peanuts, Gluten">
            </div>
        </div>

        <button id="btnSave" class="btn" style="width:100%; margin-bottom:20px;">Save Settings</button>
    `;

    // Event Listeners
    container.querySelector('#btnTestKey').addEventListener('click', async (e) => {
        const btn = e.target;
        const key = container.querySelector('#apiKey').value;
        const model = container.querySelector('#geminiModel').value;

        btn.textContent = 'Testing...';
        const success = await testApiKey(key, model);
        btn.textContent = success ? '✅ Success!' : '❌ Failed';
        setTimeout(() => btn.textContent = 'Test Key', 3000);
    });

    container.querySelector('#btnSave').addEventListener('click', () => {
        // Save Settings
        const newSettings = {
            apiKey: container.querySelector('#apiKey').value,
            geminiModel: container.querySelector('#geminiModel').value,
            showMacros: container.querySelector('#showMacros').checked,
            showGI: container.querySelector('#showGI').checked,
            diabeticMode: container.querySelector('#diabeticMode').checked,
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

        alert('Settings Saved!');
    });

    return container;
}
