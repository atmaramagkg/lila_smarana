import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../core/database/app_database.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import 'reading_screen.dart';
import 'caitanya_screen.dart';
import 'coming_soon_screen.dart';

/// Entry point showing the four spiritual personalities ("branches") of the
/// lila-smarana library. Tapping one enters that personality's content.
/// Caitanya and Rādhā–Kṛṣṇa are populated; Mañjarī and Prabhupāda open a
/// "coming soon" notice until their data is imported.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppDatabase.instance.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Database Error: ${snapshot.error}')),
          );
        }

        final db = snapshot.data;
        if (db == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to load database instance.')),
          );
        }

        return _PersonalityHome(
          repository: BssRepository(db),
        );
      },
    );
  }
}

class _PersonalityHome extends StatelessWidget {
  final BssRepository repository;

  const _PersonalityHome({required this.repository});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextCol = isDark ? BssColors.darkOakSubText : BssColors.subText;

    final personalities = [
      _Personality(
        id: 'caitanya',
        title: Translations.t('personality.caitanya.title'),
        subtitle: Translations.t('personality.caitanya.subtitle'),
        icon: Icons.self_improvement,
        enabled: true,
      ),
      _Personality(
        id: 'radha-krsna',
        title: Translations.t('personality.radha-krsna.title'),
        subtitle: Translations.t('personality.radha-krsna.subtitle'),
        icon: Icons.spa,
        enabled: true,
      ),
      _Personality(
        id: 'manjari',
        title: Translations.t('personality.mañjarī.title'),
        subtitle: Translations.t('personality.mañjarī.subtitle'),
        icon: Icons.local_florist,
        enabled: false,
      ),
      _Personality(
        id: 'prabhupada',
        title: Translations.t('personality.prabhupada.title'),
        subtitle: Translations.t('personality.prabhupada.subtitle'),
        icon: Icons.account_balance,
        enabled: false,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Translations.t('app.title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Translations.t('personality.choose'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: subTextCol),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  for (final personality in personalities) ...[
                    _PersonalityCard(
                      personality: personality,
                      onTap: () => _openPersonality(context, personality),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the reader for the selected personality branch. Only branches
  /// whose data has been imported are enabled.
  void _openPersonality(BuildContext context, _Personality personality) {
    switch (personality.id) {
      case 'caitanya':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CaitanyaScreen(repository: repository),
          ),
        );
      case 'radha-krsna':
        _openRadhaKrsna(context);
      case 'manjari':
      case 'prabhupada':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ComingSoonScreen(
              title: personality.title,
              subtitle: personality.subtitle,
              icon: personality.icon,
            ),
          ),
        );
    }
  }

  /// Rādhā–Kṛṣṇa: open the time-of-day reader (same flow the app used to
  /// jump to directly).
  Future<void> _openRadhaKrsna(BuildContext context) async {
    final current =
        await repository.getCurrentPeriodPair();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          repository: repository,
          initialPeriodId: current?.mainPeriodId ?? 1,
          initialSubPeriodId: current?.subPeriodId,
        ),
      ),
    );
  }
}

class _Personality {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;

  const _Personality({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
  });
}

class _PersonalityCard extends StatelessWidget {
  final _Personality personality;
  final VoidCallback onTap;

  const _PersonalityCard({
    required this.personality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final subTextCol = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: personality.enabled ? goldColor : goldColor.withAlpha(40),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          personality.icon,
          color: goldColor,
          size: 36,
        ),
        title: Text(
          personality.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            personality.subtitle,
            style: TextStyle(color: subTextCol, fontSize: 13),
          ),
        ),
        trailing: Icon(
          personality.enabled
              ? Icons.arrow_forward_ios
              : Icons.lock_outline,
          size: 18,
          color: goldColor.withAlpha(
            personality.enabled ? 200 : 90,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}