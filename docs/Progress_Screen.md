# Screen: Progress

## Purpose

This screen provides users with visual feedback on their weight loss journey and adherence to their diet plan, using data stored locally.

## Content & Features

1.  **Weight Chart:**
    * **Display:** A line graph plotting the user's recorded weight entries over time. Reads data from local storage.
    * **Goal Line:** Optionally displays the target weight.
    * **Timeframe Selection:** Allows viewing progress over different periods.
2.  **Calorie / Macronutrient Adherence:**
    * **Display:** Charts or summaries showing average daily intake compared to targets over selected periods. Reads data from local meal logs.
3.  **Weekly Weigh-in:**
    * **Input:** A simple interface to record the current weight.
    * **Functionality:** Adds a new data point to the weight history stored locally.

## Data Source

* Reads all data (weight history, meal logs) exclusively from **local storage** (`sqflite`).

## Access

* Typically accessible via a main navigation tab or menu item.