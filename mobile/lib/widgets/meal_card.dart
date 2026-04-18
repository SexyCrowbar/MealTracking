import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../domain/models/meal.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onDelete,
  });

  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _emoji {
    switch (meal.source) {
      case 'ai_photo':
      case 'ai_photo_text':
        return '📷';
      case 'manual':
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        onLongPress: onDelete,
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
                child: Center(
                  child: Text(_emoji, style: const TextStyle(fontSize: 22)),
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
                      meal.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QueuedMealCard extends StatelessWidget {
  const QueuedMealCard({
    super.key,
    this.label,
    this.failed = false,
    this.onRetry,
    this.onDelete,
  });

  final String? label;
  final bool failed;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = failed ? AppColors.accentRed : AppColors.accentOrange;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: color),
      ),
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
              child: Center(
                child: Text(failed ? '⚠️' : '⏳',
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (failed && onRetry != null)
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}
