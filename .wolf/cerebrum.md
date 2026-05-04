# Cerebrum

> OpenWolf's learning memory. Updated automatically as the AI learns from interactions.
> Do not edit manually unless correcting an error.
> Last updated: 2026-04-27

## User Preferences

<!-- How the user likes things done. Code style, tools, patterns, communication. -->

## Key Learnings

- **Project:** MealTracking
- **Stack:** Flutter mobile app under `mobile/` (Riverpod + drift + dio; **no go_router** — uses MaterialPageRoute pushes from `home_shell.dart` tabs). Barcode scanning is mobile-only via `mobile_scanner: ^5.2.3`. (The repo previously hosted a Vanilla JS PWA at root — `index.html`, `js/`, `styles/`, `sw.js`, `manifest.json` — removed 2026-05-04; `mobile/` is now the only application.)
- **Food lookup:** OpenFoodFacts public API via `mobile/lib/food/off_client.dart` — `OffLookupException` carries `notFound` and `noNutrition` flags so the UI can show a specific message.
- **mobile_scanner detection model:** `DetectionSpeed.noDuplicates` only suppresses repeats *while the controller stays running*. Calling `controller.stop()` then `controller.start()` resets the dedup state, so a barcode still in frame will re-detect immediately on restart. Don't restart the controller during a normal lookup — rely on a `_busy` flag and (optionally) an app-level last-code cooldown.
- **Drift schema migrations:** schemaVersion lives in `mobile/lib/data/db/database.dart`. Migrations in `MigrationStrategy.onUpgrade` use `if (from < N)` blocks that call `m.createTable(...)` and `m.addColumn(...)`. After table changes, **must** run `dart run build_runner build --delete-conflicting-outputs` (NOT `flutter pub run` — that path can fail on pub.dev advisory format quirks). The `flutter pub get` step can fail with `FormatException: advisoriesUpdated must be a String` — work around by running build_runner directly (it doesn't re-run pub get) and `flutter analyze --no-pub` for verification.
- **DAOs live in `lib/data/db/dao/`** (not at the top of `db/`). Drift `@DriftAccessor(tables: [...])` mixin is named `_$<DaoName>Mixin` and the part directive is `part '<filename>.g.dart'`.
- **Drift table column naming:** the column getter name becomes the SQL column name. Don't name a TextColumn getter `text` (collides with the `text()` type constructor) — use `description` or another distinct name.
- **AI analyzers (`mobile/lib/ai/`)** share a single `MealAnalyzer.analyzeMeal(AnalysisRequest)` interface. To add a new analysis mode (e.g., recipe), extend `AnalysisRequest` with a new optional field (e.g., `recipeIngredients`), branch in `PromptBuilder.systemInstruction` based on it, and have both adapters skip the image/text-description appendix when the new mode is active. Don't fork into `analyzeRecipe(...)` — keeps the dio boilerplate single-sourced.
- **Localization:** snake_case ARB keys. After editing `app_en.arb`/`app_uk.arb`, run `flutter gen-l10n` (config in `l10n.yaml`).
- **`use_build_context_synchronously` lint:** when you receive a `BuildContext` as a method parameter and want to use it after an `await`, the lint requires `if (!context.mounted) return;` — the State's `mounted` is treated as "unrelated."
- **Saved meals data model (added 2026-05-04):** `SavedMeals` table stores per-100g aggregates AND raw totals + total weight; `SavedMealIngredients` stores ordered ingredient rows with cascade delete. Logged portions are inserted into `Meals` with `source='saved_meal'` and `savedMealId` FK as a snapshot — past logs are immutable to recipe edits, and deleting a recipe leaves logs intact (FK is nullable, no FK constraint enforced at DB level — just an int reference).
- **Log-time extras (added 2026-05-04):** `Meals.extrasJson` (TEXT nullable) stores ad-hoc ingredients added at log time as `[{"d":"ketchup","g":30}, ...]`. The flow lives in `LogPortionScreen` (full screen pushed from the saved-meals library, replacing the old modal sheet). When extras present, `AnalysisRequest.recipeIngredients` is set to the extras list (only) and the same `analyzeMeal` path computes their totals; those are summed into the saved-meal portion totals before the `Meals` insert. Meal name carries a `+ extra1 + extra2` suffix for visibility in the daily log; `meal_details_sheet.dart` shows the full breakdown when `meal.hasExtras`.
- **Drift `update().replace(row)` overwrites all columns:** `MealsRepository.updateMeal` builds a `MealRow` from the `Meal` model and calls `_dao.updateMeal(row)` which uses `update(meals).replace(row)` — that nukes columns the model doesn't track (`savedMealId`, `extrasJson`). The method is currently unused in features but is a latent bug. If/when meal editing UI lands, switch to companion-based partial update (`update(meals)..where(...).write(MealsCompanion(...))`).

## Do-Not-Repeat

<!-- Mistakes made and corrected. Each entry prevents the same mistake recurring. -->
<!-- Format: [YYYY-MM-DD] Description of what went wrong and what to do instead. -->
- [2026-05-03] Don't `await controller.stop()` / `await controller.start()` inside `mobile_scanner`'s `onDetect` callback to "pause during lookup". It causes a visible camera black-flash AND resets `noDuplicates` state, producing a detect→stop→fail→start→detect loop on any failing barcode. Use a `bool _busy` guard plus a same-code cooldown instead; let the camera keep running.
- [2026-05-04] Don't name a Drift `TextColumn` getter `text` — it shadows the `text()` type constructor inside the table class. Use `description`, `label`, or another distinct name.
- [2026-05-04] Don't use `flutter pub run build_runner` here — the local pub.dev advisories decoder is broken (`FormatException: advisoriesUpdated must be a String`). Use `dart run build_runner build --delete-conflicting-outputs` (no pub get triggered) and `flutter analyze --no-pub` for verification. `flutter gen-l10n` works because it doesn't hit pub get.
- [2026-05-04] Don't fork analyzer adapters into a separate `analyzeRecipe(...)` method. Reuse the existing `analyzeMeal(AnalysisRequest)` by extending `AnalysisRequest` with an optional `recipeIngredients` field; both adapters then branch with `if (!request.isRecipe)` to decide whether to attach an image / "User description:" appendix. Keeps the dio boilerplate in one place.

## Decision Log

<!-- Significant technical decisions with rationale. Why X was chosen over Y. -->
