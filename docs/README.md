# MealTracker — App Documentation

## Purpose

MealTracker helps users achieve their weight loss goals by combining a structured ZigZag calorie cycling plan with AI-powered food photo analysis. Users take a photo of their meal, optionally add a text description for precision, and the AI estimates calories and macronutrients. All data stays on the device.

## Core Concepts

**Diet Method:** ZigZag calorie cycling — 5 low-calorie days and 2 high-calorie days (weekends) per week, calculated from the user's BMR/TDEE. Creates a consistent weekly deficit while preventing metabolic adaptation.

**Photo-First Input:** Every AI analysis starts with a photo. Users can optionally add a text description to improve accuracy (e.g., specifying hidden ingredients, portion sizes, or cooking methods). Manual entry (type calories + macros by hand) is always available as a fallback.

**Bring-Your-Own-Key:** AI features require the user's own API key from one of two supported providers — Google Gemini (default, best quality) or Groq (fastest setup, no credit card). The app never uses developer API resources. Guided onboarding walks first-time users through key setup in under 3 minutes.

**Local Storage:** All data (meals, weight, profile, settings) is stored in a local SQLite database on the device. API keys are stored in the device's secure keychain (iOS Keychain / Android Keystore). No cloud sync, no telemetry, no server.

**Offline-First:** Meal photos are saved to the device immediately. If the network is unavailable, analysis requests are queued and processed automatically when connectivity returns. Manual entry is always available regardless of network state.

## Supported AI Providers

**Google Gemini (Default)**
- Models: Gemini 2.5 Flash (default), Gemini 2.5 Pro, Gemini 2.0 Flash
- Free tier: 15 requests/minute, no credit card required
- Setup: Sign in with Google account at AI Studio, create API key (2 clicks)
- Strengths: Best photo+text analysis quality, native structured JSON output

**Groq (Alternative)**
- Models: Llama 4 Scout (default), Llama 4 Maverick
- Free tier: 30 requests/minute, 14,400/day, no credit card required
- Setup: Sign up at console.groq.com, create API key (1 click)
- Strengths: Sub-second responses, zero-friction signup, higher rate limits

## Key Features

- **Guided Onboarding:** 3-step setup for API key (Gemini or Groq), then profile creation
- **Photo + Text Meal Analysis:** Take a photo, optionally describe the meal, get AI-estimated nutrition
- **Manual Meal Logging:** Always available — type food name, calories, and macros directly
- **ZigZag Plan Calculation:** Daily calorie and macro targets based on user profile, with High/Low day cycling
- **Progress Tracking:** Weight history chart, 7-day calorie adherence chart, BMI display, meal history
- **Offline Queue:** Meal photos are queued for analysis when offline, processed automatically on reconnection
- **Allergen Detection:** AI warns when detected allergens match the user's configured list
- **Diabetic Mode:** Optional insulin estimation based on carbs and user's insulin-to-carb ratio
- **Configurable Display:** Toggle macronutrients, glycemic index, and insulin estimates on/off
- **Barcode Scanner:** Scan packaged food to look up nutrition via OpenFoodFacts (free database)
- **Home Screen Widgets:** Remaining calories displayed on iOS/Android home screen
- **Health App Integration:** Sync weight and calorie data with Apple Health / Google Fit
- **Share Sheet:** Share food photos from any app directly into MealTracker for analysis
- **Notifications:** Meal logging reminders, streak tracking, weekly weigh-in nudges
- **Bilingual:** English and Ukrainian (Українська)

## Technology

- **Framework:** Flutter (Dart) — single codebase for iOS and Android
- **Local Database:** SQLite via `drift` (type-safe wrapper over `sqflite`)
- **Secure Storage:** `flutter_secure_storage` (iOS Keychain / Android Keystore) for API keys
- **Camera:** `camera` + `image_picker` for photo capture and gallery selection
- **HTTP Client:** `dio` with retry and queue support for API calls
- **State Management:** `riverpod`
- **Charts:** `fl_chart` for progress visualization
- **Barcode:** `mobile_scanner` + OpenFoodFacts API
- **Health:** `health` package for Apple Health / Google Fit integration
- **Background Tasks:** `workmanager` for offline queue processing
- **Widgets:** `home_widget` for home screen calorie display
- **Notifications:** `flutter_local_notifications`
- **i18n:** `flutter_localizations` + `intl`

## Navigation

Bottom tab bar with 4 screens:

1. **Plan** — Today's calorie target, macro breakdown, meal list
2. **Record** — Camera capture, photo description, AI analysis, manual entry
3. **Progress** — Weight chart, adherence chart, meal history
4. **Settings** — Profile, AI provider, display preferences, allergens, notifications

## Data Privacy

- All meal logs, weight history, and profile data stay in local SQLite — never transmitted
- API keys are encrypted at rest in the device keychain
- Photos are stripped of EXIF/GPS data before being sent to the AI provider
- Only outbound network calls are to the user's chosen LLM provider
- No analytics, no telemetry, no ads
