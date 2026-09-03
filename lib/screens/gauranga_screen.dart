// screens/gauranga_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_theme.dart';
import '../models/gauranga_stotra_verse.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import '../widgets/app_menu_sheet.dart';

/// The Śrī Śrīmad Gaurāṅga-līlā-smaraṇa-maṅgala-stotram by Śrīla
/// Bhaktivinoda Ṭhākura (104 verses). The list pane shows the English
/// translation; the Devanāgarī, IAST transliteration, and translation are
/// revealed in the swipeable detail reader.
class GaurangaScreen extends StatefulWidget {
  final BssRepository repository;

  const GaurangaScreen({super.key, required this.repository});

  @override
  State<GaurangaScreen> createState() => _GaurangaScreenState();
}

class _GaurangaScreenState extends State<GaurangaScreen> {
  late Future<List<GaurangaStotraVerse>> _future;
  List<GaurangaStotraVerse> _verses = const [];

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getGaurangaStotram().then((v) {
      if (mounted) setState(() => _verses = v);
      return v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Śrī Gaurāṅga stotram'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: Translations.t('menu.share'),
            onPressed: _verses.isEmpty ? null : _shareAll,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: Translations.t('common.menu'),
            onPressed: _openAppMenu,
          ),
        ],
      ),
      floatingActionButton: _verses.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GaurangaVerseDetailScreen(
                      verses: _verses,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              tooltip: 'Read stotram',
              child: const Icon(Icons.auto_stories),
            )
          : null,
      body: FutureBuilder<List<GaurangaStotraVerse>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final verses = snapshot.data ?? const [];
          if (verses.isEmpty) {
            return Center(child: Text('Coming soon'));
          }

          return SafeArea(
            top: false,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final v = verses[index];
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GaurangaVerseDetailScreen(
                            verses: _verses,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '(${v.ref})',
                                style: TextStyle(
                                  color: goldColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  v.heading,
                                  style: TextStyle(
                                    color: goldColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            v.translationEn,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _shareAll() {
    final buffer = StringBuffer();
    for (final v in _verses) {
      buffer.writeln('(${v.ref}) ${v.heading}\n');
      if (v.transliteration.isNotEmpty) {
        buffer.writeln('${v.transliteration}\n');
      }
      buffer.writeln('${v.translationEn}\n');
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

/// Full-screen reading mode for the Gaurāṅga stotram: swipeable pages,
/// one verse per page, showing Devanāgarī, IAST, and English translation.
class GaurangaVerseDetailScreen extends StatefulWidget {
  final List<GaurangaStotraVerse> verses;
  final int initialIndex;

  const GaurangaVerseDetailScreen({
    super.key,
    required this.verses,
    this.initialIndex = 0,
  });

  @override
  State<GaurangaVerseDetailScreen> createState() =>
      _GaurangaVerseDetailScreenState();
}

class _GaurangaVerseDetailScreenState
    extends State<GaurangaVerseDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex.clamp(0, widget.verses.length - 1);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final subText = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Śrī Gaurāṅga stotram'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.verses.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final v = widget.verses[index];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '(${v.ref})',
                          style: TextStyle(
                            color: goldColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            v.heading,
                            style: TextStyle(
                              color: goldColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (v.devanagari.isNotEmpty) ...[
                      Text(
                        v.devanagari,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.9,
                          color: isDark
                              ? BssColors.darkOakSanskritText
                              : BssColors.sanskritText,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (v.transliteration.isNotEmpty) ...[
                      Text(
                        v.transliteration,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? BssColors.darkOakSanskritText
                              : BssColors.sanskritText,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      v.translationEn,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: isDark
                            ? BssColors.darkOakText
                            : BssColors.darkText,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: goldColor.withAlpha(76)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentPage == 0
                        ? null
                        : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            ),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                    style: TextButton.styleFrom(foregroundColor: goldColor),
                  ),
                  Text(
                    '${_currentPage + 1} / ${widget.verses.length}',
                    style: TextStyle(color: subText, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: _currentPage == widget.verses.length - 1
                        ? null
                        : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            ),
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                    style: TextButton.styleFrom(foregroundColor: goldColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}