import { getSettings } from './storage.js';

const API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models/';

export async function testApiKey(key, model) {
    const url = `${API_BASE_URL}${model}:generateContent?key=${key}`;
    const payload = {
        contents: [{ parts: [{ text: "Hello, are you there?" }] }]
    };

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!response.ok) throw new Error('API Request Failed');
        const data = await response.json();
        return data.candidates && data.candidates.length > 0;
    } catch (e) {
        console.error(e);
        return false;
    }
}

export async function analyzeMeal(text, imageBase64) {
    const settings = getSettings();
    if (!settings.apiKey) throw new Error('No API Key');

    const url = `${API_BASE_URL}${settings.geminiModel}:generateContent?key=${settings.apiKey}`;

    const parts = [];
    if (text) parts.push({ text: text });
    if (imageBase64) {
        // Remove data URL prefix if present for API
        const base64Data = imageBase64.split(',')[1];
        parts.push({
            inline_data: {
                mime_type: "image/jpeg",
                data: base64Data
            }
        });
    }

    // Prompt engineering
    const prompt = `Analyze this meal. Return JSON only: { "name": string, "calories": number, "protein": number, "carbs": number, "fat": number, "gi_estimate": number, "health_score": number (1-10) }. If allergens (${settings.allergens}) are detected, add "allergen_warning": string.`;
    parts.push({ text: prompt });

    const payload = {
        contents: [{ parts: parts }]
    };

    let data;
    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!response.ok) throw new Error(\`Gemini API Error: \${response.statusText}\`);
        data = await response.json();
    } catch (e) {
        console.error("API Call Failed", e);
        throw e;
    }

    if (!data.candidates || !data.candidates[0].content) {
         throw new Error("No response from AI");
    }

    // Parse JSON from markdown code block if necessary
    let resultText = data.candidates[0].content.parts[0].text;
    resultText = resultText.replace(/```json / g, '').replace(/```/g, '').trim();
        return JSON.parse(resultText);
    }
