// screens/caitanya_screen.dart
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/caitanya_stotra_verse.dart';
import '../services/bss_repository.dart';
import '../services/translations.dart';

/// The Śrī Caitanya branch: the complete
/// "Sriman Mahaprabhor asta-kaliya lila smarana mangala stotram"
/// with transliteration and English translation, in canonical order
/// (invocation, daily schedule, eight period songs, benefit).
class CaitanyaScreen extends StatefulWidget {
  final BssRepository repository;

  const CaitanyaScreen({super.key, required this.repository});

  @override
  State<CaitanyaScreen> createState() => _CaitanyaScreenState();
}

class _CaitanyaScreenState extends State<CaitanyaScreen> {
  late Future<List<CaitanyaStotraVerse>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getCaitanyaStotram();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? BssColors.darkOakGold : BssColors.goldAccent;
    final textColor = isDark ? BssColors.darkOakText : BssColors.darkText;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.t('personality.caitanya.title')),
      ),
      body: FutureBuilder<List<CaitanyaStotraVerse>>(
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
                final periodTitle = _periodTitle(v.periodCode);
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
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (periodTitle != null) ...[
                          Text(
                            periodTitle,
                            style: TextStyle(
                              color: goldColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (v.heading.isNotEmpty) ...[
                          Text(
                            v.heading,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (v.transliteration.isNotEmpty) ...[
                          Text(
                            v.transliteration,
                            style: TextStyle(
                              color: isDark
                                  ? BssColors.darkOakSanskritText
                                  : BssColors.sanskritText,
                              fontSize: 14,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Maps a stotram period code to its translated lila name using the
  /// same keys the main reader uses, or null for non-period verses.
  String? _periodTitle(String? code) {
    if (code == null) return null;
    const codes = {
      'nishanta': 'period.nishanta.name',
      'pratah': 'period.pratah.name',
      'purvahna': 'period.purvahna.name',
      'madhyahna': 'period.madhyahna.name',
      'aparahna': 'period.aparahna.name',
      'sayahna': 'period.sayahna.name',
      'pradosha': 'period.pradosha.name',
      'nisha': 'period.nisha.name',
    };
    final key = codes[code];
    return key == null ? null : Translations.t(key);
  }
}