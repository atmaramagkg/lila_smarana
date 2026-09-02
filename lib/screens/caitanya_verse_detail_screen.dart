// screens/caitanya_verse_detail_screen.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/caitanya_stotra_verse.dart';

/// Full-screen reading mode for the Caitanya stotram: swipeable pages,
/// one verse per page, with IAST and English translation.
class CaitanyaVerseDetailScreen extends StatefulWidget {
  final List<CaitanyaStotraVerse> verses;
  final int initialIndex;

  const CaitanyaVerseDetailScreen({
    super.key,
    required this.verses,
    this.initialIndex = 0,
  });

  @override
  State<CaitanyaVerseDetailScreen> createState() =>
      _CaitanyaVerseDetailScreenState();
}

class _CaitanyaVerseDetailScreenState extends State<CaitanyaVerseDetailScreen> {
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
        title: Text('Śrī Caitanya'),
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
                    if (v.heading.isNotEmpty) ...[
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
