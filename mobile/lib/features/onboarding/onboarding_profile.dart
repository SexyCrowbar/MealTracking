import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../domain/models/profile.dart';
import '../../domain/providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import '../home_shell.dart';
import '../settings/profile_form.dart';

class OnboardingProfile extends ConsumerWidget {
  const OnboardingProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.onboarding_setup_profile)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.lg),
          children: [
            Text(
              t.onboarding_setup_profile,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            ProfileForm(
              submitLabel: t.onboarding_finish,
              onSubmit: (Profile p) async {
                await ref.read(profileRepoProvider).save(p);
                await ref.read(weightRepoProvider).addEntry(p.weightKg);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
