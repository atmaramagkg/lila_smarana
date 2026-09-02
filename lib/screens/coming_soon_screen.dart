// screens/coming_soon_screen.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Placeholder shown when a personality branch has no imported content yet.
/// Displays the branch icon, title, subtitle and a soft "coming soon" message
/// so the user understands the intent without it feeling broken.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final subText = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: goldColor.withAlpha(140)),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: subText,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: goldColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goldColor.withAlpha(60)),
                ),
                child: Text(
                  'Content coming soon',
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This branch will become available once source material is imported.',
                style: TextStyle(color: subText, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
