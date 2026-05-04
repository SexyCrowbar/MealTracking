import 'package:drift/drift.dart';

@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  RealColumn get goalWeightKg => real()();
  TextColumn get activityLevel => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MealRow')
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get time => text()();
  TextColumn get name => text()();
  IntColumn get calories => integer()();
  RealColumn get protein => real().nullable()();
  RealColumn get carbs => real().nullable()();
  RealColumn get fat => real().nullable()();
  IntColumn get glycemicIndex => integer().nullable()();
  RealColumn get healthScore => real().nullable()();
  TextColumn get allergenWarning => text().nullable()();
  RealColumn get estimatedInsulin => real().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get provider => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get analysisLatencyMs => integer().nullable()();
  IntColumn get savedMealId => integer().nullable()();
  TextColumn get extrasJson => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SavedMealRow')
class SavedMeals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get totalWeightG => real()();
  IntColumn get caloriesPer100g => integer()();
  RealColumn get proteinPer100g => real().nullable()();
  RealColumn get carbsPer100g => real().nullable()();
  RealColumn get fatPer100g => real().nullable()();
  IntColumn get glycemicIndex => integer().nullable()();
  IntColumn get totalCalories => integer()();
  RealColumn get totalProtein => real().nullable()();
  RealColumn get totalCarbs => real().nullable()();
  RealColumn get totalFat => real().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get model => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SavedMealIngredientRow')
class SavedMealIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get savedMealId =>
      integer().references(SavedMeals, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get description => text()();
  RealColumn get grams => real()();
}

@DataClassName('WeightEntryRow')
class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().unique()();
  RealColumn get weightKg => real()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AnalysisQueueRow')
class AnalysisQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get textDescription => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get resultJson => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get processedAt => dateTime().nullable()();
}

@DataClassName('SettingsRow')
class SettingsKv extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
