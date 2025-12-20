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

            {/* Weekly Overview */}
            <div className="card">
                <h3>Weekly Schedule</h3>
                <p className="text-muted text-sm mb-4">ZigZag Rotation (High: Mon, Wed, Fri)</p>
                <div className="flex flex-col gap-2">
                    {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day, index) => {
                        // Mon(0), Wed(2), Fri(4) -> Workout days
                        const isHigh = [0, 2, 4].includes(index);
                        const cals = isHigh ? zigZag.workout : zigZag.rest;
                        const isToday = new Date().getDay() === (index + 1) % 7; // getDay() Sun=0, so Mon=1...

                        return (
                            <div
                                key={day}
                                className="flex justify-between items-center p-2 rounded"
                                style={{
                                    backgroundColor: isToday ? 'var(--surface-hover)' : 'transparent',
                                    border: isToday ? '1px solid var(--primary)' : 'none'
                                }}
                            >
                                <div className="flex items-center gap-2">
                                    <span style={{ width: '40px', fontWeight: 'bold' }}>{day}</span>
                                    <span className={`text-xs px-2 py-0.5 rounded-full ${isHigh ? 'bg-primary/20 text-primary' : 'bg-surface text-muted'}`} style={{ border: '1px solid var(--border)' }}>
                                        {isHigh ? 'Workout' : 'Rest'}
                                    </span>
                                </div>
                                <strong>{cals}</strong>
                            </div>
                        );
                    })}
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
