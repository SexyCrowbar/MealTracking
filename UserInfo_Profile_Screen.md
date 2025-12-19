# Screen: User Info / Profile

## Purpose

This screen allows users to set up their initial profile upon first launch and subsequently edit their information via the Settings screen. This data is fundamental for all local calculations within the app.

## Sections / Input Fields

* **Age:** User's age in years.
* **Sex:** User's biological sex (relevant for BMR calculation).
* **Height:** User's height (in cm/inches based on app settings).
* **Current Weight:** User's current weight (in kg/lbs based on app settings). Updated via the Progress screen's weigh-in feature.
* **Goal Weight:** User's desired target weight.
* **Activity Level:** A selection representing the user's typical daily activity (e.g., Sedentary, Lightly Active, Moderately Active, Very Active, Extra Active).

## Functionality

* **Data Storage:** Saves data **only locally** on the device (e.g., using `sqflite` or `shared_preferences`).
* **Calculations:** The entered data is used locally to calculate Basal Metabolic Rate (BMR), Total Daily Energy Expenditure (TDEE), and formulate the ZigZag diet plan targets.
* **Validation:** Basic input validation.

## Access

* Presented automatically on the first launch.
* Accessible later via the "Edit Profile" option within the Settings screen.