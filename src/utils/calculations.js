export const ACTIVITY_MULTIPLIERS = {
  sedentary: 1.2,
  light: 1.375,
  moderate: 1.55,
  active: 1.725,
  very_active: 1.9
};

export function calculateBMR(weightKg, heightCm, age, sex) {
  // Mifflin-St Jeor Equation
  const s = sex === 'male' ? 5 : -161;
  return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + s;
}

export function calculateTDEE(bmr, activityLevel) {
  const multiplier = ACTIVITY_MULTIPLIERS[activityLevel] || 1.2;
  return Math.round(bmr * multiplier);
}

export function calculateZigZagPlan(tdee, goal = 'loss') {
  // Goal: loss = -500kcal/day average
  const deficit = goal === 'loss' ? 500 : 0; // Maintain if not loss
  const weeklyAverage = tdee - deficit;
  const weeklyTotal = weeklyAverage * 7;

  // Strategy: 3 High Days (Workout/Refeed), 4 Low Days
  // High Day = TDEE (Maintenance) - small deficit or just TDEE?
  // Let's set High Day = TDEE
  // 3 * TDEE + 4 * Low = WeeklyTotal
  // 4 * Low = WeeklyTotal - 3 * TDEE
  // Low = (WeeklyTotal - 3 * TDEE) / 4

  const highDay = tdee; // Maintenance on high days
  const remainingCalories = weeklyTotal - (highDay * 3);
  const lowDay = Math.round(remainingCalories / 4);

  // Safety check: ensure low day isn't too low (e.g. < 1000 or BMR)
  // If calculated low day is too low, flatten the curve
  const minCalories = 1200;
  if (lowDay < minCalories && highDay > minCalories) {
      // Simple spread if aggressive zigzag fails
      return {
          workout: Math.round(weeklyAverage + 200),
          rest: Math.round(weeklyAverage - 150)
      };
  }

  return {
    workout: Math.round(highDay),
    rest: Math.round(lowDay)
  };
}

export function calculateMacros(calories, diabeticMode = false) {
  // Standard split: 30% Protein, 35% Carb, 35% Fat
  // Diabetic friendly: Lower Carb? Say 40% Protein, 20% Carb, 40% Fat?
  // Let's keep it simple standard for now, user didn't specify exact splits.
  
  const ratios = diabeticMode 
    ? { p: 0.40, c: 0.20, f: 0.40 }
    : { p: 0.30, c: 0.35, f: 0.35 };

  return {
    protein: Math.round((calories * ratios.p) / 4),
    carbs: Math.round((calories * ratios.c) / 4),
    fat: Math.round((calories * ratios.f) / 9)
  };
}
