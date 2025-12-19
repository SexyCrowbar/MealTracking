# AI Weight Loss Assistant - App Documentation (Local Storage Version)

## Purpose

This application assists users in achieving their weight loss goals by leveraging a structured diet plan (ZigZag method) and AI-powered calorie estimation features. It is designed as a **completely local application**, storing all user data securely on the device.

## Core Concepts

* **Diet Method:** Utilizes the ZigZag calorie cycling method, providing different calorie targets for workout days and rest days based on user profile and goals, calculated locally.
* **Local Storage:** All application data, including user profiles, meal logs, progress history, settings, and the user's Google AI API key, is stored securely **only** on the user's device. There is **no cloud synchronization**.
* **AI Functionality:** AI features (meal analysis from text, photo, or audio) are available **only** if the user provides their own valid Google AI API key in the settings. The app does not provide any AI functionality using developer resources.
* **Configurable AI Output:** The nutritional information provided by the AI is configurable:
    * Calories are shown by default.
    * Macronutrients (Protein, Carbs, Fat), Glycemic Index (Estimated), and Estimated Insulin (for diabetics) can be toggled on/off in settings.
* **Allergen Detection:** Users can input a list of allergens. The AI (when enabled) will attempt to detect the presence of these allergens in analyzed meals and warn the user.
* **Technology:** Built using Flutter for cross-platform deployment (iOS/Android) and local storage solutions (`sqflite`, `shared_preferences`, `flutter_secure_storage`). It utilizes Google AI (Gemini models) via the user's provided API key.

## Key Features

* **User Profile Setup:** Input basic physical data and goals.
* **Manual Meal Logging:** Record meals with calories and macros manually.
* **AI-Powered Meal Analysis (Requires User API Key):**
    * Estimate nutrition from **text descriptions + weight/volume**.
    * Estimate nutrition from **Photos**.
    * Estimate nutrition from **Audio** descriptions.
* **ZigZag Plan Calculation:** Calculates daily/weekly calorie and macro targets locally.
* **Progress Tracking:** Log weekly weight and view progress charts.
* **Configurable Settings:** Includes Diabetic Mode, AI output preferences, Allergen list, and API key input.
* **Secure Local Storage:** All data managed on the device.