import { analyzeMeal } from '../api.js';
import { getSettings } from '../storage.js';

export function renderRecordScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';
    const settings = getSettings();
    const showMacros = settings.showMacros;

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">Record Meal</h1>
        </div>

        <!-- AI Input Section -->
        <div class="card" id="ai-section">
            <h3 style="margin-bottom:10px;">✨ AI Entry</h3>
            <div class="ai-input-container">
                <textarea id="aiText" class="form-textarea" placeholder="Describe your meal... (e.g., 'A bowl of oatmeal with blueberries and honey')"></textarea>
                
                <div style="display:flex; gap:10px;">
                    <label class="btn btn-secondary btn-icon" style="flex:1">
                        📷 Photo
                        <input type="file" id="aiImage" accept="image/*" style="display:none">
                    </label>
                </div>
                
                <img id="previewImg" class="image-preview" alt="Preview">
                
                <button id="btnAnalyze" class="btn" style="width:100%">
                    🔮 Analyze
                </button>
            </div>
        </div>

        <!-- Manual / Edit Section -->
        <div class="card" id="manual-section">
            <h3 style="margin-bottom:10px;">📝 Details</h3>
            <div class="form-group">
                <label class="form-label">Food Name</label>
                <input type="text" id="foodName" class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">Calories (kcal)</label>
                <input type="number" id="calories" class="form-input">
            </div>
            
            <div id="macro-fields" class="${showMacros ? '' : 'hidden'}">
                <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:10px;">
                     <div class="form-group">
                        <label class="form-label">Prot (g)</label>
                        <input type="number" id="protein" class="form-input">
                    </div>
                     <div class="form-group">
                        <label class="form-label">Carb (g)</label>
                        <input type="number" id="carbs" class="form-input">
                    </div>
                     <div class="form-group">
                        <label class="form-label">Fat (g)</label>
                        <input type="number" id="fat" class="form-input">
                    </div>
                </div>
            </div>

            <div id="warning-box" class="card" style="background-color:rgba(255,0,0,0.2); border-color:red; display:none;">
                ⚠️ <span id="warning-text"></span>
            </div>

            <button id="btnAddLog" class="btn" style="width:100%">Add to Log</button>
        </div>
    `;

    // Image Preview
    const imgInput = container.querySelector('#aiImage');
    const preview = container.querySelector('#previewImg');
    let currentImageBase64 = null;

    imgInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (evt) => {
                currentImageBase64 = evt.target.result;
                preview.src = currentImageBase64;
                preview.classList.add('visible');
            };
            reader.readAsDataURL(file);
        }
    });

    // Analyze
    const btnAnalyze = container.querySelector('#btnAnalyze');
    btnAnalyze.addEventListener('click', async () => {
        const text = container.querySelector('#aiText').value;
        if (!text && !currentImageBase64) return alert('Please provide text or an image.');

        btnAnalyze.textContent = 'Thinking...';
        btnAnalyze.disabled = true;

        try {
            const result = await analyzeMeal(text, currentImageBase64);

            // Populate Fields
            container.querySelector('#foodName').value = result.name || 'Unknown Meal';
            container.querySelector('#calories').value = result.calories || 0;

            if (showMacros) {
                container.querySelector('#protein').value = result.protein || 0;
                container.querySelector('#carbs').value = result.carbs || 0;
                container.querySelector('#fat').value = result.fat || 0;
            }

            // Warnings
            if (result.allergen_warning) {
                const wBox = container.querySelector('#warning-box');
                const wText = container.querySelector('#warning-text');
                wText.textContent = result.allergen_warning;
                wBox.style.display = 'block';
            }

        } catch (error) {
            alert('Analysis Failed: ' + error.message);
        } finally {
            btnAnalyze.textContent = '🔮 Analyze';
            btnAnalyze.disabled = false;
        }
    });

    // Add Log
    container.querySelector('#btnAddLog').addEventListener('click', () => {
        const log = {
            id: Date.now(),
            date: new Date().toISOString(),
            name: container.querySelector('#foodName').value,
            calories: parseInt(container.querySelector('#calories').value) || 0,
            protein: parseInt(container.querySelector('#protein').value) || 0,
            carbs: parseInt(container.querySelector('#carbs').value) || 0,
            fat: parseInt(container.querySelector('#fat').value) || 0,
        };

        if (!log.name) return alert('Please enter a food name');

        // Save to Storage (Logs)
        const logs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');
        logs.push(log);
        localStorage.setItem('meal_tracker_logs', JSON.stringify(logs));

        alert('Meal Added!');
        // Clear
        container.querySelector('#foodName').value = '';
        container.querySelector('#calories').value = '';
        container.querySelector('#aiText').value = '';
        preview.classList.remove('visible');
    });

    return container;
}
