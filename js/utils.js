// Utility Functions

// Mifflin-St Jeor Equation
export function calculateBMR(weightKg, heightCm, age, isMale) {
    let bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return isMale ? (bmr + 5) : (bmr - 161);
}

export function calculateTDEE(bmr, activityMultiplier) {
    return bmr * activityMultiplier;
}

export const ACTIVITY_LEVELS = {
    sedentary: 1.2,      // Little or no exercise
    light: 1.375,        // Light exercise/sports 1-3 days/week
    moderate: 1.55,      // Moderate exercise/sports 3-5 days/week
    active: 1.725,       // Hard exercise/sports 6-7 days/week
    extra: 1.9           // Very hard exercise/physical job
};

export function calculateZigZagPlan(tdee, goalWeight, currentWeight) {
    // Basic weight loss logic: -500 calories for 1lb/week loss
    const isWeightLoss = goalWeight < currentWeight;
    const deficit = isWeightLoss ? 500 : 0; // Maintain if goal >= current (implied)

    const dailyBase = tdee - deficit;

    // ZigZag: 5 low days, 2 high days (refeed)
    // High day = Maintenance or slightly above
    // To maintain weekly deficit, low days must be lower

    // Weekly Target = dailyBase * 7
    // High Days = TDEE (Maintenance)
    // Remaining Calories = (dailyBase * 7) - (TDEE * 2)
    // Low Day = Remaining / 5

    // Simple ZigZag: +/- swing
    // High = Base + 15%
    // Low = Base - 6% (approx to balance)

    const highDay = Math.round(dailyBase * 1.15);
    const lowDay = Math.round(dailyBase * 0.94);

    return {
        high: highDay,
        low: lowDay,
        weeklyAverage: dailyBase
    };
}

export function getDayType(date) {
    // 2 high days a week, e.g., Sat/Sun or Wed/Sun
    // Using Sat(6) and Sun(0) as high days
    const day = date.getDay();
    return (day === 0 || day === 6) ? 'high' : 'low';
}

export function formatDate(date) {
    return date.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
}
