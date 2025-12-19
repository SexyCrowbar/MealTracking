import React, { useState, useEffect } from 'react';
import { useUser } from '../contexts/UserContext';
import { calculateBMR, calculateTDEE, calculateZigZagPlan, calculateMacros } from '../utils/calculations';

export default function PlanScreen() {
    const { profile, settings } = useUser();
    const [isWorkoutDay, setIsWorkoutDay] = useState(false);

    // Calculate targets
    const bmr = calculateBMR(profile.weight, profile.height, profile.age, profile.sex);
    const tdee = calculateTDEE(bmr, profile.activityLevel);
    const zigZag = calculateZigZagPlan(tdee, 'loss');

    const dailyCalories = isWorkoutDay ? zigZag.workout : zigZag.rest;
    const macros = calculateMacros(dailyCalories, settings.diabeticMode && settings.insulinRatio); // Pass diabetic context if needed for macro split changes

    return (
        <div className="animate-fade-in">
            <h1 className="mb-4">Today's Plan</h1>

            {/* Day Type Toggle */}
            <div className="card flex items-center justify-between">
                <div>
                    <h3>{isWorkoutDay ? 'Workout Day' : 'Rest Day'}</h3>
                    <p className="text-muted">
                        {isWorkoutDay ? 'High energy for performance' : 'Lower calories for recovery'}
                    </p>
                </div>
                <button
                    className={`btn ${isWorkoutDay ? 'btn-primary' : 'btn-secondary'}`}
                    onClick={() => setIsWorkoutDay(!isWorkoutDay)}
                >
                    {isWorkoutDay ? 'Active' : 'Resting'}
                </button>
            </div>

            {/* Main Target */}
            <div className="text-center py-8">
                <div className="flex flex-col items-center justify-center">
                    <span className="text-muted text-lg">Daily Target</span>
                    <span style={{ fontSize: '4rem', fontWeight: '700', color: 'var(--primary)', lineHeight: 1 }}>
                        {dailyCalories}
                    </span>
                    <span className="text-muted">kcal</span>
                </div>
            </div>

            {/* Macros */}
            <div className="flex gap-4 mb-4">
                <MacroCard label="Protein" amount={macros.protein} color="var(--accent)" />
                <MacroCard label="Carbs" amount={macros.carbs} color="var(--secondary)" />
                <MacroCard label="Fat" amount={macros.fat} color="var(--warning)" />
            </div>

            <div className="card">
                <h3>Stats</h3>
                <div className="flex justify-between mt-4">
                    <div>
                        <span className="block text-muted text-sm">BMR</span>
                        <strong>{Math.round(bmr)}</strong>
                    </div>
                    <div>
                        <span className="block text-muted text-sm">TDEE</span>
                        <strong>{Math.round(tdee)}</strong>
                    </div>
                    <div>
                        <span className="block text-muted text-sm">ZigZag Diff</span>
                        <strong>{zigZag.workout - zigZag.rest} kcal</strong>
                    </div>
                </div>
            </div>
        </div>
    );
}

function MacroCard({ label, amount, color }) {
    return (
        <div className="card w-full text-center" style={{ padding: 'var(--space-md)' }}>
            <span className="block text-muted text-sm mb-1">{label}</span>
            <strong style={{ color: color, fontSize: '1.5rem', display: 'block' }}>{amount}g</strong>
        </div>
    );
}
