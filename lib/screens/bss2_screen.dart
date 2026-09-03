// screens/bss2_screen.dart
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../app_theme.dart';
import '../models/bss2.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import '../widgets/app_menu_sheet.dart';

/// The second Bhavanāsāra-saṅgraha edition (translation by Haricaraṇa Dāsa),
/// read continuously, mirroring the Bhanu Swami time-of-day reader.
///
/// It carries the same two-level navigation as the classical reader: a row of
/// main-period tabs across the top, and a horizontal bar of section
/// (time-window) chips beneath it. Selecting a period or a section jumps the
/// feed to that point. The whole book is one scrolling feed, with the period,
/// section (time-window) and chapter headings appearing inline, each chapter's
/// verses flowing beneath them. Tapping a verse opens a swipeable detail
/// reader with the full Devanāgarī, IAST transliteration, English translation,
/// and source reference.
class Bss2Screen extends StatefulWidget {
  final BssRepository repository;

  const Bss2Screen({super.key, required this.repository});

  @override
  State<Bss2Screen> createState() => _Bss2ScreenState();
}

/// Converts a range string like `3:36 a.m.—4:24 a.m.` to 24-hour format
/// `03:36–04:24`. Returns the input unchanged if it can't be parsed.
String _to24(String range) {
  final m = RegExp(
          r'(\d{1,2}):(\d{2})\s*([ap])\.?m?\.?\s*[—–-]\s*(\d{1,2}):(\d{2})\s*([ap])\.?m?\.?')
      .firstMatch(range);
  if (m == null) return range;
  int h1 = int.parse(m.group(1)!);
  int h2 = int.parse(m.group(4)!);
  if (m.group(3)!.toLowerCase() == 'p' && h1 != 12) h1 += 12;
  if (m.group(3)!.toLowerCase() == 'a' && h1 == 12) h1 = 0;
  if (m.group(6)!.toLowerCase() == 'p' && h2 != 12) h2 += 12;
  if (m.group(6)!.toLowerCase() == 'a' && h2 == 12) h2 = 0;
  String two(int h) => h.toString().padLeft(2, '0');
  return '${two(h1)}:${m.group(2)}–${two(h2)}:${m.group(5)}';
}

class _Bss2ScreenState extends State<Bss2Screen> {
  late Future<List<Bs2FeedRow>> _future;
  Future<List<Bs2Period>>? _periodsFuture;
  List<Bs2FeedRow> _feed = const [];
  List<Bs2Period> _periods = const [];
  List<Bs2Section> _sections = const [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  int _selectedPeriodId = -1;
  int _selectedSectionId = -1;
  bool _sectionsLoading = false;

  /// Running chapter number (1-based across the whole book) and the feed
  /// index of each chapter heading, keyed by chapter id. Built from the feed.
  final Map<int, int> _chapterNumbers = {};
  final Map<int, int> _chapterFeedIndexes = {};

  /// Headings (chapter id + running number) of the currently selected section,
  /// in reading order. Drives the right-side Level-3 numbered rail.
  List<Bs2FeedRow> _selectedChapters = const [];

  /// The chapter currently at the top of the feed, highlighted in the rail.
  int _currentChapterId = -1;

  @override
  void initState() {
    super.initState();
    final repo = widget.repository;
    _future = repo.getBs2Feed().then((rows) {
      if (mounted) {
        setState(() {
          _feed = rows;
          _buildChapterIndex();
        });
      }
      return rows;
    });
    _periodsFuture = repo.getBs2Periods().then((periods) {
      if (mounted) {
        setState(() {
          _periods = periods;
          _selectedPeriodId =
              periods.isEmpty ? -1 : periods.first.id;
        });
        if (periods.isNotEmpty) _loadSections(periods.first.id);
      }
      return periods;
    });
    _itemPositionsListener.itemPositions.addListener(_updateCurrentChapter);
  }

  /// Tracks the chapter whose heading is nearest the top of the feed so the
  /// right rail can highlight the current reading position.
  void _updateCurrentChapter() {
    final positions = _itemPositionsListener.itemPositions.value
        .where((p) => p.index >= 0 && p.index < _feed.length)
        .toList();
    if (positions.isEmpty) return;
    // Topmost visible item.
    positions.sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    final first = positions.first.index;
    int selected = -1;
    for (int i = first; i >= 0; i--) {
      final row = _feed[i];
      if (row.type == Bs2RowType.chapterHeading) {
        selected = row.chapterId;
        break;
      }
    }
    if (selected != _currentChapterId) {
      setState(() => _currentChapterId = selected);
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_updateCurrentChapter);
    super.dispose();
  }

  Future<void> _loadSections(int periodId) async {
    setState(() => _sectionsLoading = true);
    final sections = await widget.repository.getBs2Sections(periodId);
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _sectionsLoading = false;
      // Preserve selection if it still belongs to this period.
      if (!sections.any((s) => s.id == _selectedSectionId)) {
        _selectedSectionId = sections.isEmpty ? -1 : sections.first.id;
      }
    });
    _onSectionTapped(_selectedSectionId);
  }

  /// Walks the loaded feed, assigning a running (1-based) chapter number to each
  /// chapter heading and recording its feed index.
  void _buildChapterIndex() {
    _chapterNumbers.clear();
    _chapterFeedIndexes.clear();
    int running = 0;
    for (int i = 0; i < _feed.length; i++) {
      final row = _feed[i];
      if (row.type == Bs2RowType.chapterHeading) {
        running++;
        _chapterNumbers[row.chapterId] = running;
        _chapterFeedIndexes[row.chapterId] = i;
      }
    }
    _rebuildSelectedChapters();
  }

  /// The chapter-heading rows of the currently selected section, used by the
  /// right-side Level-3 numbered rail.
  void _rebuildSelectedChapters() {
    _selectedChapters = _feed
        .where((r) =>
            r.type == Bs2RowType.chapterHeading &&
            r.sectionId == _selectedSectionId)
        .toList();
  }

  void _onMainPeriodTapped(int periodId) {
    if (periodId == _selectedPeriodId) return;
    setState(() => _selectedPeriodId = periodId);
    _loadSections(periodId);
    _scrollToPeriod(periodId);
  }

  void _onSectionTapped(int sectionId) {
    setState(() {
      _selectedSectionId = sectionId;
      _rebuildSelectedChapters();
    });
    _scrollToSection(_selectedSectionId);
  }

  void _scrollToChapter(int chapterId) {
    final index = _chapterFeedIndexes[chapterId];
    if (index == null) return;
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.0,
    );
  }

  void _scrollToPeriod(int periodId) {
    final index = _feed.indexWhere(
        (r) => r.periodId == periodId && r.type == Bs2RowType.periodHeading);
    if (index >= 0) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void _scrollToSection(int sectionId) {
    final index = _feed.indexWhere(
        (r) => r.sectionId == sectionId && r.type == Bs2RowType.sectionHeading);
    if (index >= 0) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
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
            child: Column(
              children: [
                _buildNavigationBar(isDark, goldColor, textColor),
                Expanded(
                  child: Stack(
                    children: [
                      ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _itemPositionsListener,
                        padding:
                            const EdgeInsets.fromLTRB(20, 12, 48, 28),
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
                              return _verseCard(row.verse!, goldColor,
                                  textColor, subText,
                                  () => _openVerseDetail(row.verse!));
                          }
                        },
                      ),
                      // Level 3: right-side numbered chapter rail for the
                      // selected section.
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: _buildChapterRail(isDark, goldColor, textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Two-level navigation mirroring the classical reader: a row of main-period
  /// tabs, and a horizontal chip bar of the selected period's sections
  /// (time-windows). Selecting either jumps the feed to that point.
  Widget _buildNavigationBar(
      bool isDark, Color goldColor, Color textColor) {
    final cardBg = isDark ? BssColors.darkOakCard : BssColors.parchmentCard;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? BssColors.darkOakBg : BssColors.parchmentBg,
        border: Border(
            bottom: BorderSide(color: goldColor.withAlpha(76), width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level 1: main-period tabs.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 32,
              child: FutureBuilder<List<Bs2Period>>(
                future: _periodsFuture,
                builder: (context, snapshot) {
                  final periods = snapshot.data ?? _periods;
                  if (periods.isEmpty) return const SizedBox.shrink();
                  return Row(
                    children: [
                      for (int index = 0; index < periods.length; index++)
                        Expanded(
                          child: Builder(builder: (context) {
                            final period = periods[index];
                            final isSelected =
                                (period.id == _selectedPeriodId);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: GestureDetector(
                                onTap: () =>
                                    _onMainPeriodTapped(period.id),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected ? goldColor : cardBg,
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                        color: goldColor, width: 1.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? (isDark
                                                ? BssColors.darkOakBg
                                                : Colors.white)
                                            : textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Level 2: section (time-window) chips for the selected period.
          if (_sections.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sections.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  final isSelected =
                      (section.id == _selectedSectionId);
                  return GestureDetector(
                    onTap: () => _onSectionTapped(section.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? goldColor.withAlpha(64) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                            color: isSelected
                                ? goldColor
                                : goldColor.withAlpha(76),
                            width: 1.0),
                      ),
                      child: Center(
                        child: Text(
                          section.timeRange.isNotEmpty
                              ? _to24(section.timeRange)
                              : section.title,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? goldColor : textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (_sectionsLoading) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: goldColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Level 3: a slim vertical rail on the right edge showing the chapters of
  /// the selected section as small numbered buttons (global running numbers).
  /// Tapping a number scrolls the feed to that chapter.
  Widget _buildChapterRail(bool isDark, Color goldColor, Color textColor) {
    final railBg = isDark ? BssColors.darkOakBg : BssColors.parchmentBg;
    final chapters = _selectedChapters;
    if (chapters.isEmpty) return const SizedBox.shrink();
    return Container(
      width: 34,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(
          left: BorderSide(color: goldColor.withAlpha(60), width: 1.0),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final row = chapters[index];
          final chapterId = row.chapterId;
          final number = _chapterNumbers[chapterId] ?? index + 1;
          final isCurrent = _currentChapterId == chapterId;
          return GestureDetector(
            onTap: () => _scrollToChapter(chapterId),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              height: 20,
              decoration: BoxDecoration(
                color: isCurrent ? goldColor.withAlpha(64) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? goldColor : textColor,
                ),
              ),
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