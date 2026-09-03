// screens/bss2_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_theme.dart';
import '../models/bss2.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import '../widgets/app_menu_sheet.dart';

/// The second Bhavanāsāra-saṅgraha edition (translation by Haricaraṇa Dāsa),
/// read continuously, mirroring the Bhanu Swami time-of-day reader.
///
/// The whole book is one scrolling feed: the period, section (time-window)
/// and chapter headings appear inline in the middle of the text, with each
/// chapter's verses flowing beneath them. Tapping a verse opens a swipeable
/// detail reader with the full Devanāgarī, IAST transliteration, English
/// translation, and source reference.
class Bss2Screen extends StatefulWidget {
  final BssRepository repository;

  const Bss2Screen({super.key, required this.repository});

  @override
  State<Bss2Screen> createState() => _Bss2ScreenState();
}

class _Bss2ScreenState extends State<Bss2Screen> {
  late Future<List<Bs2FeedRow>> _future;
  List<Bs2FeedRow> _feed = const [];

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getBs2Feed().then((rows) {
      if (mounted) setState(() => _feed = rows);
      return rows;
    });
  }

  void _shareAll() {
    final buffer = StringBuffer()..writeln('Bhāvanāsāra-saṅgraha\n');
    for (final row in _feed) {
      switch (row.type) {
        case Bs2RowType.periodHeading:
        case Bs2RowType.sectionHeading:
        case Bs2RowType.chapterHeading:
          buffer.writeln('${row.title}\n');
          break;
        case Bs2RowType.verse:
          final v = row.verse!;
          if (v.transliteration.isNotEmpty) {
            buffer.writeln('${v.transliteration}\n');
          }
          buffer.writeln('${v.translation}\n');
          if (v.reference.isNotEmpty) buffer.writeln('— ${v.reference}\n');
          break;
      }
    }
    buffer.write('Lila Smarana');
    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _openVerseDetail(Bs2Verse verse) {
    final verses = _feed
        .where((r) => r.type == Bs2RowType.verse)
        .map((r) => r.verse!)
        .toList();
    final initialIndex = verses.indexWhere((v) => v.id == verse.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Bss2VerseDetailScreen(
          verses: verses,
          initialIndex: initialIndex < 0 ? 0 : initialIndex,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final subText = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bhāvanāsāra-saṅgraha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: Translations.t('menu.share'),
            onPressed: _feed.isEmpty ? null : _shareAll,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: Translations.t('common.menu'),
            onPressed: _openAppMenu,
          ),
        ],
      ),
      body: FutureBuilder<List<Bs2FeedRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final feed = snapshot.data ?? const [];
          if (feed.isEmpty) {
            return const Center(child: Text('Coming soon'));
          }
          return SafeArea(
            top: false,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final row = feed[index];
                switch (row.type) {
                  case Bs2RowType.periodHeading:
                    return _headingRow(
                      row.title,
                      goldColor,
                      textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      topSpace: index == 0 ? 0 : 24,
                    );
                  case Bs2RowType.sectionHeading:
                    return _headingRow(
                      row.title,
                      textColor,
                      textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      topSpace: 20,
                    );
                  case Bs2RowType.chapterHeading:
                    return _headingRow(
                      row.title,
                      goldColor,
                      textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      topSpace: 16,
                    );
                  case Bs2RowType.verse:
                    return _verseCard(row.verse!, goldColor, textColor, subText,
                        () => _openVerseDetail(row.verse!));
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _headingRow(
    String title,
    Color accent,
    Color textColor, {
    required double fontSize,
    required FontWeight fontWeight,
    required double topSpace,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: topSpace, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: accent,
        ),
      ),
    );
  }

  Widget _verseCard(
    Bs2Verse verse,
    Color goldColor,
    Color textColor,
    Color subText,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: goldColor.withAlpha(50)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                verse.translation,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (verse.reference.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  verse.reference,
                  style: TextStyle(
                    color: subText,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Swipeable full reading mode for the second BSS: one verse per page,
/// showing Devanāgarī, IAST transliteration, English translation, and the
/// source reference.
class Bss2VerseDetailScreen extends StatefulWidget {
  final List<Bs2Verse> verses;
  final int initialIndex;

  const Bss2VerseDetailScreen({
    super.key,
    required this.verses,
    this.initialIndex = 0,
  });

  @override
  State<Bss2VerseDetailScreen> createState() => _Bss2VerseDetailScreenState();
}

class _Bss2VerseDetailScreenState extends State<Bss2VerseDetailScreen> {
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
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bhāvanāsāra-saṅgraha'),
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
                    if (v.reference.isNotEmpty)
                      Text(
                        v.reference,
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (v.reference.isNotEmpty) const SizedBox(height: 16),
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
                      v.translation,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: textColor,
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