import { calculateBMR, calculateTDEE, calculateZigZagPlan, getDayType } from '../utils.js';
import { getUserProfile, getSettings } from '../storage.js';

export function renderPlanScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';

    // Get Data
    const profile = getUserProfile();
    const settings = getSettings();
    const logs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');

    // Check if profile exists
    if (!profile) {
        container.innerHTML = `
            <div class="screen-header"><h1 class="screen-title">Start Your Journey</h1></div>
            <div class="card" style="text-align:center; padding:40px;">
                <p style="margin-bottom:20px; color:var(--text-muted)">Please set up your profile to generate your plan.</p>
                <a href="#settings" class="btn">Setup Profile</a>
            </div>
        `;
        return container;
    }

    // Calculations
    const bmr = calculateBMR(profile.weight, profile.height, profile.age, profile.gender === 'male');
    const tdee = calculateTDEE(bmr, 1.2); // Default to sedentary for base, profile activity usually higher
    // Actually use profile activity
    // Map string to value manually if needed or import ACTIVITY_LEVELS
    const ACTIVITY_MAP = {
        sedentary: 1.2, light: 1.375, moderate: 1.55, active: 1.725, extra: 1.9
    };
    const realTdee = calculateTDEE(bmr, ACTIVITY_MAP[profile.activity] || 1.2);

    const plan = calculateZigZagPlan(realTdee, profile.goalWeight, profile.weight);
    const dayType = getDayType(new Date());
    const dailyTarget = dayType === 'high' ? plan.high : plan.low;

    // Today's Consumption
    const today = new Date().toISOString().split('T')[0];
    const todayLogs = logs.filter(l => l.date.startsWith(today));

    const consumed = todayLogs.reduce((acc, log) => ({
        cals: acc.cals + log.calories,
        prot: acc.prot + log.protein,
        carbs: acc.carbs + log.carbs,
        fat: acc.fat + log.fat
    }), { cals: 0, prot: 0, carbs: 0, fat: 0 });

    const remaining = dailyTarget - consumed.cals;
    const progressPercent = Math.min((consumed.cals / dailyTarget) * 100, 100);

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">Today's Plan</h1>
            <p style="color:var(--text-muted); font-size:0.9rem;">
                ${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })} 
                • <span style="color:${dayType === 'high' ? 'var(--accent-red)' : 'var(--primary)'}">${dayType.toUpperCase()} DAY</span>
            </p>
        </div>

        <!-- Calories Ring -->
        <div class="card" style="text-align:center; display:flex; flex-direction:column; align-items:center;">
            <div style="position:relative; width:200px; height:200px; display:flex; align-items:center; justify-content:center;">
                <svg width="200" height="200" style="transform: rotate(-90deg);">
                    <circle cx="100" cy="100" r="90" stroke="var(--bg-input)" stroke-width="15" fill="none"></circle>
                    <circle cx="100" cy="100" r="90" stroke="var(--primary)" stroke-width="15" fill="none"
                        stroke-dasharray="565" stroke-dashoffset="${565 - (565 * progressPercent) / 100}"
                        style="transition: stroke-dashoffset 1s ease-in-out; stroke-linecap:round;">
                    </circle>
                </svg>
                <div style="position:absolute; text-align:center;">
                    <div style="font-size:2.5rem; font-weight:700;">${Math.round(remaining)}</div>
                    <div style="color:var(--text-muted); font-size:0.9rem;">Kcal Remaining</div>
                    <div style="color:var(--text-muted); font-size:0.8rem; margin-top:5px;">Target: ${dailyTarget}</div>
                </div>
            </div>
        </div>

        <!-- Macros (If Enabled) -->
        ${settings.showMacros ? `
        <div class="card">
            <h3 style="margin-bottom:15px;">Macronutrients</h3>
            <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:10px; text-align:center;">
                <div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">Protein</div>
                    <div style="font-size:1.2rem; font-weight:600;">${consumed.prot}g</div>
                </div>
                <div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">Carbs</div>
                    <div style="font-size:1.2rem; font-weight:600;">${consumed.carbs}g</div>
                </div>
                 <div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">Fat</div>
                    <div style="font-size:1.2rem; font-weight:600;">${consumed.fat}g</div>
                </div>
            </div>
        </div>
        ` : ''}

        <!-- Diabetic Info (If Enabled) -->
        ${settings.diabeticMode && settings.showMacros ? `
        <div class="card" style="border-left: 4px solid var(--accent-blue);">
            <h3 style="margin-bottom:5px;">Diabetic Insights</h3>
            <p style="color:var(--text-muted); font-size:0.9rem;">
                Estimated Insulin for Today (based on intake): 
                <strong>${settings.insulinRatio ? (consumed.carbs / settings.insulinRatio).toFixed(1) : '?'} units</strong>
            </p>
        </div>
        ` : ''}

        <!-- Recent Logs -->
        <h3 style="margin:20px 0 10px 0;">Today's Meals</h3>
        ${todayLogs.length === 0 ? '<p style="color:var(--text-muted); text-align:center;">No meals logged yet.</p>' : ''}
        ${todayLogs.map(log => `
            <div class="card" style="padding: 10px 15px; display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                <div>
                    <div style="font-weight:600;">${log.name}</div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">${log.calories} kcal</div>
                </div>
                <button class="btn btn-secondary" style="padding:5px 10px; font-size:0.8rem;" onclick="deleteLog(${log.id})">❌</button>
            </div>
        `).join('')}
    `;

    // Hacky delete function binding
    window.deleteLog = (id) => {
        if (confirm('Delete this entry?')) {
            const newLogs = logs.filter(l => l.id !== id);
            localStorage.setItem('meal_tracker_logs', JSON.stringify(newLogs));
            // Re-render
            const newScreen = renderPlanScreen();
            container.innerHTML = newScreen.innerHTML;
        }
    };

    return container;
}
