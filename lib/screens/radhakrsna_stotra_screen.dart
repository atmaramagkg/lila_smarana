// screens/radhakrsna_stotra_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_theme.dart';
import '../models/radhakrsna_stotra_verse.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import '../widgets/app_menu_sheet.dart';

/// The Śrī Rādhā-Kṛṣṇayoḥ Aṣṭa-kālīya-līlā Smaraṇa-maṅgala-śrotram:
/// eight periods of the divine couple's daily routine. Each period carries
/// a romanized Sanskrit verse, a word-by-word gloss, and an English prose
/// translation. The list pane shows the translation; verse and word
/// meanings appear in the swipeable detail reader.
class RadhaKrsnaStotraScreen extends StatefulWidget {
  final BssRepository repository;

  const RadhaKrsnaStotraScreen({super.key, required this.repository});

  @override
  State<RadhaKrsnaStotraScreen> createState() => _RadhaKrsnaStotraScreenState();
}

class _RadhaKrsnaStotraScreenState extends State<RadhaKrsnaStotraScreen> {
  late Future<List<RadhaKrsnaStotraVerse>> _future;
  List<RadhaKrsnaStotraVerse> _verses = const [];

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getRadhaKrsnaStotram().then((v) {
      if (mounted) setState(() => _verses = v);
      return v;
    });
  }

  /// Strips a leading/trailing double-quote (present around translations
  /// in the printed source) before display.
  static String _clean(String s) {
    var out = s.trim();
    if (out.startsWith('"')) out = out.substring(1);
    if (out.endsWith('"')) out = out.substring(0, out.length - 1);
    return out.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rādhā-Kṛṣṇayoḥ stotram'),
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
                    builder: (_) => RadhaKrsnaStotraDetailScreen(
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
      body: FutureBuilder<List<RadhaKrsnaStotraVerse>>(
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
                          builder: (_) => RadhaKrsnaStotraDetailScreen(
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
                                v.period,
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
                            _clean(v.translationEn),
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
      buffer.writeln('${v.heading}\n');
      if (v.verse.isNotEmpty) buffer.writeln('${v.verse}\n');
      if (v.wordMeanings.isNotEmpty) {
        buffer.writeln('${v.wordMeanings}\n');
      }
      buffer.writeln('${_clean(v.translationEn)}\n');
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

/// Full-screen reading mode for the Rādhā–Kṛṣṇayoḥ stotram: swipeable
/// pages, one period per page, showing the Sanskrit verse, word-by-word
/// meanings, and English translation.
class RadhaKrsnaStotraDetailScreen extends StatefulWidget {
  final List<RadhaKrsnaStotraVerse> verses;
  final int initialIndex;

  const RadhaKrsnaStotraDetailScreen({
    super.key,
    required this.verses,
    this.initialIndex = 0,
  });

  @override
  State<RadhaKrsnaStotraDetailScreen> createState() =>
      _RadhaKrsnaStotraDetailScreenState();
}

class _RadhaKrsnaStotraDetailScreenState
    extends State<RadhaKrsnaStotraDetailScreen> {
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

  static String _clean(String s) {
    var out = s.trim();
    if (out.startsWith('"')) out = out.substring(1);
    if (out.endsWith('"')) out = out.substring(0, out.length - 1);
    return out.trim();
  }

  /// Parses the stored word-meaning gloss (`word --meaning; word --meaning; ...`)
  /// into ordered `(sanskrit, translation)` pairs. Each semicolon-delimited
  /// gloss carries exactly one `--`, so a single split is safe.
  static List<(String, String)> _parseGlosses(String gloss) {
    final pairs = <(String, String)>[];
    for (final raw in gloss.split(';')) {
      final token = raw.trim();
      if (token.isEmpty) continue;
      final idx = token.indexOf('--');
      if (idx < 0) {
        pairs.add(('', token));
        continue;
      }
      pairs.add((token.substring(0, idx).trim(), token.substring(idx + 2).trim()));
    }
    return pairs;
  }

  /// Builds the inline spans for the word-by-word gloss: each Sanskrit word
  /// is set in italic with the accent colour, and its English translation in
  /// the plain body colour, separated from the next gloss by a `;`.
  static List<InlineSpan> _glossSpans(
    List<(String, String)> pairs,
    bool isDark,
  ) {
    final sanskritColor =
        isDark ? BssColors.darkOakSanskritText : BssColors.sanskritText;
    final bodyColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final sepColor = isDark ? BssColors.darkOakSubText : BssColors.subText;

    final spans = <InlineSpan>[];
    for (var i = 0; i < pairs.length; i++) {
      final (sanskrit, translation) = pairs[i];
      if (sanskrit.isNotEmpty) {
        spans.add(
          TextSpan(
            text: sanskrit,
            style: TextStyle(
              color: sanskritColor,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        if (translation.isNotEmpty) {
          spans.add(const TextSpan(text: ' — '));
        }
      }
      if (translation.isNotEmpty) {
        spans.add(TextSpan(text: translation, style: TextStyle(color: bodyColor)));
      }
      if (i < pairs.length - 1) {
        spans.add(TextSpan(text: ';  ', style: TextStyle(color: sepColor)));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final subText = isDark ? BssColors.darkOakSubText : BssColors.subText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rādhā-Kṛṣṇayoḥ stotram'),
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
                    Text(
                      v.heading,
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      v.verse,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark
                            ? BssColors.darkOakSanskritText
                            : BssColors.sanskritText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (v.wordMeanings.isNotEmpty) ...[
                      Text.rich(
                        TextSpan(children: _glossSpans(_parseGlosses(v.wordMeanings), isDark)),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? BssColors.darkOakSanskritText
                              : BssColors.sanskritText,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      _clean(v.translationEn),
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