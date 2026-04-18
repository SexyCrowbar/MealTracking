import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../domain/providers/app_providers.dart';
import '../../food/off_client.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key, this.prefill});

  final OffProduct? prefill;

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _gi = TextEditingController();
  final _servingG = TextEditingController(text: '100');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    if (p != null) {
      _name.text = p.brand == null ? p.name : '${p.brand} ${p.name}';
      _applyServing(100);
    }
    _servingG.addListener(_onServingChanged);
  }

  void _onServingChanged() {
    final grams = double.tryParse(_servingG.text.trim());
    if (grams == null || grams <= 0) return;
    _applyServing(grams);
  }

  void _applyServing(double grams) {
    final p = widget.prefill;
    if (p == null) return;
    final factor = grams / 100.0;
    _kcal.text = (p.kcalPer100g * factor).round().toString();
    _protein.text = _format(p.proteinPer100g, factor);
    _carbs.text = _format(p.carbsPer100g, factor);
    _fat.text = _format(p.fatPer100g, factor);
  }

  static String _format(double? per100, double factor) {
    if (per100 == null) return '';
    final v = per100 * factor;
    return v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _servingG.removeListener(_onServingChanged);
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _gi.dispose();
    _servingG.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.manual_entry)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.md),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: t.food_name),
          ),
          const SizedBox(height: AppSpace.sm),
          if (widget.prefill != null) ...[
            TextField(
              controller: _servingG,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.serving_size_g,
                helperText: t.per_100g,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
          ],
          TextField(
            controller: _kcal,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t.calories),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _protein,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.protein),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: TextField(
                  controller: _carbs,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.carbs),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: TextField(
                  controller: _fat,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.fat),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: _gi,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t.glycemic_index),
          ),
          const SizedBox(height: AppSpace.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(t.add_meal_btn),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final name = _name.text.trim();
    final kcal = int.tryParse(_kcal.text.trim());
    if (name.isEmpty || kcal == null || kcal < 0) {
      showAppSnack(context, t.provide_text_image);
      return;
    }
    setState(() => _saving = true);
    await ref.read(mealsRepoProvider).insertManual(
          name: name,
          calories: kcal,
          protein: double.tryParse(_protein.text.trim()),
          carbs: double.tryParse(_carbs.text.trim()),
          fat: double.tryParse(_fat.text.trim()),
          glycemicIndex: int.tryParse(_gi.text.trim()),
        );
    if (!mounted) return;
    showAppSnack(context, t.meal_added);
    Navigator.of(context).pop();
  }
}
