import React, { useState } from 'react';
import { useUser } from '../contexts/UserContext';
import { useNavigate } from 'react-router-dom';

export default function SettingsScreen() {
    const { settings, updateSettings, profile } = useUser();
    const navigate = useNavigate();
    const [formData, setFormData] = useState(settings);

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        let val = type === 'checkbox' ? checked : value;

        // Warn for estimated insulin
        if (name === 'showInsulin' && checked) {
            if (!confirm("⚠️ WARNING: This feature provides ESTIMATIONS ONLY. It is NOT a medical device. Do not use for dosing decisions without professional medical advice. Are you sure?")) {
                return;
            }
        }

        setFormData(prev => ({ ...prev, [name]: val }));
    };

    const handleSave = () => {
        updateSettings(formData);
        alert('Settings Saved');
    };

    return (
        <div className="container animate-fade-in">
            <h1 className="mb-4">Settings</h1>

            <div className="card">
                <h3>User Profile</h3>
                <p className="text-muted mb-4">Edit your age, weight, and goals.</p>
                <button className="btn btn-secondary w-full" onClick={() => navigate('/profile')}>
                    Edit Profile
                </button>
            </div>

            <div className="card">
                <h3>Google AI API Key</h3>
                <p className="text-muted text-sm mb-4">
                    Required for AI features. Get one at <a href="https://aistudio.google.com/app/apikey" target="_blank" rel="noreferrer">Google AI Studio</a>.
                    Usage incurs calls on your personal account.
                </p>
                <div className="input-group">
                    <input
                        type="password"
                        name="apiKey"
                        value={formData.apiKey}
                        onChange={handleChange}
                        placeholder="Paste your API Key here"
                    />
                </div>
                <div className="input-group">
                    <label>AI Model Name</label>
                    <input
                        type="text"
                        name="aiModel"
                        value={formData.aiModel || 'gemini-2.0-flash-exp'}
                        onChange={handleChange}
                        placeholder="e.g., gemini-1.5-flash"
                    />
                    <p className="text-muted text-xs mt-1">
                        Try "gemini-2.0-flash-exp", "gemini-1.5-flash", or "gemini-1.5-pro".
                    </p>
                </div>
            </div>

            <div className="card">
                <h3>AI Display Preferences</h3>
                <div className="input-group flex items-center gap-2">
                    <input
                        type="checkbox"
                        name="showMacros"
                        checked={formData.showMacros}
                        onChange={handleChange}
                        style={{ width: 'auto' }}
                    />
                    <label className="mb-0">Show Macronutrients (P/C/F)</label>
                </div>

                <div className="input-group flex items-center gap-2">
                    <input
                        type="checkbox"
                        name="showGI"
                        checked={formData.showGI}
                        onChange={handleChange}
                        style={{ width: 'auto' }}
                    />
                    <label className="mb-0">Show Glycemic Index (Estimated)</label>
                </div>
            </div>

            <div className="card">
                <h3>Diabetic Mode</h3>
                <div className="input-group flex items-center gap-2">
                    <input
                        type="checkbox"
                        name="diabeticMode"
                        checked={formData.diabeticMode}
                        onChange={handleChange}
                        style={{ width: 'auto' }}
                    />
                    <label className="mb-0">Enable Diabetic Mode</label>
                </div>

                {formData.diabeticMode && (
                    <div className="pl-6 animate-fade-in">
                        <div className="input-group">
                            <label>Insulin Ratio (e.g. "1:10" or "1 unit per 10g")</label>
                            <input
                                type="text"
                                name="insulinRatio"
                                value={formData.insulinRatio}
                                onChange={handleChange}
                                placeholder="1 unit per 10g carbs"
                            />
                        </div>
                        <div className="input-group flex items-center gap-2">
                            <input
                                type="checkbox"
                                name="showInsulin"
                                checked={formData.showInsulin}
                                onChange={handleChange}
                                style={{ width: 'auto' }}
                            />
                            <label className="mb-0">Show Estimated Insulin</label>
                        </div>
                    </div>
                )}
            </div>

            <div className="card">
                <h3>Allergens</h3>
                <div className="input-group">
                    <label>List allergens separated by commas</label>
                    <input
                        type="text"
                        name="allergens"
                        value={formData.allergens}
                        onChange={handleChange}
                        placeholder="Peanuts, Shellfish, Gluten..."
                    />
                </div>
            </div>

            <button className="btn btn-primary w-full" onClick={handleSave}>
                Save Settings
            </button>

            <div className="text-center mt-8 text-muted text-xs">
                MealTracking App - Local Storage Version v1.0
            </div>
        </div>
    );
}
