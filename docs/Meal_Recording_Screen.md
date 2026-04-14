# Screen: Meal Recording

## Purpose

This screen allows users to log meals by taking a photo and optionally adding a text description for AI-powered nutritional analysis. Manual entry is always available as a fallback.

## Recording Flow

The recording flow has three stages: Capture, Describe, and Result.

### Stage 1: Camera Capture

**Layout:** Full-screen camera viewfinder with a semi-transparent circular plate guide to encourage good framing.

**Controls:**
- Shutter button (center) — captures photo
- Gallery button (top-right) — select a photo from the device gallery
- Flash toggle — on/off/auto
- Camera flip — front/rear

**Behavior:**
- Opens as a full-screen native camera view (not a system file picker dialog)
- After capture, shows a quick preview with "Use" and "Retake" options
- On "Use," transitions to Stage 2 (Describe)

**Image Processing (before API send):**
- Resize to max dimension based on Photo Quality setting (512px / 1024px / 2048px)
- Strip EXIF metadata including GPS coordinates (privacy)
- Convert PNG to JPEG if needed (smaller payload)
- Save to local app directory immediately (for offline queue support)

### Stage 2: Describe (After Photo)

**Layout:**
- Photo thumbnail displayed at the top of the screen
- "Photo ready" badge on thumbnail
- Optional text input field below with placeholder: "Add details for better accuracy (e.g., 'chicken soup, no cream, large bowl')"
- Microphone icon next to text field — taps to activate device speech-to-text for hands-free dictation into the text field
- Tips card showing examples of helpful descriptions

**Tips shown to user:**
- Mention hidden ingredients ("no cream", "sugar-free")
- Estimate portion size ("large bowl", "~250g")
- Specify cooking method ("fried", "steamed")

**Actions:**
- "Analyze with [Provider]" button — sends photo + optional text to the selected AI provider
- "Enter calories manually instead" — skips AI, opens manual entry fields

**Behavior:**
- User can tap "Analyze" immediately (photo only) for fast path
- Or type/dictate a description, then tap "Analyze" (photo + text) for precision path
- On tap: photo + text are saved to the `analysis_queue` table in SQLite and processing begins
- If offline: shows "Queued" state, meal appears on Plan screen with pending badge

### Stage 3: AI Result Display

**Layout:**
- Photo thumbnail with meal name identified by AI
- Provider and model used, response latency
- Large calorie number (primary metric)
- Macro breakdown bar: Protein, Carbs, Fat
- Additional fields (conditionally shown based on Settings toggles):
  - Glycemic Index (estimated) — shown if GI toggle is ON
  - Health Score (1-10)
  - Allergen Warning — if allergens detected from user's configured list, shown as prominent warning: "⚠️ High risk of [Allergen Name] detected!"
  - Estimated Insulin — shown if Diabetic Mode is ON and insulin toggle is ON

**Editability:** All values are tappable to adjust before saving. This lets users correct the AI's estimate if they know it's wrong (e.g., the AI estimated 400 kcal but the user knows the portion was smaller).

**Actions:**
- "Save to Today's Log" — inserts the meal into the `meals` SQLite table
- "Discard" — deletes the queued item and photo

## Manual Entry (Fallback)

Always available regardless of AI provider configuration.

**Fields:**
- Food Description (text, required)
- Calories (kcal, required)
- Protein (g, optional)
- Carbohydrates (g, optional)
- Fat (g, optional)

**Behavior:** Writes directly to the `meals` table — bypasses the analysis queue entirely. No network required.

## Offline Behavior

When the device is offline at the time of analysis:
- Photo is already saved to local storage
- Text description is stored in the `analysis_queue` table
- Queue item status is set to `pending`
- Meal appears on the Plan screen with a clock/sync icon and "Analysis pending..." label
- When connectivity returns, `workmanager` processes the queue in FIFO order
- On completion, the meal card updates with full nutrition data and a notification is shown

## Barcode Scanning (Phase 2)

An additional entry point for packaged foods:
- User taps barcode icon → camera opens in scanner mode
- Barcode is looked up in the OpenFoodFacts API (free, open database)
- If found: nutrition data is pre-filled, user adjusts portion size and saves
- If not found: falls back to photo + text analysis with the product name as text

## Data Storage

- Meal entries are stored in the `meals` table in SQLite with fields: date, time, name, calories, protein, carbs, fat, glycemic_index, health_score, allergen_warning, estimated_insulin, source (manual / ai_photo / ai_photo_text), provider, model, analysis_latency_ms
- Queued analyses are stored in the `analysis_queue` table with fields: image_path (NOT NULL), text_description (nullable), status, retry_count, error_message, result_json

## Access

Accessible via the "Record" tab in the bottom navigation bar (second tab, plus icon).
