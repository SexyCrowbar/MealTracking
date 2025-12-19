import React, { useState } from 'react';
import { useUser } from '../contexts/UserContext';
import { useData } from '../contexts/DataContext';
import { analyzeMealWithAI } from '../utils/ai';
import { Camera, Mic, Loader2, Save } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function MealRecordingScreen() {
    const { settings } = useUser();
    const { addLog } = useData();
    const navigate = useNavigate();

    const [mode, setMode] = useState('ai'); // 'ai' or 'manual'
    const [loading, setLoading] = useState(false);

    // AI Input State
    const [textInput, setTextInput] = useState('');
    const [imageFile, setImageFile] = useState(null);
    const [imagePreview, setImagePreview] = useState(null);

    // Mic State
    const [isListening, setIsListening] = useState(false);

    // Result / Manual State
    const [result, setResult] = useState(null);

    const handleMicClick = () => {
        if (!('webkitSpeechRecognition' in window)) {
            alert("Speech recognition not supported in this browser.");
            return;
        }

        if (isListening) return; // Stop handled by onend usually, or toggle logic

        const recognition = new window.webkitSpeechRecognition();
        recognition.continuous = false;
        recognition.interimResults = false;

        recognition.onstart = () => setIsListening(true);
        recognition.onend = () => setIsListening(false);

        recognition.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            setTextInput(prev => prev + (prev ? ' ' : '') + transcript);
        };

        recognition.start();
    };

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setImageFile(file);
            const reader = new FileReader();
            reader.onloadend = () => setImagePreview(reader.result);
            reader.readAsDataURL(file);
        }
    };

    const handleAnalyze = async () => {
        if (!textInput && !imageFile) {
            alert("Please provide a description or an image.");
            return;
        }
        if (!settings.apiKey) {
            alert("Please set your Google AI API Key in Settings first.");
            return;
        }

        setLoading(true);
        try {
            const analysis = await analyzeMealWithAI(textInput, imagePreview, settings.apiKey, settings);
            setResult(analysis);
        } catch (error) {
            alert("AI Analysis Failed: " + error.message);
        } finally {
            setLoading(false);
        }
    };

    const handleManualChange = (field, value) => {
        setResult(prev => ({ ...prev, [field]: value }));
    };

    const saveLog = () => {
        if (!result) return;
        addLog({
            ...result,
            name: result.name || textInput || 'Manual Entry',
        });
        // navigate('/plan'); // Optional: redirect back to plan
        alert("Meal Logged!");
        // Reset
        setResult(null);
        setTextInput('');
        setImageFile(null);
        setImagePreview(null);
    };

    return (
        <div className="container animate-fade-in">
            <h1 className="mb-4">Record Meal</h1>

            <div className="flex gap-2 mb-4">
                <button
                    className={`btn w-full ${mode === 'ai' ? 'btn-primary' : 'btn-secondary'}`}
                    onClick={() => { setMode('ai'); setResult(null); }}
                >
                    AI Assist
                </button>
                <button
                    className={`btn w-full ${mode === 'manual' ? 'btn-primary' : 'btn-secondary'}`}
                    onClick={() => { setMode('manual'); setResult({ name: '', calories: 0, protein: 0, carbs: 0, fat: 0 }); }}
                >
                    Manual
                </button>
            </div>

            {mode === 'ai' && !result && (
                <div className="card">
                    <h3 className="mb-4">Describe or Snap</h3>

                    <div className="input-group relative">
                        <textarea
                            rows={4}
                            placeholder="Describe your meal (e.g., 'A bowl of oatmeal with berries')..."
                            value={textInput}
                            onChange={(e) => setTextInput(e.target.value)}
                        />
                        <button
                            className="absolute bottom-4 right-4 text-primary"
                            title="Speak"
                            onClick={handleMicClick}
                        >
                            <Mic className={isListening ? 'animate-pulse text-error' : ''} />
                        </button>
                    </div>

                    <div className="input-group">
                        <label
                            htmlFor="file-upload"
                            className="btn btn-secondary w-full flex gap-2 justify-center cursor-pointer"
                        >
                            <Camera size={20} />
                            {imageFile ? 'Change Photo' : 'Take / Upload Photo'}
                        </label>
                        <input
                            id="file-upload"
                            type="file"
                            accept="image/*"
                            className="hidden"
                            onChange={handleImageChange}
                        />
                    </div>

                    {imagePreview && (
                        <div className="mb-4 relative">
                            <img src={imagePreview} alt="Preview" className="w-full rounded-lg object-cover max-h-64" />
                            <button
                                className="absolute top-2 right-2 bg-black/50 text-white rounded-full p-1"
                                onClick={() => { setImageFile(null); setImagePreview(null); }}
                            >
                                &times;
                            </button>
                        </div>
                    )}

                    <button
                        className="btn btn-primary w-full"
                        onClick={handleAnalyze}
                        disabled={loading}
                    >
                        {loading ? <Loader2 className="animate-spin" /> : 'Analyze Meal'}
                    </button>
                </div>
            )}

            {(result || mode === 'manual') && (
                <div className="animate-fade-in">
                    {result?.allergenWarning && (
                        <div className="card" style={{ borderColor: 'var(--error)', backgroundColor: 'rgba(239, 68, 68, 0.1)' }}>
                            <h3 className="text-error" style={{ fontSize: '1.25rem' }}>⚠️ High Risk Detected</h3>
                            <p>{result.allergenWarning}</p>
                        </div>
                    )}

                    <div className="card">
                        <h3 className="mb-4">{mode === 'ai' ? 'Analysis Result' : 'Manual Entry'}</h3>

                        <div className="input-group">
                            <label>Food Name</label>
                            <input
                                type="text"
                                value={result?.name || ''}
                                onChange={(e) => handleManualChange('name', e.target.value)}
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr' }}>
                            <div className="input-group">
                                <label>Calories</label>
                                <input
                                    type="number"
                                    value={result?.calories || 0}
                                    onChange={(e) => handleManualChange('calories', parseInt(e.target.value) || 0)}
                                />
                            </div>
                            {/* Only show these in manual if needed, but keeping common UI */}
                        </div>

                        {(settings.showMacros || mode === 'manual') && (
                            <div className="grid grid-cols-3 gap-2" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr' }}>
                                <div className="input-group">
                                    <label>Prot (g)</label>
                                    <input type="number" value={result?.protein || 0} onChange={(e) => handleManualChange('protein', parseFloat(e.target.value))} />
                                </div>
                                <div className="input-group">
                                    <label>Carbs (g)</label>
                                    <input type="number" value={result?.carbs || 0} onChange={(e) => handleManualChange('carbs', parseFloat(e.target.value))} />
                                </div>
                                <div className="input-group">
                                    <label>Fat (g)</label>
                                    <input type="number" value={result?.fat || 0} onChange={(e) => handleManualChange('fat', parseFloat(e.target.value))} />
                                </div>
                            </div>
                        )}

                        {mode === 'ai' && settings.showGI && (
                            <div className="input-group">
                                <label>Est. Glycemic Index</label>
                                <input type="number" value={result?.glycemicIndex || 0} readOnly disabled />
                            </div>
                        )}

                        {mode === 'ai' && settings.showInsulin && (
                            <div className="input-group">
                                <label>Est. Insulin Units</label>
                                <input type="number" value={result?.estimatedInsulin || 0} readOnly disabled />
                            </div>
                        )}

                        <button className="btn btn-primary w-full mt-4 gap-2" onClick={saveLog}>
                            <Save size={20} />
                            Log Meal
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
}
