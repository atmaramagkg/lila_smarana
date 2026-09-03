// screens/manjari_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_theme.dart';
import '../models/manjari_chapter.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import '../widgets/app_menu_sheet.dart';

/// The Mañjarī Sevā branch: "Manjari Svarupa Nirupana", an 11-chapter prose
/// treatise by Śrīla Bhaktivinoda Ṭhākura on the identity and loving service
/// of the mañjarīs. The list pane shows the chapter titles; tapping one
/// opens the chapter's full prose text.
class ManjariScreen extends StatefulWidget {
  final BssRepository repository;

  const ManjariScreen({super.key, required this.repository});

  @override
  State<ManjariScreen> createState() => _ManjariScreenState();
}

class _ManjariScreenState extends State<ManjariScreen> {
  late Future<List<ManjariChapter>> _future;
  List<ManjariChapter> _chapters = const [];

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getManjariChapters().then((v) {
      if (mounted) setState(() => _chapters = v);
      return v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final subTextCol = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.t('personality.mañjarī.title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: Translations.t('menu.share'),
            onPressed: _chapters.isEmpty ? null : _shareAll,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: Translations.t('common.menu'),
            onPressed: _openAppMenu,
          ),
        ],
      ),
      body: FutureBuilder<List<ManjariChapter>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapters = snapshot.data ?? const [];
          if (chapters.isEmpty) {
            return Center(child: Text('Coming soon'));
          }

          return SafeArea(
            top: false,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final c = chapters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: goldColor.withAlpha(50)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Icon(Icons.menu_book, color: goldColor),
                    title: Text(
                      c.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _preview(c.content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: subTextCol, fontSize: 13),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: goldColor.withAlpha(200),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ManjariChapterReader(chapter: c),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// A short plain-text preview of the chapter opening.
  static String _preview(String content) {
    final text = content.replaceAll('\n\n', ' ').trim();
    return text.length <= 120 ? text : '${text.substring(0, 120)}…';
  }

  void _shareAll() {
    final buffer = StringBuffer();
    for (final c in _chapters) {
      buffer.writeln('${c.title}\n');
      buffer.writeln('${c.content}\n');
    }
    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _openAppMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Material(
        color: Theme.of(sheetContext).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: AppMenuSheet(onShare: _shareAll),
      ),
    );
  }
}

/// Scrollable prose reader for a single chapter of the treatise. The
/// chapter text is split on blank lines into paragraphs.
class ManjariChapterReader extends StatelessWidget {
  final ManjariChapter chapter;

  const ManjariChapterReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;

    final paragraphs = chapter.content
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: paragraphs.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                chapter.title,
                style: TextStyle(
                  color: goldColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              paragraphs[index],
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: textColor,
              ),
            ),
          );
        },
      ),
    );
  }
}