import React, { createContext, useState, useEffect, useContext } from 'react';

const DataContext = createContext();

export function useData() {
    return useContext(DataContext);
}

export function DataProvider({ children }) {
    const [logs, setLogs] = useState(() => {
        const saved = localStorage.getItem('meal_logs');
        return saved ? JSON.parse(saved) : [];
    });

    const [weightHistory, setWeightHistory] = useState(() => {
        const saved = localStorage.getItem('weight_history');
        return saved ? JSON.parse(saved) : [];
    });

    useEffect(() => {
        localStorage.setItem('meal_logs', JSON.stringify(logs));
    }, [logs]);

    useEffect(() => {
        localStorage.setItem('weight_history', JSON.stringify(weightHistory));
    }, [weightHistory]);

    const addLog = (log) => {
        // log: { id, date, name, cals, protein, carbs, fat, ... }
        const newLog = {
            ...log,
            id: Date.now().toString(),
            timestamp: new Date().toISOString() // Ensure timestamp
        };
        setLogs(prev => [newLog, ...prev]);
    };

    const addWeight = (weight) => {
        // weight: number
        const entry = {
            date: new Date().toISOString(),
            weight: parseFloat(weight)
        };
        setWeightHistory(prev => [...prev, entry]);
    };

    const getLogsByDate = (dateString) => {
        // dateString YYYY-MM-DD
        return logs.filter(log => log.timestamp.startsWith(dateString));
    };

    const getLatestWeight = () => {
        if (weightHistory.length === 0) return null;
        return weightHistory[weightHistory.length - 1].weight;
    };

    const value = {
        logs,
        weightHistory,
        addLog,
        addWeight,
        getLogsByDate,
        getLatestWeight
    };

    return (
        <DataContext.Provider value={value}>
            {children}
        </DataContext.Provider>
    );
}
