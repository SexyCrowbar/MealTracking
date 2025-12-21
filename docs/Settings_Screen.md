# Screen: Settings

## Purpose

This screen provides access to user profile editing, AI configuration, and other application settings. All settings are stored locally.

## Sections

1.  **Profile:**
    * **Action:** Navigate to the "User Info / Profile" screen to view or edit personal details.
2.  **Google AI API Key:**
    * **Input Field:** Allows users to paste their personal Google AI API key to enable all AI features.
    * **Model Selection:** Dropdown to select preferred Gemini model (e.g., "Gemini 2.5").
    * **Actions:** Buttons to "Save Key" and "Clear Key".
    * **Note:** Explains that AI features require a valid key and that usage incurs costs on the user's Google AI account.
3.  **AI Display Preferences:**
    * **Toggle:** "Show Macronutrients in AI results" (Default: Off).
    * **Toggle:** "Show Glycemic Index (Estimated) in AI results" (Default: Off). May include a small note about estimation accuracy.
    * **Toggle:** "Show Estimated Insulin in AI results" (Default: Off).
        * *Condition:* This toggle is only enabled if "Diabetic Mode" is ON *and* the Insulin:Carb Ratio is configured.
        * *Warning Logic:* When this toggle is switched ON, a one-time modal dialog must be displayed, warning the user that this is not medical advice and should not be solely relied upon.
4.  **Diabetic Mode:**
    * **Toggle:** Enable or disable Diabetic Mode features.
    * **Input Field (Conditional):** Appears if Diabetic Mode is ON, for user's Insulin-to-Carbohydrate ratio (e.g., "1 unit per X grams of carbs").
5.  **Allergens:**
    * **Text Input Field:** Allows the user to enter a list of their allergens (e.g., comma-separated: "Peanuts, Shellfish, Gluten, Dairy"). This list is used for AI detection.
    * **Action:** Button to save the allergen list.

## Access

* Typically accessible via a gear icon or menu item in the app's main navigation or app bar.