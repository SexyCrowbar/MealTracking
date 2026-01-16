
import { calculateBMR, calculateTDEE, calculateZigZagPlan, getDayType } from '../utils.js';
import { getUserProfile, getSettings } from '../storage.js';
import { showToast, showConfirm } from '../ui.js';
import { t } from '../translations.js';

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
    <div class="screen-header"><h1 class="screen-title">${t('screen_title_start')}</h1></div>
        <div class="card" style="text-align:center; padding:40px;">
            <p style="margin-bottom:20px; color:var(--text-muted)">${t('setup_profile_msg')}</p>
            <a href="#settings" class="btn">${t('setup_profile_btn')}</a>
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
            <h1 class="screen-title">${t('screen_title_plan')}</h1>
            <p style="color:var(--text-muted); font-size:0.9rem;">
                ${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })} 
                • <span style="color:${dayType === 'high' ? 'var(--accent-red)' : 'var(--primary)'}">${t(dayType === 'high' ? 'high_day' : 'low_day')}</span>
            </p>
        </div>

        <!--Calories Ring-->
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
                    <div style="color:var(--text-muted); font-size:0.9rem;">${t('kcal_remaining')}</div>
                    <div style="color:var(--text-muted); font-size:0.8rem; margin-top:5px;">${t('target')}: ${dailyTarget}</div>
                </div>
            </div>
        </div>

        <!--Macros(If Enabled) -->
    ${settings.showMacros ? `
        <div class="card">
            <h3 style="margin-bottom:15px;">${t('macros')}</h3>
            <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:10px; text-align:center;">
                <div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">${t('protein')}</div>
                    <div style="font-size:1.2rem; font-weight:600;">${consumed.prot}g</div>
                </div>
                <div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">${t('carbs')}</div>
                    <div style="font-size:1.2rem; font-weight:600;">${consumed.carbs}g</div>
                </div>
                 <div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">${t('fat')}</div>
                    <div style="font-size:1.2rem; font-weight:600;">${consumed.fat}g</div>
                </div>
            </div>
        </div>
    ` : ''}



        <!--Recent Logs-->
    <h3 style="margin:20px 0 10px 0;">${t('todays_meals')}</h3>
        ${todayLogs.length === 0 ? `<p style="color:var(--text-muted); text-align:center;">${t('no_meals_logged')}</p>` : ''}
        ${todayLogs.map(log => `
            <div class="card" style="padding: 10px 15px; display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                <div>
                    <div style="font-weight:600;">${log.name}</div>
                    <div style="color:var(--text-muted); font-size:0.8rem;">${log.calories} kcal</div>
                </div>
                <button class="btn btn-secondary delete-log-btn" data-id="${log.id}" style="padding:5px 10px; font-size:0.8rem;">❌</button>
            </div>
        `).join('')}
`;

    // Attach event listeners for delete buttons
    container.querySelectorAll('.delete-log-btn').forEach(button => {
        button.addEventListener('click', (e) => {
            const id = parseInt(e.target.dataset.id);
            showConfirm(t('confirm_delete_entry'), () => {
                let currentLogs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');
                currentLogs = currentLogs.filter(l => l.id !== id);
                localStorage.setItem('meal_tracker_logs', JSON.stringify(currentLogs));

                // Refresh the screen
                const app = document.getElementById('app');
                app.innerHTML = ''; // Clear current content
                app.appendChild(renderPlanScreen()); // Re-render the entire screen
                showToast(t('entry_deleted'));
            });
        });
    });

    return container;
}
