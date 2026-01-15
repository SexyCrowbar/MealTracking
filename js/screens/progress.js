import { getUserProfile, saveUserProfile, getSettings } from '../storage.js';
import { calculateBMR, calculateTDEE, calculateZigZagPlan, getDayType } from '../utils.js';

export function renderProgressScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';
    const profile = getUserProfile();
    const settings = getSettings();

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">Progress & History</h1>
        </div>

        <!-- Weigh-In Section -->
        <div class="card">
            <h3 style="margin-bottom:10px;">⚖️ Weigh-In</h3>
            <div style="display:flex; gap:10px; align-items:end;">
                <div class="form-group" style="flex:1; margin-bottom:0;">
                    <label class="form-label">Current Weight (kg)</label>
                    <input type="number" id="newWeight" class="form-input" value="${profile ? profile.weight : ''}">
                </div>
                <button id="btnUpdateWeight" class="btn">Update</button>
            </div>
        </div>

        <!-- Adherence Chart -->
        <div class="card">
            <h3 style="margin-bottom:20px;">Calorie Adherence (Last 30 Days)</h3>
            <div id="adherenceChart" class="chart-container" style="display:flex; align-items:flex-end; gap:4px; height:200px; padding-bottom:20px; border-bottom:1px solid var(--border); overflow-x:auto;">
                <!-- Chart bars injected here -->
            </div>
             <div style="display:flex; align-items:center; justify-content:center; gap:15px; margin-top:10px; font-size:0.8rem;">
                <div style="display:flex; align-items:center; gap:5px;"><div style="width:10px; height:10px; background:var(--primary);"></div> Consumed</div>
                <div style="display:flex; align-items:center; gap:5px;"><div style="width:10px; height:10px; background:var(--text-muted); opacity:0.3;"></div> Target</div>
            </div>
        </div>

        <!-- History List -->
         <div class="card">
            <h3 style="margin-bottom:20px;">📜 Meal History</h3>
            <div id="historyList">
                <!-- History items injected here -->
            </div>
        </div>
    `;

    // Initialize Logic
    setupWeighIn(container, profile);
    renderAdherenceChart(container.querySelector('#adherenceChart'), profile);
    renderHistoryList(container.querySelector('#historyList'), container);

    return container;
}

function setupWeighIn(container, profile) {
    container.querySelector('#btnUpdateWeight').addEventListener('click', () => {
        const newW = parseFloat(container.querySelector('#newWeight').value);
        if (!newW || isNaN(newW)) return;

        if (profile) {
            profile.weight = newW;
            saveUserProfile(profile);

            const history = JSON.parse(localStorage.getItem('meal_tracker_weight') || '[]');
            history.push({ date: new Date().toISOString(), weight: newW });
            localStorage.setItem('meal_tracker_weight', JSON.stringify(history));

            alert('Weight Updated!');
        }
    });
}

function renderAdherenceChart(chartContainer, profile) {
    if (!profile) return chartContainer.innerHTML = 'Setup profile to view charts.';

    // Calculations (same as before)
    const bmr = calculateBMR(profile.weight, profile.height, profile.age, profile.gender === 'male');
    const ACTIVITY_MAP = { sedentary: 1.2, light: 1.375, moderate: 1.55, active: 1.725, extra: 1.9 };
    const tdee = calculateTDEE(bmr, ACTIVITY_MAP[profile.activity] || 1.2);
    const plan = calculateZigZagPlan(tdee, profile.goalWeight, profile.weight);

    const logs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');

    // Group last 30 days
    const days = [];
    for (let i = 29; i >= 0; i--) {
        const d = new Date();
        d.setDate(d.getDate() - i);
        const dateStr = d.toISOString().split('T')[0];

        const dayLogs = logs.filter(l => l.date.startsWith(dateStr));
        const consumed = dayLogs.reduce((sum, l) => sum + l.calories, 0);

        const dayOfWeek = d.getDay();
        const isHigh = (dayOfWeek === 0 || dayOfWeek === 6);
        const target = isHigh ? plan.high : plan.low;

        days.push({ date: dateStr, consumed, target });
    }

    // SVG Layout
    const width = chartContainer.clientWidth || 600; // Fallback
    const height = 200;
    const padding = 20;
    const chartW = width - (padding * 2);
    const chartH = height - (padding * 2);

    const maxVal = Math.max(...days.map(d => Math.max(d.consumed, d.target)), 2000) * 1.1; // 10% headroom

    // Helper to map Point
    const getX = (i) => padding + (i * (chartW / (days.length - 1)));
    const getY = (val) => height - padding - ((val / maxVal) * chartH);

    // Generate Paths
    let consumedPath = `M ${getX(0)},${getY(days[0].consumed)}`;
    let targetPath = `M ${getX(0)},${getY(days[0].target)}`;

    days.forEach((d, i) => {
        if (i === 0) return;
        consumedPath += ` L ${getX(i)},${getY(d.consumed)}`;
        targetPath += ` L ${getX(i)},${getY(d.target)}`;
    });

    // Points for tooltips/visuals
    const points = days.map((d, i) => {
        const x = getX(i);
        const y = getY(d.consumed);
        const color = d.consumed > d.target ? 'var(--accent-red)' : 'var(--primary)';
        return `<circle cx="${x}" cy="${y}" r="3" fill="${color}" />`;
    }).join('');

    chartContainer.innerHTML = `
        <svg width="100%" height="${height}" viewBox="0 0 ${width} ${height}" preserveAspectRatio="none">
            <!-- Background Lines -->
            <line x1="${padding}" y1="${getY(0)}" x2="${width - padding}" y2="${getY(0)}" stroke="var(--border)" stroke-width="1" />
            <line x1="${padding}" y1="${getY(maxVal / 2)}" x2="${width - padding}" y2="${getY(maxVal / 2)}" stroke="var(--border)" stroke-width="1" stroke-dasharray="4" />
            
            <!-- Target Line -->
            <path d="${targetPath}" fill="none" stroke="var(--text-muted)" stroke-width="2" stroke-dasharray="5,5" opacity="0.5" />
            
            <!-- Consumed Line -->
            <path d="${consumedPath}" fill="none" stroke="var(--primary)" stroke-width="2" />
            
            <!-- Data Points -->
            ${points}
        </svg>
    `;

    // Remove flex styles from container as SVG handles layout
    chartContainer.style.display = 'block';
    chartContainer.style.overflowX = 'hidden'; // SVG handles scaling
}

function renderHistoryList(listContainer, parentContainer) {
    const logs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');
    logs.sort((a, b) => new Date(b.date) - new Date(a.date)); // Newest first

    if (logs.length === 0) {
        listContainer.innerHTML = '<p style="color:var(--text-muted); text-align:center;">No history.</p>';
        return;
    }

    // Group by Date
    const grouped = {};
    logs.forEach(log => {
        const d = log.date.split('T')[0];
        if (!grouped[d]) grouped[d] = [];
        grouped[d].push(log);
    });

    listContainer.innerHTML = Object.keys(grouped).map(date => `
        <details class="history-group" open style="margin-bottom:15px;">
            <summary style="cursor:pointer; font-weight:600; padding:10px; background:var(--bg-input); border-radius:var(--radius-sm); margin-bottom:5px;">
                ${new Date(date).toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' })}
                <span style="float:right; font-weight:400; color:var(--text-muted);">${grouped[date].reduce((s, l) => s + l.calories, 0)} kcal</span>
            </summary>
            ${grouped[date].map(log => `
                <div class="history-item" style="padding:10px; border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <div style="font-weight:500;">${log.name}</div>
                        <div style="font-size:0.8rem; color:var(--text-muted);">
                            ${log.calories} kcal • P:${log.protein} C:${log.carbs} F:${log.fat}
                        </div>
                    </div>
                    <div style="display:flex; gap:10px;">
                        <button class="btn-edit" data-id="${log.id}" style="background:none; border:none; cursor:pointer;">✏️</button>
                        <button class="btn-del" data-id="${log.id}" style="background:none; border:none; cursor:pointer;">🗑️</button>
                    </div>
                </div>
            `).join('')}
        </details>
    `).join('');

    // Attach Event Listeners
    listContainer.querySelectorAll('.btn-del').forEach(btn => {
        btn.addEventListener('click', (e) => {
            if (confirm('Delete this meal?')) {
                const id = parseInt(e.target.dataset.id);
                const newLogs = logs.filter(l => l.id !== id);
                localStorage.setItem('meal_tracker_logs', JSON.stringify(newLogs));
                // Refresh
                renderHistoryList(listContainer, parentContainer);
                renderAdherenceChart(parentContainer.querySelector('#adherenceChart'), getUserProfile()); // Refresh chart too
            }
        });
    });

    listContainer.querySelectorAll('.btn-edit').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const id = parseInt(e.target.dataset.id);
            const log = logs.find(l => l.id === id);
            editLog(log, parentContainer);
        });
    });
}

function editLog(log, container) {
    // Simple Prompt-based edit for now to save UI complexity
    // A modal would be better but requires more CSS/JS structure.
    // Using browser prompts for MVC (Minimum Viable Code) efficiency as requested.

    // Better: Inject a modal form
    const modal = document.createElement('div');
    modal.className = 'modal-overlay fade-in';
    modal.innerHTML = `
        <div class="modal-content">
            <h3>Edit Meal</h3>
            <div class="form-group"><label>Name</label><input id="eName" class="form-input" value="${log.name}"></div>
            <div class="form-group"><label>Cals</label><input type="number" id="eCal" class="form-input" value="${log.calories}"></div>
            <div style="display:flex; gap:5px;">
                <div class="form-group"><label>P</label><input type="number" id="eP" class="form-input" value="${log.protein}" style="min-width:0;"></div>
                <div class="form-group"><label>C</label><input type="number" id="eC" class="form-input" value="${log.carbs}" style="min-width:0;"></div>
                <div class="form-group"><label>F</label><input type="number" id="eF" class="form-input" value="${log.fat}" style="min-width:0;"></div>
            </div>
            <div style="display:flex; gap:10px; margin-top:20px;">
                <button id="btnSaveEdit" class="btn" style="flex:1;">Save</button>
                <button id="btnCancelEdit" class="btn btn-secondary" style="flex:1;">Cancel</button>
            </div>
        </div>
    `;
    document.body.appendChild(modal);

    modal.querySelector('#btnCancelEdit').addEventListener('click', () => modal.remove());

    modal.querySelector('#btnSaveEdit').addEventListener('click', () => {
        const uLog = {
            ...log,
            name: modal.querySelector('#eName').value,
            calories: parseInt(modal.querySelector('#eCal').value) || 0,
            protein: parseInt(modal.querySelector('#eP').value) || 0,
            carbs: parseInt(modal.querySelector('#eC').value) || 0,
            fat: parseInt(modal.querySelector('#eF').value) || 0,
        };

        const logs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');
        const idx = logs.findIndex(l => l.id === log.id);
        if (idx !== -1) {
            logs[idx] = uLog;
            localStorage.setItem('meal_tracker_logs', JSON.stringify(logs));
        }

        modal.remove();
        // Refresh entire screen to update list and chart
        const newScreen = renderProgressScreen();
        container.innerHTML = newScreen.innerHTML;
        // Re-bind (hacky but works for vanilla SPA replacement)
        // Ideally we'd separate render logic better
        setupWeighIn(container, getUserProfile());
        renderAdherenceChart(container.querySelector('#adherenceChart'), getUserProfile());
        renderHistoryList(container.querySelector('#historyList'), container);
    });
}
