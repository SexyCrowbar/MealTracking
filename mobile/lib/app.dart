import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'domain/providers/app_providers.dart';
import 'features/home_shell.dart';
import 'features/onboarding/onboarding_welcome.dart';
import 'l10n/app_localizations.dart';

class MealTrackerApp extends ConsumerStatefulWidget {
  const MealTrackerApp({super.key});

  @override
  ConsumerState<MealTrackerApp> createState() => _MealTrackerAppState();
}

class _MealTrackerAppState extends ConsumerState<MealTrackerApp> {
  @override
  void initState() {
    super.initState();
    // Start the queue worker once the app is up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(queueServiceProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStreamProvider);
    final profileAsync = ref.watch(profileStreamProvider);
    final locale = settingsAsync.value?.locale ?? 'en';

    return MaterialApp(
      title: 'MealTracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: profileAsync.when(
        loading: () => const _Splash(),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        data: (profile) {
          if (profile == null) {
            return const OnboardingWelcome();
          }
          return const HomeShell();
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
