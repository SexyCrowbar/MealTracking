import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import 'barcode_scanner_screen.dart';
import 'camera_screen.dart';
import 'describe_screen.dart';
import 'manual_entry_screen.dart';
import 'saved_meal_create_screen.dart';
import 'saved_meals_library_screen.dart';

class RecordHomeScreen extends ConsumerWidget {
  const RecordHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpace.md),
      children: [
        Text(t.screen_title_record,
            style: Theme.of(context).appBarTheme.titleTextStyle),
        const SizedBox(height: AppSpace.lg),
        _BigCard(
          icon: Icons.camera_alt_outlined,
          title: t.ai_analysis,
          subtitle: t.photo_prompt,
          onTap: () => _openCamera(context),
        ),
        const SizedBox(height: AppSpace.md),
        _BigCard(
          icon: Icons.photo_library_outlined,
          title: t.open_gallery,
          subtitle: t.or_pick_from_gallery,
          onTap: () => _pickGallery(context),
        ),
        const SizedBox(height: AppSpace.md),
        _BigCard(
          icon: Icons.text_fields_outlined,
          title: t.describe_only_title,
          subtitle: t.describe_only_subtitle,
          onTap: () => _openDescribeTextOnly(context),
        ),
        const SizedBox(height: AppSpace.md),
        _BigCard(
          icon: Icons.qr_code_scanner_outlined,
          title: t.scan_barcode,
          subtitle: t.scan_barcode_subtitle,
          onTap: () => _openBarcodeScanner(context),
        ),
        const SizedBox(height: AppSpace.md),
        _BigCard(
          icon: Icons.menu_book_outlined,
          title: t.saved_meals,
          subtitle: t.saved_meals_log_subtitle,
          onTap: () => _openSavedMealsLibrary(context),
        ),
        const SizedBox(height: AppSpace.md),
        _BigCard(
          icon: Icons.add_circle_outline,
          title: t.new_saved_meal,
          subtitle: t.new_saved_meal_subtitle,
          onTap: () => _openSavedMealCreate(context),
        ),
        const SizedBox(height: AppSpace.md),
        _BigCard(
          icon: Icons.edit_outlined,
          title: t.manual_entry,
          subtitle: t.manual_instead,
          onTap: () => _openManual(context),
        ),
      ],
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final result = await Navigator.of(context).push<File?>(
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (result != null && context.mounted) {
      _openDescribe(context, result);
    }
  }

  Future<void> _pickGallery(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      _openDescribe(context, File(picked.path));
    }
  }

  void _openDescribe(BuildContext context, File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DescribeScreen(image: file)),
    );
  }

  void _openDescribeTextOnly(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DescribeScreen()),
    );
  }

  void _openManual(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
    );
  }

  void _openBarcodeScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
  }

  void _openSavedMealsLibrary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SavedMealsLibraryScreen()),
    );
  }

  void _openSavedMealCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SavedMealCreateScreen()),
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
