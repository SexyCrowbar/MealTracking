import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { UserProvider, useUser } from './contexts/UserContext';
import { DataProvider } from './contexts/DataContext';
import Layout from './components/Layout';

// Screens - we'll create these next
import UserInfoScreen from './screens/UserInfoScreen';
import PlanScreen from './screens/PlanScreen';
import MealRecordingScreen from './screens/MealRecordingScreen';
import ProgressScreen from './screens/ProgressScreen';

import SettingsScreen from './screens/SettingsScreen';
import HistoryScreen from './screens/HistoryScreen';

function AppRoutes() {
  const { isInitialized } = useUser();

  if (!isInitialized) {
    return (
      <Routes>
        <Route path="/setup" element={<UserInfoScreen />} />
        <Route path="*" element={<Navigate to="/setup" replace />} />
      </Routes>
    );
  }

  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Navigate to="/plan" replace />} />
        <Route path="plan" element={<PlanScreen />} />
        <Route path="record" element={<MealRecordingScreen />} />

        <Route path="history" element={<HistoryScreen />} />
        <Route path="progress" element={<ProgressScreen />} />
        <Route path="settings" element={<SettingsScreen />} />
        <Route path="profile" element={<UserInfoScreen isEditMode />} />
      </Route>
      <Route path="*" element={<Navigate to="/plan" replace />} />
    </Routes>
  );
}

function App() {
  return (
    <UserProvider>
      <DataProvider>
        <BrowserRouter>
          <AppRoutes />
        </BrowserRouter>
      </DataProvider>
    </UserProvider>
  );
}

export default App;
