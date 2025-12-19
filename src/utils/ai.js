import { GoogleGenerativeAI } from "@google/generative-ai";

export async function analyzeMealWithAI(promptText, imageBase64, apiKey, settings) {
    if (!apiKey) {
        throw new Error("API Key is missing.");
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const modelName = settings.aiModel || "gemini-2.0-flash-exp";
    const model = genAI.getGenerativeModel({ model: modelName });

    let prompt = `Analyze this meal. Provide nutritional information.
  Return a JSON object with this structure:
  {
    "name": "Short food name",
    "calories": number,
    "protein": number (grams),
    "carbs": number (grams),
    "fat": number (grams)
    ${settings.showGlycemicIndex ? ', "glycemicIndex": number (estimated)' : ''}
    ${settings.showInsulin ? ', "estimatedInsulin": number (estimated units)' : ''}
    ${settings.allergens ? `, "allergenWarning": "string warning if ${settings.allergens} is detected, else null"` : ''}
  }
  
  Input Description: ${promptText || "See image."}
  `;

    // Diabetec context if useful
    if (settings.diabeticMode && settings.insulinRatio) {
        prompt += `\nUser has diabetes. Insulin Ratio: ${settings.insulinRatio}. Estimate insulin strictly based on carbs.`;
    }

    try {
        const parts = [{ text: prompt }];
        if (imageBase64) {
            // Base64 string might include "data:image/jpeg;base64," prefix, strip it if needed or API handles it?
            // GenerativeAI expects simple base64 usually
            const base64Data = imageBase64.split(',')[1] || imageBase64;
            const mimeType = imageBase64.split(';')[0].split(':')[1] || 'image/jpeg';

            parts.push({
                inlineData: {
                    data: base64Data,
                    mimeType: mimeType
                }
            });
        }

        const result = await model.generateContent(parts);
        const response = await result.response;
        const text = response.text();

        // Extract JSON
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            return JSON.parse(jsonMatch[0]);
        } else {
            throw new Error("Failed to parse AI response as JSON.");
        }

    } catch (error) {
        console.error("AI Analysis Failed:", error);
        throw error;
    }
}
