import React, { useState } from 'react';
import { useData } from '../contexts/DataContext';
import { useUser } from '../contexts/UserContext';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, ReferenceLine } from 'recharts';

export default function ProgressScreen() {
    const { weightHistory, addWeight, logs } = useData();
    const { profile } = useUser();
    const [newWeight, setNewWeight] = useState('');

    const handleWeighIn = (e) => {
        e.preventDefault();
        if (newWeight) {
            addWeight(newWeight);
            setNewWeight('');
            alert('Weight Recorded!');
        }
    };

    // Prepare Chart Data
    const chartData = weightHistory.map(entry => ({
        date: new Date(entry.date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' }),
        weight: entry.weight
    })).slice(-10); // Last 10 entries for simplicity

    // Adherence (Average Cals last 7 days)
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    const recentLogs = logs.filter(l => new Date(l.timestamp) > oneWeekAgo);
    const totalCals = recentLogs.reduce((sum, log) => sum + (log.calories || 0), 0);
    const avgCals = recentLogs.length > 0 ? Math.round(totalCals / 7) : 0; // Rough avg per day (fixing denominator to 7 implies 7 days existed, maybe easier to just sum total)
    // Actually, to get Daily Average, we need to group by day.
    // Let's just show Total Logged Today.

    const today = new Date().toISOString().split('T')[0];
    const todayLogs = logs.filter(l => l.timestamp.startsWith(today));
    const todayCals = todayLogs.reduce((sum, log) => sum + (log.calories || 0), 0);

    return (
        <div className="container animate-fade-in">
            <h1 className="mb-4">Progress</h1>

            {/* Weigh In */}
            <div className="card">
                <h3>Weigh In</h3>
                <form onSubmit={handleWeighIn} className="flex gap-4 mt-4 items-end">
                    <div className="input-group w-full mb-0">
                        <label>Current Weight (kg)</label>
                        <input
                            type="number"
                            step="0.1"
                            value={newWeight}
                            onChange={(e) => setNewWeight(e.target.value)}
                            placeholder={profile.weight}
                        />
                    </div>
                    <button type="submit" className="btn btn-primary mb-[1px]">Log</button>
                    {/* mb-[1px] aligns visual height roughly with input border */}
                </form>
            </div>

            {/* Chart */}
            <div className="card h-64">
                <h3 className="mb-4">Weight History</h3>
                {chartData.length > 0 ? (
                    <ResponsiveContainer width="100%" height="100%">
                        <LineChart data={chartData}>
                            <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                            <XAxis dataKey="date" stroke="var(--text-muted)" fontSize={12} />
                            <YAxis domain={['dataMin - 2', 'dataMax + 2']} stroke="var(--text-muted)" fontSize={12} />
                            <Tooltip
                                contentStyle={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}
                                itemStyle={{ color: 'var(--text-main)' }}
                            />
                            {profile.goalWeight && (
                                <ReferenceLine y={profile.goalWeight} label="Goal" stroke="var(--success)" strokeDasharray="5 5" />
                            )}
                            <Line type="monotone" dataKey="weight" stroke="var(--primary)" strokeWidth={2} dot={{ fill: 'var(--primary)' }} />
                        </LineChart>
                    </ResponsiveContainer>
                ) : (
                    <div className="h-full flex items-center justify-center text-muted">
                        No Data Yet
                    </div>
                )}
            </div>

            {/* Stats */}
            <div className="card">
                <h3>Snapshot</h3>
                <div className="flex justify-between mt-4">
                    <div className="text-center">
                        <span className="block text-muted text-sm">Today's Intake</span>
                        <strong className="text-xl">{todayCals}</strong>
                        <span className="text-muted text-xs block">kcal</span>
                    </div>
                    <div className="text-center">
                        <span className="block text-muted text-sm">Start Weight</span>
                        <strong className="text-xl">{weightHistory[0]?.weight || profile.weight}</strong>
                        <span className="text-muted text-xs block">kg</span>
                    </div>
                    <div className="text-center">
                        <span className="block text-muted text-sm">Goal</span>
                        <strong className="text-xl text-success">{profile.goalWeight}</strong>
                        <span className="text-muted text-xs block">kg</span>
                    </div>
                </div>
            </div>
        </div>
    );
}
