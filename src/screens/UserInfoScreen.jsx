import React, { useState } from 'react';
import { useUser } from '../contexts/UserContext';
import { useNavigate } from 'react-router-dom';

const ACTIVITY_LEVELS = [
    { value: 'sedentary', label: 'Sedentary (Office job)' },
    { value: 'light', label: 'Lightly Active (1-3 days/week)' },
    { value: 'moderate', label: 'Moderately Active (3-5 days/week)' },
    { value: 'active', label: 'Very Active (6-7 days/week)' },
    { value: 'very_active', label: 'Extra Active (Physically demanding)' }
];

export default function UserInfoScreen({ isEditMode = false }) {
    const { profile, updateProfile, isInitialized } = useUser();
    const navigate = useNavigate();
    const [formData, setFormData] = useState(profile);

    const handleChange = (e) => {
        const { name, value } = e.target;
        // parse numbers
        const val = ['age', 'height', 'weight', 'goalWeight'].includes(name)
            ? parseFloat(value)
            : value;

        setFormData(prev => ({ ...prev, [name]: val }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        updateProfile(formData);
        if (!isInitialized) {
            navigate('/plan'); // Redirect to plan after onboarding
        } else if (isEditMode) {
            // feedback or navigate back?
            alert('Profile Updated!');
        }
    };

    return (
        <div className="container animate-fade-in">
            <h1 className="mb-4">{isEditMode ? 'Edit Profile' : 'Welcome!'}</h1>
            <p className="text-muted mb-4">
                {isEditMode
                    ? 'Update your details to recalculate your plan.'
                    : 'Let\'s get to know you to build your personalized plan.'}
            </p>

            <form onSubmit={handleSubmit}>
                <div className="input-group">
                    <label>Name (Optional)</label>
                    <input
                        type="text"
                        name="name"
                        value={formData.name}
                        onChange={handleChange}
                        placeholder="Your Name"
                    />
                </div>

                <div className="flex gap-4">
                    <div className="input-group w-full">
                        <label>Age</label>
                        <input
                            type="number"
                            name="age"
                            value={formData.age}
                            onChange={handleChange}
                            required
                        />
                    </div>
                    <div className="input-group w-full">
                        <label>Sex</label>
                        <select name="sex" value={formData.sex} onChange={handleChange}>
                            <option value="male">Male</option>
                            <option value="female">Female</option>
                        </select>
                    </div>
                </div>

                <div className="flex gap-4">
                    <div className="input-group w-full">
                        <label>Height (cm)</label>
                        <input
                            type="number"
                            name="height"
                            value={formData.height}
                            onChange={handleChange}
                            required
                        />
                    </div>
                    <div className="input-group w-full">
                        <label>Weight (kg)</label>
                        <input
                            type="number"
                            name="weight"
                            value={formData.weight}
                            onChange={handleChange}
                            required
                        />
                    </div>
                </div>

                <div className="input-group">
                    <label>Goal Weight (kg)</label>
                    <input
                        type="number"
                        name="goalWeight"
                        value={formData.goalWeight}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="input-group">
                    <label>Activity Level</label>
                    <select name="activityLevel" value={formData.activityLevel} onChange={handleChange}>
                        {ACTIVITY_LEVELS.map(level => (
                            <option key={level.value} value={level.value}>{level.label}</option>
                        ))}
                    </select>
                </div>

                <button type="submit" className="btn btn-primary w-full mt-4">
                    {isEditMode ? 'Save Changes' : 'Create My Plan'}
                </button>
            </form>
        </div>
    );
}
