// screens/works_menu_screen.dart
import 'package:flutter/material.dart';

import '../app_theme.dart';

/// A single selectable "work" (scripture) inside a personality branch.
class WorkEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  const WorkEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

/// Presents the list of works belonging to one spiritual personality.
/// Tapping a work navigates into its reader. Used when a branch contains
/// more than one scripture (e.g. Caitanya: asta-kaliya + Gauranga stotrams;
/// Rādhā–Kṛṣṇa: asta-kaliya stotram + Bhavanasara-sangraha).
class WorksMenuScreen extends StatelessWidget {
  final String title;
  final List<WorkEntry> works;

  const WorksMenuScreen({
    super.key,
    required this.title,
    required this.works,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final subTextCol = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: works.length,
          itemBuilder: (context, index) {
            final work = works[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: goldColor.withAlpha(50)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Icon(work.icon, color: goldColor, size: 30),
                title: Text(
                  work.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    work.subtitle,
                    style: TextStyle(color: subTextCol, fontSize: 13),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: goldColor.withAlpha(200),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: work.builder),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}