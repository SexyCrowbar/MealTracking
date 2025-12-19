import React from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { Calendar, PlusCircle, BarChart2, Settings } from 'lucide-react';
import styles from './Layout.module.css';

export default function Layout() {
    return (
        <div className="layout">
            <main className="container animate-fade-in">
                <Outlet />
            </main>

            <nav className={styles.navbar}>
                <div className={styles.navContainer}>
                    <NavLink to="/plan" className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}>
                        <Calendar size={24} />
                        <span>Plan</span>
                    </NavLink>

                    <NavLink to="/record" className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}>
                        <PlusCircle size={24} />
                        <span>Record</span>
                    </NavLink>

                    <NavLink to="/progress" className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}>
                        <BarChart2 size={24} />
                        <span>Progress</span>
                    </NavLink>

                    <NavLink to="/settings" className={({ isActive }) => `${styles.navItem} ${isActive ? styles.active : ''}`}>
                        <Settings size={24} />
                        <span>Settings</span>
                    </NavLink>
                </div>
            </nav>
        </div>
    );
}
