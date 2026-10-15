// screens/book_chapters_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_theme.dart';
import '../models/book.dart';
import '../models/book_chapter.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';
import '../widgets/app_menu_sheet.dart';
import 'book_reader_screen.dart';

/// Full-text reader for one source scripture: a list of its chapters, each
/// opening a scrollable prose reader. A book whose text has been imported into
/// `book_chapters` is opened here instead of the quoted-passages reader.
class BookChaptersScreen extends StatefulWidget {
  final BssRepository repository;
  final Book book;

  const BookChaptersScreen({
    super.key,
    required this.repository,
    required this.book,
  });

  @override
  State<BookChaptersScreen> createState() => _BookChaptersScreenState();
}

class _BookChaptersScreenState extends State<BookChaptersScreen> {
  late Future<List<BookChapter>> _future;
  List<BookChapter> _chapters = const [];

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getBookChapters(widget.book.id).then((v) {
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
        title: Text(widget.book.title),
        actions: [
          if (widget.book.quoteCount > 0)
            IconButton(
              icon: const Icon(Icons.format_quote_outlined),
              tooltip: Translations.t('book.quoted_passages'),
              onPressed: _openQuotedPassages,
            ),
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
      body: FutureBuilder<List<BookChapter>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapters = snapshot.data ?? const [];
          if (chapters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  Translations.t('screen.book_reader.empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subTextCol),
                ),
              ),
            );
          }

          return SafeArea(
            top: false,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final c = chapters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        style: TextStyle(color: subTextCol, fontSize: 13),
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
                          builder: (_) => BookChapterReader(chapter: c),
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

  static String _preview(String content) {
    final text = content.replaceAll('\n\n', ' ').trim();
    return text.length <= 120 ? text : '${text.substring(0, 120)}…';
  }

  void _openQuotedPassages() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookReaderScreen(
          repository: widget.repository,
          book: widget.book,
        ),
      ),
    );
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

/// Scrollable prose reader for a single chapter of a source scripture. The
/// chapter text is split on blank lines into paragraphs, and each paragraph
/// is coloured by script: the Sanskrit mūla (and Sanskrit commentary) in the
/// warm brown accent, the English translation in the plain body colour —
/// matching the aṣṭa-kālīya-smaraṇa reader.
class BookChapterReader extends StatelessWidget {
  final BookChapter chapter;

  const BookChapterReader({super.key, required this.chapter});

  /// IAST diacritic letters (both cases) that mark romanized Sanskrit.
  static const Set<String> _iastDiacritics = {
    'ā', 'ī', 'ū', 'ṛ', 'ṝ', 'ḷ', 'ḹ', 'ē', 'ō', 'ĕ', 'ŏ',
    'ṃ', 'ṁ', 'ḥ', 'ś', 'ṣ', 'ṭ', 'ḍ', 'ṇ', 'ñ', 'ṅ', 'ç', 'ä', 'ë', 'ï',
    'Ā', 'Ī', 'Ū', 'Ṛ', 'Ṝ', 'Ḷ', 'Ḹ', 'Ē', 'Ō',
    'Ṃ', 'Ṁ', 'Ḥ', 'Ś', 'Ṣ', 'Ṭ', 'Ḍ', 'Ṇ', 'Ñ', 'Ṅ', 'Ç', 'Ä', 'Ë', 'Ï',
  };

  /// High-frequency English function words. Sanskrit transliteration almost
  /// never contains these as standalone tokens, so two or more hits are a
  /// reliable signal that a paragraph is an English translation.
  static const List<String> _englishStopWords = [
    'the', 'and', 'of', 'to', 'is', 'in', 'that', 'with', 'his', 'her',
    'he', 'she', 'by', 'as', 'for', 'was', 'were', 'are', 'who', 'which',
    'not', 'from', 'this', 'these', 'those', 'it', 'its', 'be', 'been',
    'on', 'at', 'or', 'but', 'when', 'then', 'you', 'your', 'we', 'our',
    'they', 'their', 'will', 'shall', 'have', 'has', 'had', 'him', 'me',
    'my', 'an', 'do', 'does', 'did', 'there', 'here', 'what', 'why', 'how',
    'upon', 'into', 'over', 'out', 'up', 'down', 'also', 'more', 'most',
    'such', 'than', 'only', 'even', 'like', 'one', 'two', 'all', 'any',
    'can', 'may', 'must', 'so', 'if', 'no', 'yes',
  ];

  /// True when [paragraph] reads as an English translation rather than
  /// Sanskrit mūla or Sanskrit commentary.
  static bool isEnglish(String paragraph) {
    if (paragraph.isEmpty) return false;
    if (RegExp(r'[\u0900-\u097F]').hasMatch(paragraph)) return false; // Devanāgarī

    var letters = 0;
    var diacritics = 0;
    for (final rune in paragraph.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[A-Za-z]').hasMatch(ch)) {
        letters++;
      } else if (_iastDiacritics.contains(ch)) {
        letters++;
        diacritics++;
      } else if (rune >= 0x0300 && rune <= 0x036F) {
        diacritics++;
      }
    }
    if (letters == 0) return false;

    final padded = ' ${paragraph.toLowerCase()} ';
    var hits = 0;
    for (final w in _englishStopWords) {
      if (padded.contains(' $w ')) hits++;
    }
    // Strong English signal takes precedence over incidental IAST names.
    if (hits >= 2) return true;
    // Heavy diacritic density means romanized Sanskrit.
    if (diacritics / letters > 0.06) return false;
    // No diacritics at all and not flagged above — treat as English prose.
    if (diacritics == 0) return true;
    // A single function word alongside a few diacritics still reads English.
    return hits >= 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;
    final sanskritColor =
        isDark ? BssColors.darkOakSanskritText : BssColors.sanskritText;

    final paragraphs = chapter.content
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: paragraphs.length + 1,
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
          final paragraph = paragraphs[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _styledParagraph(paragraph, sanskritColor, textColor),
          );
        },
      ),
    );
  }

  /// Builds a paragraph where each line is coloured by script, so a block that
  /// mixes Sanskrit (Devanāgarī / IAST) and its English rendering — as in the
  /// Bhāgavatam chapters, where the reference and translation share a line
  /// range — gets the Sanskrit in the warm brown accent and the English in the
  /// plain body colour.
  static Widget _styledParagraph(
    String paragraph,
    Color sanskritColor,
    Color textColor,
  ) {
    final lines = paragraph.split('\n');
    if (lines.length == 1) {
      final line = lines.first;
      return Text(
        line,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: isEnglish(line) ? textColor : sanskritColor,
        ),
      );
    }
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      spans.add(
        TextSpan(
          text: lines[i],
          style: TextStyle(
            color: isEnglish(lines[i]) ? textColor : sanskritColor,
          ),
        ),
      );
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 15, height: 1.6),
    );
  }
}
