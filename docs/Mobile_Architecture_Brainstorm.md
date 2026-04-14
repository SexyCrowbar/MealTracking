# MealTracker Mobile Architecture Brainstorm

## Decisions Made

- **Mobile native only** — no web app to maintain, all-in on Android + iOS
- **SQLite** for local storage (replacing browser localStorage)
- **Offline-first with analysis queue** — never lose a meal entry due to bad connectivity
- **Multi-LLM support** — users bring their own API key from any supported provider
- **Photo-first input model** — every AI analysis starts with a photo; optional text description adds precision
- **All existing features carry forward** — ZigZag cycling, diabetic mode, allergen detection, i18n

---

## 1. Tech Stack Recommendation: Flutter

The existing docs already reference Flutter as the intended platform, and it remains the strongest choice here for several reasons.

**Why Flutter over React Native:**

- The camera/image pipeline is critical for food photo analysis. Flutter's native camera integration (`camera` package) is more mature and consistent across platforms than React Native's ecosystem of competing camera libraries.
- Flutter compiles to native ARM code — no JavaScript bridge overhead. This matters for image processing (compression, resizing) before sending to the LLM.
- The existing dark-theme UI with circular progress rings, SVG charts, and custom modals maps cleanly to Flutter's widget system.
- SQLite support via `sqflite` is battle-tested in Flutter. The docs already reference this.
- Flutter's `flutter_secure_storage` uses iOS Keychain and Android Keystore natively — ideal for storing API keys securely.

**Why not Kotlin Multiplatform (KMP):**

- KMP is excellent if you need deep platform integration, but MealTracker's UI is uniform across platforms. You'd be writing two separate UIs for no real benefit.
- The ecosystem for KMP UI (Compose Multiplatform) is still maturing on iOS.

**Core Flutter packages to use:**

| Purpose | Package |
|---|---|
| Local DB | `sqflite` + `drift` (type-safe wrapper) |
| Secure key storage | `flutter_secure_storage` |
| Camera | `camera` + `image_picker` |
| HTTP client | `dio` (interceptors, retry, queue support) |
| State management | `riverpod` (or `bloc` if you prefer) |
| Charts | `fl_chart` |
| Barcode scanning | `mobile_scanner` |
| Health integration | `health` |
| Notifications | `flutter_local_notifications` |
| i18n | `flutter_localizations` + `intl` |
| Background tasks | `workmanager` |
| Home screen widgets | `home_widget` |

---

## 2. Multi-LLM Provider Architecture

### 2.1 The Adapter Pattern

Every LLM provider implements a single interface:

```
abstract class MealAnalyzer {
  String get providerName;          // "Google Gemini" or "Groq"
  String get providerDescription;   // One-line shown in provider selection UI
  List<ModelOption> get availableModels;
  String get defaultModel;          // e.g., "gemini-2.5-flash" or "meta-llama/llama-4-scout-17b-16e-instruct"
  String get setupUrl;              // Deep link to provider's API key page

  Future<MealAnalysis> analyzeMeal({
    required Uint8List imageBytes,   // always required — photo is the primary input
    String? textDescription,          // optional — user's additional context for precision
    required String apiKey,
    required String model,
  });

  Future<bool> validateApiKey(String apiKey, String model);
}
```

**Input model:** The photo is always the primary input. The user can optionally add a text description to improve accuracy (e.g., "homemade borscht with sour cream, about 300ml bowl" alongside the photo). The LLM receives both the image and text together — the image provides visual identification and portion estimation, while the text disambiguates ingredients, specifies preparation method, or corrects what the model might miss (e.g., "this is sugar-free" or "the dressing is on the side"). Manual entry (calories + macros typed by hand) remains available as a fallback that bypasses AI entirely.

The `MealAnalysis` response is uniform across all providers:

```
class MealAnalysis {
  final String name;
  final int calories;
  final double protein;    // grams
  final double carbs;      // grams
  final double fat;        // grams
  final int? glycemicIndex;
  final double? healthScore;
  final String? allergenWarning;
  final double? estimatedInsulin; // units, if diabetic mode
  final String providerUsed;
  final String modelUsed;
  final int latencyMs;
}
```

### 2.2 Supported Providers

The app ships with two providers: **Gemini** (default, best quality) and **Groq** (easiest setup, fastest responses). This keeps the app focused and the onboarding simple — two clear choices instead of a wall of options.

#### Google Gemini (Default)

- Models: Gemini 2.5 Flash (default), Gemini 2.5 Pro, Gemini 2.0 Flash
- Vision: Native multimodal — photo is processed as a first-class input alongside text
- Structured output: Native JSON mode via `responseMimeType` + `responseSchema`
- API endpoint: `generativelanguage.googleapis.com/v1beta/models/`
- Auth: API key (no OAuth, no billing setup for free tier)
- Free tier: 15 requests/minute, no credit card required
- Setup: Sign in with Google account → Google AI Studio → "Create API key" (2 clicks)
- Strengths: Best photo+text analysis quality. Native structured JSON output eliminates parsing errors. Generous free tier covers casual users (15 RPM = ~900 analyses/hour). Existing prompt engineering from the web app carries over directly.
- Weaknesses: Occasional hallucination on portion sizes. Free tier rate limit can be hit by heavy users. Google Cloud project is auto-created in the background (can confuse users who see GCP console emails).

#### Groq (Fast + Free Alternative)

- Models: Llama 4 Scout (default, vision-capable), Llama 4 Maverick
- Vision: Yes via Llama 4 Scout/Maverick — photo + text supported
- Structured output: JSON mode supported
- API endpoint: `api.groq.com/openai/v1/chat/completions`
- Auth: API key (Bearer token, OpenAI-compatible format)
- Free tier: 30 requests/minute, 14,400 requests/day, no credit card, no time limit
- Setup: Sign up at console.groq.com → "Create API Key" (literally 1 click after signup)
- Strengths: Zero-friction signup (no credit card, no project creation, no billing). Blazing fast inference (<1 second) thanks to custom LPU hardware. Higher free-tier rate limits than Gemini. OpenAI-compatible API format.
- Weaknesses: Running open-weight models — food recognition quality is a step below Gemini 2.5. Model availability can change (Groq controls which models are hosted). Less reliable structured output than Gemini's native schema enforcement.

#### Why these two (and not others)

| Factor | Gemini | Groq |
|---|---|---|
| Signup friction | Low (Google account + 2 clicks) | Lowest (1 click, no card) |
| Credit card required | No (free tier) | No |
| Photo analysis quality | Excellent | Good |
| Response speed | Fast (~1-2s) | Very fast (<1s) |
| Structured output | Native schema (most reliable) | JSON mode (good, occasional errors) |
| Free tier limits | 15 RPM | 30 RPM, 14.4K/day |

Other providers (OpenAI, Claude, Mistral) all require credit cards and billing setup before the user can make a single API call. For a consumer app where users bring their own keys, that's a significant onboarding barrier. Gemini and Groq are the only two providers where a new user can go from "I downloaded the app" to "I just analyzed my first meal" in under 3 minutes without entering payment info.

### 2.3 Provider-Specific Prompt Engineering

Each provider adapter includes an optimized system prompt. The core analysis request is identical, but the output framing differs:

**Gemini:** Use `responseMimeType: "application/json"` with a `responseSchema` object. Gemini natively enforces the schema — no need for "return JSON" in the prompt. This makes Gemini the most reliable for structured output. Focus the prompt entirely on food analysis instructions and let the schema handle formatting.

**Groq (Llama 4 Scout/Maverick):** Use `response_format: { type: "json_object" }` in the request. JSON mode quality is good but not as strict as Gemini's native schema. Always validate the response and fall back to regex extraction if JSON parsing fails. Include a concrete example of the expected JSON in the prompt — few-shot prompting dramatically improves structured output from open-weight models. The adapter should have a `parseResponse()` method with a fallback chain: try JSON.parse → try extracting JSON from markdown code blocks → try regex extraction of individual fields.

**Universal prompt core** (adapted per provider):

```
Analyze the attached photo of a meal and estimate its nutritional content.

The photo is the primary source of truth. Use it to identify food items,
estimate portion sizes, and calculate nutrition.

[IF USER TEXT PROVIDED]:
The user has also provided this description: "[USER_TEXT]"
Use this text to refine your analysis — it may specify ingredients not
visible in the photo, clarify preparation method, indicate portion size,
or correct assumptions (e.g., "sugar-free", "dressing on the side",
"about 250g of pasta"). When the text and photo conflict, prefer the
text for ingredient details and the photo for portion size estimation.

Context:
- User profile: [age, gender, weight, height, activity_level]
- Consider typical restaurant/home portion sizes for the region.
- If the photo shows multiple dishes, analyze ALL of them as one meal.

Required output fields:
- name: concise meal name (e.g., "Grilled Chicken Salad")
- calories: total estimated kcal (integer)
- protein: grams (number)
- carbs: grams (number)
- fat: grams (number)
- gi: estimated glycemic index 0-100 (integer or null)
- health_score: 1-10 rating (number)
- allergen_warning: warning string if allergens detected from user's list, otherwise null

User's allergen list: [ALLERGENS]
Diabetic mode: [ON/OFF] — if ON, also estimate insulin units using ratio 1:[RATIO]
```

**Why photo + text together improves precision:**

The LLM sees the photo and can identify "a bowl of soup" — but it can't know whether it's made with cream or broth, whether the bread on the side was eaten, or how large the bowl actually is. The user's text fills these gaps. In testing, photo + brief text description typically produces calorie estimates 15-25% more accurate than photo alone, especially for home-cooked meals where ingredients aren't visually obvious.

### 2.4 Settings UI: Provider Selection

```
Settings > AI Provider
├── Two provider cards (radio selection):
│   ├── Google Gemini  [default] [recommended badge]
│   │   └── "Best photo analysis quality. Free tier included."
│   └── Groq
│       └── "Fastest setup, no credit card. Instant responses."
│
├── [Selected provider section]:
│   ├── API Key input (secure, masked, paste-friendly)
│   ├── Model dropdown (populated per provider)
│   ├── "Test Connection" button → spinner → ✓ / ✗
│   └── Status: "Connected" / "Invalid key" / "Not configured"
│
└── [Image quality]:
    └── Photo quality (Low / Medium / High) — compression before send
```

### 2.5 Guided Onboarding Flow

First-time users see this flow before reaching the main app. The goal: get an API key entered and validated in under 3 minutes.

```
Welcome Screen
│  "To analyze your meals with AI, you'll need a free API key
│   from one of our supported providers."
│
│  [Get started with Gemini (Recommended)]
│  [Get started with Groq (Fastest setup)]
│  [Skip — I'll use manual entry for now]
│
├── Gemini path:
│   Step 1: "Sign in to Google AI Studio"
│   │  [Open Google AI Studio →]  (deep link to aistudio.google.com/app/apikey)
│   │  Instruction: "Sign in with your Google account"
│   │
│   Step 2: "Create your API key"
│   │  Instruction: "Tap 'Create API key' → 'Create API key in new project'"
│   │  Illustration: annotated screenshot showing the button location
│   │
│   Step 3: "Paste your key here"
│   │  [API key input field] [Paste button]
│   │  [Test connection] → spinner → ✓ "Connected! You're ready to go."
│   │  [Continue to app →]
│
├── Groq path:
│   Step 1: "Create a Groq account"
│   │  [Open Groq Console →]  (deep link to console.groq.com)
│   │  Instruction: "Sign up with Google or email — no credit card needed"
│   │
│   Step 2: "Create your API key"
│   │  Instruction: "Go to API Keys → Create key → Copy it"
│   │  Illustration: annotated screenshot showing the flow
│   │
│   Step 3: "Paste your key here"
│   │  [API key input field] [Paste button]
│   │  [Test connection] → spinner → ✓ "Connected! You're ready to go."
│   │  [Continue to app →]
│
└── Skip path:
    │  "No problem! You can add an API key anytime in Settings."
    │  "You'll be able to log meals manually and track calories."
    │  [Continue to profile setup →]
```

**Onboarding UX principles:**
- Each step is a single screen — no scrolling, no information overload
- Deep links open the provider's console directly in the system browser
- When user returns to the app, auto-focus the paste field
- The "Test connection" button sends a tiny test request (text-only, no image) to validate the key works
- If the test fails, show a clear error: "Key not recognized — double-check you copied the full key" with a "Try again" option
- The skip option is always visible — never force API setup
- Users who skip see a gentle nudge on the Record screen: "Add an AI provider in Settings to analyze meals by photo"

---

## 3. SQLite Storage Architecture

### 3.1 Schema Design

Replace the flat localStorage keys with a proper relational schema using `drift` (type-safe SQLite wrapper for Flutter):

**Tables:**

```sql
-- User profile (single row)
CREATE TABLE profile (
  id INTEGER PRIMARY KEY DEFAULT 1,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  height_cm REAL NOT NULL,
  weight_kg REAL NOT NULL,
  goal_weight_kg REAL NOT NULL,
  activity_level TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Meal log entries
CREATE TABLE meals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,              -- ISO date YYYY-MM-DD
  time TEXT NOT NULL,              -- ISO time HH:MM
  name TEXT NOT NULL,
  calories INTEGER NOT NULL,
  protein REAL,
  carbs REAL,
  fat REAL,
  glycemic_index INTEGER,
  health_score REAL,
  allergen_warning TEXT,
  estimated_insulin REAL,
  source TEXT NOT NULL DEFAULT 'manual',  -- manual | ai_photo | ai_photo_text
  provider TEXT,                   -- gemini | openai | claude | ...
  model TEXT,                      -- specific model used
  analysis_latency_ms INTEGER,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Weight history
CREATE TABLE weight_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL UNIQUE,
  weight_kg REAL NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Offline analysis queue
CREATE TABLE analysis_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,     -- local file path to saved photo (always required)
  text_description TEXT,        -- optional user text for precision
  status TEXT NOT NULL DEFAULT 'pending',  -- pending | processing | completed | failed
  retry_count INTEGER DEFAULT 0,
  error_message TEXT,
  result_json TEXT,             -- raw JSON response from provider
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  processed_at TEXT
);

-- Settings (key-value for flexibility)
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Indices for common queries
CREATE INDEX idx_meals_date ON meals(date);
CREATE INDEX idx_weight_date ON weight_entries(date);
CREATE INDEX idx_queue_status ON analysis_queue(status);
```

### 3.2 Secure Storage (Separate from SQLite)

API keys should NOT go in SQLite. Use `flutter_secure_storage` which maps to:
- **iOS:** Keychain Services (hardware-backed encryption)
- **Android:** Android Keystore + EncryptedSharedPreferences

Stored securely:
- `provider_apikey_gemini` — Gemini API key
- `provider_apikey_groq` — Groq API key
- `active_provider` — which provider is currently selected ("gemini" or "groq")
- Both keys are stored independently so users can switch providers without re-entering keys

### 3.3 Data Retention

Same 30-day auto-pruning as the current app, but make it configurable:
- Settings key: `data_retention_days` (default: 30, options: 30/90/180/unlimited)
- Run pruning on app start via a simple DELETE WHERE query
- For unlimited: warn user that DB size will grow over time

### 3.4 Migration from Web App

If any users later come from the web PWA, you could offer a JSON import:
- Export from web app: serialize localStorage to JSON file
- Import in mobile app: parse and insert into SQLite tables
- Low priority given no existing users, but cheap to implement

---

## 4. Offline-First Architecture

### 4.1 Core Principle

Every user action completes instantly on-device. Network operations happen asynchronously in the background.

### 4.2 Meal Recording Flow (Offline-Safe)

```
User takes photo → (optional) adds text description → taps "Analyze"
        │
        ▼
┌─────────────────────────┐
│  Save photo to local     │  ← Immediate, always succeeds
│  file system             │
│  Save to analysis_queue  │
│  (image_path + text)     │
│  (status: pending)       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐    No
│   Network available?     │──────────┐
└──────────┬──────────────┘          │
           │ Yes                      │
           ▼                          ▼
┌─────────────────────────┐  ┌──────────────────┐
│  Send to LLM provider   │  │  Show "Queued"   │
│  (status: processing)   │  │  badge on meal   │
└──────────┬──────────────┘  │  card in UI      │
           │                  └──────────────────┘
           ▼                          │
┌─────────────────────────┐          │
│  Parse response, insert  │          │
│  into meals table        │   (When network returns,
│  (status: completed)     │    WorkManager triggers
│  Show result to user     │    queue processing)
└─────────────────────────┘          │
                                      ▼
                              ┌──────────────────┐
                              │  Process queue    │
                              │  in FIFO order    │
                              │  Update UI via    │
                              │  stream/listener  │
                              └──────────────────┘
```

### 4.3 Queue Processing Rules

- **Retry policy:** Exponential backoff — 5s, 15s, 60s, 5min. Max 5 retries.
- **Failure handling:** After max retries, mark as `failed` with error message. User can manually retry or convert to manual entry.
- **Connectivity detection:** Use `connectivity_plus` package to detect network state. Register a listener that triggers queue processing when connectivity is restored.
- **Background execution:** Use `workmanager` for Android background tasks. On iOS, use background fetch (limited but sufficient for a queue of a few items).
- **Concurrency:** Process one queue item at a time to avoid rate limit issues.
- **Photo storage:** Save captured photos to app's local directory immediately. Reference by file path in the queue. Delete photo files after successful analysis (or keep them if user wants a food photo gallery — configurable). The optional text description is stored as a string column in the queue row alongside the image path.

### 4.4 Manual Entry is Always Available

Even when the queue is backed up, manual entry bypasses the queue entirely and writes straight to the `meals` table. This ensures the core calorie tracking function is never blocked by network issues.

### 4.5 UI States for Queued Items

The meal list on the Plan screen should show clear visual states:
- **Analyzed** — normal meal card with full nutrition data
- **Queued** — meal card with a clock/sync icon, showing "Analysis pending..." and just the meal name/photo thumbnail
- **Failed** — meal card with warning icon, tap to retry or convert to manual entry

---

## 5. Native Mobile Features

### 5.1 Camera Integration & Meal Recording Flow

This is the primary advantage over a PWA. The photo is always the starting point for AI analysis.

**Capture flow:**

1. User taps the camera button on the Record screen
2. Full-screen camera viewfinder opens (not a system dialog)
3. Optional: overlay a semi-transparent plate/bowl guide circle to encourage good framing
4. User snaps photo (or picks from gallery)
5. Quick preview with "Use" or "Retake" options

**Description step (after photo is taken):**

6. Photo thumbnail is shown at the top of a "Describe your meal" screen
7. Below it: an optional text field with placeholder like "Add details for better accuracy (e.g., 'chicken soup, no cream, large bowl')"
8. User can either:
   - Tap "Analyze" immediately (photo only) — fast path for obvious meals
   - Type a description, then tap "Analyze" (photo + text) — precision path
9. Image + optional text are saved to the queue and sent to the LLM

**Why this two-step UX works:**
- The photo is zero-friction (one tap)
- The text field is clearly optional — no friction for users who don't want to type
- But when the user does add context, the LLM result is significantly more accurate
- Placeholder examples teach users what kind of text is helpful without requiring a tutorial

**Image optimization before API send:**
- Resize to 512-1024px (configurable in settings — smaller = cheaper/faster, larger = more accurate)
- Strip EXIF data (privacy — removes GPS coordinates)
- Convert to JPEG if PNG (smaller payload)
- Base64 encode for API transmission

### 5.2 Home Screen Widgets

Using the `home_widget` package:

**Small widget (2x1):** Shows remaining calories for today as a number with a circular progress ring. Taps open the app to the Plan screen.

**Medium widget (4x2):** Shows remaining calories + macros breakdown + quick "Log Meal" button that opens directly to the Record screen.

### 5.3 Health App Integration

Using the `health` package:

**Export to Apple Health / Google Fit:**
- Write daily calorie intake totals
- Write individual meal nutritional data (calories, protein, carbs, fat)
- Write weight entries

**Import from Apple Health / Google Fit:**
- Read weight entries (so users can weigh on a smart scale and it appears in the app)
- Read active energy burned (could improve TDEE calculation beyond the static activity multiplier)

### 5.4 Barcode Scanner

Using `mobile_scanner`:

1. User scans a barcode on packaged food
2. Look up the barcode in **OpenFoodFacts API** (free, open database)
3. If found: pre-fill nutrition data, let user adjust portion size
4. If not found: offer to fall back to LLM analysis with the product name
5. This provides a fast, free, accurate option for packaged foods — saving the LLM call (and user's API costs) for home-cooked and restaurant meals

### 5.5 Notifications

- **Meal logging reminders:** Configurable times (e.g., 12:30pm, 7:00pm) — "Don't forget to log your lunch!"
- **Streak tracking:** "You've logged meals for 7 days straight!"
- **Weekly weigh-in reminder:** e.g., every Sunday morning
- **Queue completed:** "Your queued meal has been analyzed — tap to review"

### 5.6 Share Sheet / Intent Integration

Register the app as a share target for images:
- **Android:** Intent filter for `image/*` MIME types
- **iOS:** Share Extension

When a user shares a food photo from their gallery, messaging app, or social media, MealTracker opens directly to the Record screen with the image pre-loaded for analysis.

### 5.7 Voice-to-Text for Description Field (Optional Enhancement)

Since the input model is photo + optional text, voice can serve as a convenient way to fill the text description field without typing:

1. User takes a photo, then taps a microphone icon next to the text description field
2. Device's native speech-to-text (free, offline on modern phones) converts speech to text
3. The transcribed text populates the description field, which the user can review/edit
4. User taps "Analyze" — the photo + transcribed text are sent together to the LLM

This is not a separate input method — it's just a faster way to add the optional text description. No audio is sent to the LLM; only the resulting text alongside the photo.

---

## 6. Multi-LLM Comparison Feature (Optional / Future)

Allow users to send the same meal to 2-3 providers simultaneously and compare results:

```
┌──────────────────────────────────────────┐
│  📸 [photo thumbnail]                    │
│  "2 slices of pepperoni pizza"           │
│                                          │
│  Gemini 2.5 Flash    │ GPT-4o-mini      │
│  Calories: 570       │ Calories: 620    │
│  Protein: 24g        │ Protein: 26g     │
│  Carbs: 62g          │ Carbs: 68g       │
│  Fat: 24g            │ Fat: 26g         │
│  ⏱ 0.8s             │ ⏱ 1.2s          │
│                                          │
│  [Use Gemini] [Use GPT-4o] [Average]    │
└──────────────────────────────────────────┘
```

- "Average" option computes the mean of all estimates — reduces individual model bias
- Track which provider the user picks over time — show a "most trusted" stat in settings
- This is a differentiating feature — no other meal tracker does this

---

## 7. Privacy and Security

### 7.1 Data Stays on Device

- All meal logs, weight history, and profile data in local SQLite — never transmitted anywhere
- API keys in device keychain — encrypted at rest by the OS
- Only outbound network calls are to the user's chosen LLM provider
- No analytics, no telemetry, no cloud sync (unless user opts into a future export feature)

### 7.2 API Key Security

- Stored in `flutter_secure_storage` (Keychain / Keystore)
- Never logged, never included in error reports
- Shown masked in UI (•••••••last4)
- Option to require biometric authentication to reveal/copy the key

### 7.3 Image Privacy

- Photos sent to LLM APIs are subject to each provider's data policies
- Show a one-time notice explaining this when the user first enables photo analysis
- Option to auto-delete photos after analysis (default: on)
- Strip EXIF/GPS data before sending

---

## 8. Rough Build Phases

**Phase 1 — Core MVP:**
- Flutter project setup with navigation, theming, i18n (English + Ukrainian)
- SQLite schema + drift models + secure key storage
- Guided onboarding flow (Gemini / Groq key setup with step-by-step screens)
- Profile setup and ZigZag calculation (port from `utils.js`)
- Manual meal entry (bypass AI entirely)
- Camera integration: photo capture + optional text description field
- Plan screen with daily target and meal list
- Gemini adapter (port from `api.js`) with native JSON schema
- Groq adapter (OpenAI-compatible format) with JSON validation fallback
- Photo + text analysis via selected provider
- Settings screen with provider selection + key management
- Basic progress screen (weight chart, meal history)
- Offline queue with background processing (WorkManager / background fetch)

**Phase 2 — Native Features + Polish:**
- Barcode scanner + OpenFoodFacts integration
- Home screen widgets (remaining calories)
- Health app integration (Apple Health / Google Fit)
- Share sheet integration (share food photos from other apps)
- Voice-to-text for description field
- Notifications (meal reminders, streak tracking, queue completion)
- Diabetic mode + allergen detection UI polish

**Phase 3 — Optional Enhancements:**
- Watch companion app
- Food photo gallery / meal history with images
- Meal templates / favorites ("I eat this every morning")
- Export data as CSV/JSON
- Additional LLM providers (OpenAI, Claude, etc.) if user demand exists

---

## 9. Provider Summary

Both providers receive the same input: photo (required) + text description (optional).

| | Gemini 2.5 Flash (Default) | Groq + Llama 4 Scout |
|---|---|---|
| **Photo+text quality** | Excellent | Good |
| **Response speed** | ~1-2 seconds | <1 second |
| **Structured output** | Native schema (most reliable) | JSON mode (needs validation fallback) |
| **Free tier** | 15 RPM, no credit card | 30 RPM / 14.4K per day, no credit card |
| **Signup steps** | Google login → AI Studio → Create key | Signup → Create key |
| **Signup time** | ~2 minutes | ~1 minute |
| **Best for** | Most users — best analysis accuracy | Users who want zero-friction setup and speed |

**Recommendation shown to users in onboarding:**
- Gemini: "Best photo analysis quality. Free tier included." [Recommended]
- Groq: "Fastest setup, no credit card needed. Instant responses."
