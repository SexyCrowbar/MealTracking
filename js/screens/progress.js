import { getUserProfile, saveUserProfile } from '../storage.js';

export function renderProgressScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';
    const profile = getUserProfile();

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">Progress</h1>
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

        <!-- Weight History Chart Placeholder -->
        <div class="card">
            <h3 style="margin-bottom:20px;">Weight History</h3>
            <div class="chart-container" style="position:relative; display:flex; align-items:end; justify-content:space-between; padding-bottom:20px; border-bottom:1px solid var(--border);">
                <!-- Simple CSS Bar Chart using inline logs -->
                ${renderWeightChart()}
            </div>
            <p style="text-align:center; color:var(--text-muted); margin-top:10px; font-size:0.8rem;">
                Last 7 updates
            </p>
        </div>
    `;

    // Logic
    container.querySelector('#btnUpdateWeight').addEventListener('click', () => {
        const newW = parseFloat(container.querySelector('#newWeight').value);
        if (!newW || isNaN(newW)) return;

        // Update Profile
        if (profile) {
            profile.weight = newW;
            saveUserProfile(profile);

            // Add to History
            const history = JSON.parse(localStorage.getItem('meal_tracker_weight') || '[]');
            history.push({ date: new Date().toISOString(), weight: newW });
            // Keep last 30
            if (history.length > 30) history.shift();
            localStorage.setItem('meal_tracker_weight', JSON.stringify(history));

            alert('Weight Updated!');
            // Re-render by simple reload/routing hack or just updating text
            window.location.hash = '#plan'; // Go back to plan to see recalculated targets
        }
    });

    return container;
}

function renderWeightChart() {
    const history = JSON.parse(localStorage.getItem('meal_tracker_weight') || '[]');
    if (history.length === 0) return '<div style="width:100%; text-align:center; color:var(--text-muted);">No history yet</div>';

    // Get Min/Max for scaling
    const weights = history.map(h => h.weight);
    const min = Math.min(...weights) - 1;
    const max = Math.max(...weights) + 1;
    const range = max - min;

    // Take last 7 for simplicity
    const recent = history.slice(-7);

    return recent.map(entry => {
        // Calculate height percentage
        const height = ((entry.weight - min) / range) * 100;
        const date = new Date(entry.date).getDate();

        return `
            <div style="display:flex; flex-direction:column; align-items:center; flex:1; height:100%;">
                 <div style="background-color:var(--primary); width:20px; height:${Math.max(height, 5)}%; border-radius:4px 4px 0 0; transition:height 0.5s;"></div>
                 <span style="font-size:0.7rem; color:var(--text-muted); margin-top:5px;">${date}</span>
            </div>
        `;
    }).join('');
}
