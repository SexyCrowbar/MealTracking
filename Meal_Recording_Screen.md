# Screen: Meal Recording

## Purpose

This screen allows users to log the meals they consume, tracking their calorie and macronutrient intake either manually or using AI assistance (if configured).

## Input Methods

1.  **Manual Entry:**
    * **Fields:** Food Description, Calories (kcal), Protein (g), Carbohydrates (g), Fat (g).
    * **Availability:** Always available.
2.  **Text Description + Weight/Volume (AI - Requires User API Key):**
    * **Field:** Text area for describing the meal.
    * **Functionality:** Sends text to the AI (using user's key) for analysis.
    * **Availability:** Enabled only if user API key is provided in Settings.
3.  **Photo Input (AI - Requires User API Key):**
    * **Trigger:** Button with camera/photo icon.
    * **Functionality:** Launches camera/gallery; sends image to AI (using user's key).
    * **Availability:** Enabled only if user API key is provided in Settings.
4.  **Audio Input (AI - Requires User API Key):**
    * **Trigger:** Button with microphone icon.
    * **Functionality:** Records audio; sends data/transcript to AI (using user's key).
    * **Availability:** Enabled only if user API key is provided in Settings.

## AI Result Display (When AI is used)

* **Calories:** Always shown by default.
* **Macronutrients (Protein, Carbs, Fat):** Displayed only if the corresponding toggle is ON in Settings > AI Display Preferences.
* **Glycemic Index (Estimated):** Displayed only if the corresponding toggle is ON in Settings.
* **Estimated Insulin:** Displayed only if Diabetic Mode is ON, a ratio is set, AND the corresponding toggle is ON in Settings.
* **Allergen Warning:** If the AI analysis flags a high risk for an allergen specified in the user's Settings, a prominent warning is displayed: `⚠️ High risk of [Allergen Name] detected!`

## Functionality

* **Data Logging:** Adds the entered or AI-estimated nutritional information as a meal log entry.
* **Storage:** Saves logs **only locally** on the device (e.g., `sqflite`).
* **Diabetic Mode Integration:** If enabled, calculates and displays estimated insulin units based on logged carbs and the user's ratio (calculation happens locally).

## Access

* Typically accessible via a main navigation tab, a floating action button, or similar.