// models/radhakrsna_stotra_verse.dart
/// One period ("yama") of the Śrī Rādhā-Kṛṣṇayoḥ Aṣṭa-kālīya-līlā
/// Smaraṇa-maṅgala-śrotram (8 periods of the divine couple's daily rotuine).
///
/// Each period carries the romanized Sanskrit verse, a word-by-word gloss,
/// and an English prose translation. The list pane shows just the
/// translation; verse + word meanings appear when the period is opened.
class RadhaKrsnaStotraVerse {
  final int id;
  final int sortOrder;
  final String period;
  final String heading;
  final String verse;
  final String wordMeanings;
  final String translationEn;

  const RadhaKrsnaStotraVerse({
    required this.id,
    required this.sortOrder,
    required this.period,
    required this.heading,
    required this.verse,
    required this.wordMeanings,
    required this.translationEn,
  });

  factory RadhaKrsnaStotraVerse.fromMap(Map<String, Object?> map) {
    return RadhaKrsnaStotraVerse(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      period: map['period'] as String? ?? '',
      heading: map['heading'] as String? ?? '',
      verse: map['verse'] as String? ?? '',
      wordMeanings: map['word_meanings'] as String? ?? '',
      translationEn: map['translation_en'] as String? ?? '',
    );
  }
}