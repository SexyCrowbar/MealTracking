import React, { useState } from 'react';
import { useData } from '../contexts/DataContext';
import { useUser } from '../contexts/UserContext';
import { Trash2, Edit2, X, Check } from 'lucide-react';

export default function HistoryScreen() {
    const { logs, deleteLog, updateLog } = useData();
    const { settings } = useUser();
    const [editingId, setEditingId] = useState(null);
    const [editForm, setEditForm] = useState({});

    // Group logs by date
    const groupedLogs = logs.reduce((acc, log) => {
        const date = new Date(log.timestamp).toLocaleDateString(undefined, {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
        if (!acc[date]) acc[date] = [];
        acc[date].push(log);
        return acc;
    }, {});

    const handleDelete = (id) => {
        if (confirm('Are you sure you want to delete this log?')) {
            deleteLog(id);
        }
    };

    const startEdit = (log) => {
        setEditingId(log.id);
        setEditForm({ ...log });
    };

    const cancelEdit = () => {
        setEditingId(null);
        setEditForm({});
    };

    const saveEdit = () => {
        updateLog(editingId, editForm);
        setEditingId(null);
    };

    const handleChange = (field, value) => {
        setEditForm(prev => ({ ...prev, [field]: value }));
    };

    return (
        <div className="container animate-fade-in">
            <h1 className="mb-4">Meal History</h1>

            {logs.length === 0 ? (
                <div className="card text-center py-8 text-muted">
                    <p>No meals recorded yet.</p>
                </div>
            ) : (
                Object.entries(groupedLogs).map(([date, dayLogs]) => (
                    <div key={date} className="mb-6">
                        <h3 className="text-muted text-sm mb-2 uppercase tracking-wider">{date}</h3>
                        {dayLogs.map(log => (
                            <div key={log.id} className="card p-4 mb-2 flex flex-col gap-2">
                                {editingId === log.id ? (
                                    /* Edit Mode */
                                    <div className="flex flex-col gap-2">
                                        <input
                                            type="text"
                                            value={editForm.name}
                                            onChange={(e) => handleChange('name', e.target.value)}
                                            placeholder="Food Name"
                                            className="font-bold"
                                        />
                                        <div className="flex gap-2">
                                            <div className="w-1/4">
                                                <label className="text-xs text-muted">Cals</label>
                                                <input
                                                    type="number"
                                                    value={editForm.calories}
                                                    onChange={(e) => handleChange('calories', parseInt(e.target.value) || 0)}
                                                />
                                            </div>
                                            <div className="w-1/4">
                                                <label className="text-xs text-muted">Prot</label>
                                                <input
                                                    type="number"
                                                    value={editForm.protein}
                                                    onChange={(e) => handleChange('protein', parseFloat(e.target.value) || 0)}
                                                />
                                            </div>
                                            <div className="w-1/4">
                                                <label className="text-xs text-muted">Carbs</label>
                                                <input
                                                    type="number"
                                                    value={editForm.carbs}
                                                    onChange={(e) => handleChange('carbs', parseFloat(e.target.value) || 0)}
                                                />
                                            </div>
                                            <div className="w-1/4">
                                                <label className="text-xs text-muted">Fat</label>
                                                <input
                                                    type="number"
                                                    value={editForm.fat}
                                                    onChange={(e) => handleChange('fat', parseFloat(e.target.value) || 0)}
                                                />
                                            </div>
                                        </div>

                                        {/* Optional Fields per Settings */}
                                        <div className="flex gap-2">
                                            {settings.showGI && (
                                                <div className="w-1/2">
                                                    <label className="text-xs text-muted">GI</label>
                                                    <input
                                                        type="number"
                                                        value={editForm.glycemicIndex || 0}
                                                        onChange={(e) => handleChange('glycemicIndex', parseFloat(e.target.value) || 0)}
                                                    />
                                                </div>
                                            )}
                                            {settings.showInsulin && (
                                                <div className="w-1/2">
                                                    <label className="text-xs text-muted">Insulin (Est)</label>
                                                    <input
                                                        type="number"
                                                        value={editForm.estimatedInsulin || 0}
                                                        onChange={(e) => handleChange('estimatedInsulin', parseFloat(e.target.value) || 0)}
                                                    />
                                                </div>
                                            )}
                                        </div>

                                        <div className="flex justify-end gap-2 mt-2">
                                            <button className="btn btn-secondary text-sm p-1 px-3" onClick={cancelEdit}>
                                                Cancel
                                            </button>
                                            <button className="btn btn-primary text-sm p-1 px-3" onClick={saveEdit}>
                                                Save
                                            </button>
                                        </div>
                                    </div>
                                ) : (
                                    /* View Mode */
                                    <div className="flex justify-between items-start">
                                        <div>
                                            <strong className="text-lg block">{log.name}</strong>
                                            <div className="text-sm text-muted flex flex-wrap gap-3 mt-1">
                                                <span>{log.calories} kcal</span>
                                                <span>P: {log.protein}g</span>
                                                <span>C: {log.carbs}g</span>
                                                <span>F: {log.fat}g</span>
                                                {settings.showGI && log.glycemicIndex !== undefined && (
                                                    <span className="text-info">GI: {log.glycemicIndex}</span>
                                                )}
                                                {settings.showInsulin && log.estimatedInsulin !== undefined && (
                                                    <span className="text-warning">Ins: {log.estimatedInsulin}u</span>
                                                )}
                                            </div>
                                        </div>
                                        <div className="flex gap-2">
                                            <button className="p-2 text-muted hover:text-primary" onClick={() => startEdit(log)}>
                                                <Edit2 size={18} />
                                            </button>
                                            <button className="p-2 text-muted hover:text-error" onClick={() => handleDelete(log.id)}>
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                ))
            )}
        </div>
    );
}
