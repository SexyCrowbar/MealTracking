import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/db/database.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import 'log_portion_screen.dart';
import 'saved_meal_create_screen.dart';

class SavedMealsLibraryScreen extends ConsumerStatefulWidget {
  const SavedMealsLibraryScreen({super.key});

  @override
  ConsumerState<SavedMealsLibraryScreen> createState() =>
      _SavedMealsLibraryScreenState();
}

class _SavedMealsLibraryScreenState
    extends ConsumerState<SavedMealsLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final mealsAsync = ref.watch(savedMealsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.saved_meals),
        actions: [
          IconButton(
            tooltip: t.new_saved_meal,
            icon: const Icon(Icons.add),
            onPressed: () => _openCreate(context),
          ),
        ],
      ),
      body: mealsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (rows) {
          if (rows.isEmpty) {
            return _EmptyState(onCreate: () => _openCreate(context));
          }
          final filtered = _query.isEmpty
              ? rows
              : rows
                  .where((r) =>
                      r.name.toLowerCase().contains(_query.toLowerCase()))
                  .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted),
                    labelText: t.search_saved_meals,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.md, 0, AppSpace.md, AppSpace.md),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final row = filtered[i];
                    return _SavedMealCard(
                      meal: row,
                      onTap: () => _openLogPortion(context, row),
                      onEdit: () => _openEdit(context, row.id),
                      onDelete: () => _confirmDelete(context, row),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SavedMealCreateScreen(),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, int id) async {
    final loaded =
        await ref.read(savedMealsRepoProvider).getWithIngredients(id);
    if (loaded == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavedMealCreateScreen(editing: loaded),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SavedMealRow row) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: t.confirm_delete_saved_meal,
      message: row.name,
      confirmLabel: t.confirm,
      cancelLabel: t.cancel,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(savedMealsRepoProvider).delete(row.id);
    if (!context.mounted) return;
    showAppSnack(context, t.saved_meal_deleted);
  }

  Future<void> _openLogPortion(
      BuildContext context, SavedMealRow row) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogPortionScreen(meal: row),
      ),
    );
  }
}

class _SavedMealCard extends StatelessWidget {
  const _SavedMealCard({
    required this.meal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedMealRow meal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(AppRadius.md - 2),
                ),
                child: const Center(
                  child: Text('🥘', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.kcal_per_100g(meal.caloriesPer100g),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: 'edit', child: Text(t.edit_recipe)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(t.saved_meal_deleted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥘', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpace.md),
            Text(
              t.saved_meals_empty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpace.md),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(t.saved_meals_empty_cta),
            ),
          ],
        ),
      ),
    );
  }
}

