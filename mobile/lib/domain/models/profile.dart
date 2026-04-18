import '../../core/constants.dart';

class Profile {
  const Profile({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goalWeightKg,
    required this.activityLevel,
  });

  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double goalWeightKg;
  final String activityLevel;

  bool get isMale => gender == Gender.male;

  double get activityMultiplier =>
      ActivityLevel.multiplierFor(activityLevel);

  Profile copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    String? activityLevel,
  }) =>
      Profile(
        age: age ?? this.age,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        goalWeightKg: goalWeightKg ?? this.goalWeightKg,
        activityLevel: activityLevel ?? this.activityLevel,
      );
}
