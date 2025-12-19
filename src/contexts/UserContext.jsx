import React, { createContext, useState, useEffect, useContext } from 'react';

const UserContext = createContext();

export function useUser() {
    return useContext(UserContext);
}

const DEFAULT_PROFILE = {
    name: '',
    age: 30,
    sex: 'male',
    height: 175,
    weight: 70,
    goalWeight: 65,
    activityLevel: 'sedentary'
};

const DEFAULT_SETTINGS = {
    apiKey: '',
    showMacros: false,
    showGI: false,
    showInsulin: false,
    diabeticMode: false,
    insulinRatio: '',
    allergens: '',
    aiModel: 'gemini-2.0-flash-exp'
};

export function UserProvider({ children }) {
    const [profile, setProfile] = useState(() => {
        const saved = localStorage.getItem('user_profile');
        return saved ? JSON.parse(saved) : null; // Null means need setup
    });

    const [settings, setSettings] = useState(() => {
        const saved = localStorage.getItem('user_settings');
        return saved ? JSON.parse(saved) : DEFAULT_SETTINGS;
    });

    useEffect(() => {
        if (profile) {
            localStorage.setItem('user_profile', JSON.stringify(profile));
        }
    }, [profile]);

    useEffect(() => {
        localStorage.setItem('user_settings', JSON.stringify(settings));
    }, [settings]);

    const updateProfile = (updates) => {
        setProfile(prev => ({ ...prev, ...updates }));
    };

    const updateSettings = (updates) => {
        setSettings(prev => ({ ...prev, ...updates }));
    };

    // Helper to check if onboarding is needed
    const needsOnboarding = !profile;

    const value = {
        profile: profile || DEFAULT_PROFILE,
        settings,
        updateProfile,
        updateSettings,
        needsOnboarding,
        isInitialized: !!profile
    };

    return (
        <UserContext.Provider value={value}>
            {children}
        </UserContext.Provider>
    );
}
