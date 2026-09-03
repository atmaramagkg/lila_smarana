// screens/about_screen.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/translations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final subText = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        children: [
          Center(
            child: Icon(
              Icons.auto_stories,
              size: 56,
              color: goldColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            Translations.t('app.title'),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sanskrit stotram reader for bhajana practice',
            style: TextStyle(color: subText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const _Section(
            title: 'Branches',
            children: [
              _Row(Icons.self_improvement, 'Śrī Caitanya — Aṣṭa-kālīya līlā-smaraṇa stotram'),
              _Row(Icons.spa, 'Rādhā–Kṛṣṇa — Bhāvanāsara-saṅgraha (time-of-day reader)'),
              _Row(Icons.local_florist, 'Mañjarī Sevā — Mañjarī-svarūpa-nirūpaṇa by Śrīla Bhaktivinoda Ṭhākura'),
              _Row(Icons.account_balance, 'Śrīla Prabhupāda — Śrīla Prabhupāda līlā-smaraṇa'),
            ],
          ),
          const SizedBox(height: 24),
          const _Section(
            title: 'Credits',
            children: [
              _Row(Icons.translate, 'IAST transliterations from Lila Smarana Vidya library'),
              _Row(Icons.book, 'English translations: Bhanu Swami et al.'),
              _Row(Icons.code, 'Bhāvanāsara-saṅgraha database compiled by BSS editors'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: goldColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        for (final child in children) ...[
          child,
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final subText = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: subText),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}
