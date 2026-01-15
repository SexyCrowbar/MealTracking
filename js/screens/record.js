import { analyzeMeal } from '../api.js';
import { getSettings } from '../storage.js';
import { showToast } from '../ui.js';
import { t } from '../translations.js';

export function renderRecordScreen() {
    const container = document.createElement('div');
    container.className = 'screen-container fade-in';
    const settings = getSettings();
    const showMacros = settings.showMacros;

    container.innerHTML = `
        <div class="screen-header">
            <h1 class="screen-title">${t('screen_title_record')}</h1>
        </div>

        <!-- AI Input -->
        <div class="card">
            <h3 style="margin-bottom:15px;">${t('ai_analysis')}</h3>
            
            <!-- Image Upload Preview -->
            <div id="imagePreviewContainer" style="display:none; margin-bottom:15px; position:relative;">
                <img id="imagePreview" src="" style="width:100%; max-height:200px; object-fit:cover; border-radius: var(--radius-md);">
                <button id="btnRemovePhoto" class="btn btn-secondary" style="position:absolute; top:5px; right:5px; padding:5px 10px; font-size:0.8rem;">${t('remove_photo')}</button>
            </div>

            <div class="form-group">
                <textarea id="aiText" class="form-input" rows="3" placeholder="${t('describe_meal')}"></textarea>
            </div>
            
            <div style="display:flex; gap:10px;">
                <label class="btn btn-secondary" style="flex:1; text-align:center; cursor:pointer;">
                    📷 ${t('photo_prompt')}
                    <input type="file" id="aiImage" accept="image/*" style="display:none;">
                </label>
                <button id="btnAnalyze" class="btn" style="flex:1;">${t('analyze_btn')}</button>
            </div>
        </div>

        <!-- Manual Input / Result Editor -->
        <div class="card">
            <h3 style="margin-bottom:15px;">${t('manual_entry')}</h3>
            
            <div class="form-group">
                <label class="form-label">${t('food_name')}</label>
                <input type="text" id="foodName" class="form-input">
            </div>

            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">${t('calories')}</label>
                    <input type="number" id="calories" class="form-input">
                </div>
                <!-- Optional: Macros can be added here if detailed manual entry is desired, 
                     but sticking to quick entry for now or relying on AI -->
                <div class="form-group">
                    <label class="form-label">${t('protein')} (g)</label>
                    <input type="number" id="prot" class="form-input">
                </div>
                <div class="form-group">
                    <label class="form-label">${t('carbs')} (g)</label>
                    <input type="number" id="carbs" class="form-input">
                </div>
                <div class="form-group">
                    <label class="form-label">${t('fat')} (g)</label>
                    <input type="number" id="fat" class="form-input">
                </div>
            </div>

            ${settings.showGI ? `
             <div class="form-group">
                <label class="form-label">${t('glycemic_index')}</label>
                 <input type="number" id="gi" class="form-input">
            </div>
            ` : ''}

            <!-- Allergen Warning Container -->
            <div id="allergenWarning" class="card warning" style="display:none; background-color: rgba(255, 77, 77, 0.1); border: 1px solid var(--accent-red); color: var(--accent-red);">
                
            </div>

            <button id="btnAdd" class="btn" style="width:100%; margin-top:20px;">${t('add_meal_btn')}</button>
        </div>
    `;

    // Image Preview
    const imgInput = container.querySelector('#aiImage');
    const preview = container.querySelector('#imagePreview');
    const previewContainer = container.querySelector('#imagePreviewContainer');
    let currentImageBase64 = null;

    imgInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (evt) => {
                currentImageBase64 = evt.target.result;
                preview.src = currentImageBase64;
                previewContainer.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    });

    // Remove Image
    container.querySelector('#btnRemovePhoto').addEventListener('click', () => {
        currentImageBase66 = null;
        preview.src = '';
        previewContainer.style.display = 'none';
        imgInput.value = ''; // Reset input
    });

    // Analyze
    const btnAnalyze = container.querySelector('#btnAnalyze');
    btnAnalyze.addEventListener('click', async () => {
        const text = container.querySelector('#aiText').value;
        if (!text && !currentImageBase64) return showToast(t('provide_text_image'), 'error');

        btnAnalyze.textContent = t('analyzing');
        btnAnalyze.disabled = true;

        try {
            const result = await analyzeMeal(text, currentImageBase64);

            // Populate Fields
            container.querySelector('#foodName').value = result.name || 'Unknown Meal';
            container.querySelector('#calories').value = result.calories || 0;

            if (showMacros) {
                container.querySelector('#prot').value = result.protein || 0;
                container.querySelector('#carbs').value = result.carbs || 0;
                container.querySelector('#fat').value = result.fat || 0;
            }
            if (settings.showGI) {
                container.querySelector('#gi').value = result.gi || 0;
            }

            // Warnings
            if (result.allergen_warning) {
                const warnBox = container.querySelector('#allergenWarning');
                warnBox.style.display = 'block';
                warnBox.textContent = t('allergen_warning') + result.allergen_warning;
            }

        } catch (error) {
            showToast(t('analysis_failed') + error.message, 'error');
        } finally {
            btnAnalyze.textContent = t('analyze_btn');
            btnAnalyze.disabled = false;
        }
    });

    // Add Log
    container.querySelector('#btnAdd').addEventListener('click', () => {
        const log = {
            id: Date.now(),
            date: new Date().toISOString(),
            name: container.querySelector('#foodName').value,
            calories: parseInt(container.querySelector('#calories').value) || 0,
            protein: parseInt(container.querySelector('#protein').value) || 0,
            carbs: parseInt(container.querySelector('#carbs').value) || 0,
            fat: parseInt(container.querySelector('#fat').value) || 0,
        };

        if (!log.name) return showToast(t('enter_food_name'), 'error');

        // Save to Storage (Logs)
        const logs = JSON.parse(localStorage.getItem('meal_tracker_logs') || '[]');
        logs.push(log);
        localStorage.setItem('meal_tracker_logs', JSON.stringify(logs));

        showToast(t('meal_added'), 'success');
        // Clear
        container.querySelector('#foodName').value = '';
        container.querySelector('#calories').value = '';
        container.querySelector('#aiText').value = '';
        preview.classList.remove('visible');
    });

    return container;
}
