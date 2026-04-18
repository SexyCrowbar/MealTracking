import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_profile.dart';
import 'onboarding_provider_setup.dart';

class OnboardingWelcome extends ConsumerWidget {
  const OnboardingWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpace.xl),
              const Icon(Icons.restaurant_menu,
                  color: AppColors.primary, size: 72),
              const SizedBox(height: AppSpace.md),
              Text(
                t.onboarding_welcome_title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                t.onboarding_welcome_body,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _ProviderCard(
                title: t.onboarding_get_started_gemini,
                subtitle: t.provider_desc_gemini,
                badge: t.onboarding_recommended,
                onTap: () => _go(context, AiProvider.gemini),
              ),
              const SizedBox(height: AppSpace.md),
              _ProviderCard(
                title: t.onboarding_get_started_groq,
                subtitle: t.provider_desc_groq,
                onTap: () => _go(context, AiProvider.groq),
              ),
              const SizedBox(height: AppSpace.md),
              TextButton(
                onPressed: () => _skip(context, ref),
                child: Text(t.onboarding_skip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, String provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingProviderSetup(provider: provider),
      ),
    );
  }

  Future<void> _skip(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.onboarding_skip),
        content: Text(t.onboarding_skip_msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.ok),
          ),
        ],
      ),
    );
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingProfile()),
      );
    }
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
