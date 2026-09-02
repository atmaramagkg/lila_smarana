// models/prabhupada_stotra_verse.dart
/// A single section of the Srila Prabhupada Lila-Smarana-Mangala-Stotram.
///
/// Unlike the Caitanya stotram (organized by the eight asta-kaliya periods),
/// this stotram narrates Srila Prabhupada's life and glories in a continuous
/// sequence. Each row corresponds to one printed verse group (some groups
/// contain several Bengali verses sharing a single English translation).
class PrabhupadaStotraVerse {
  final int id;
  final int sortOrder;
  final String ref;
  final String heading;
  final String transliteration;
  final String translationEn;

  const PrabhupadaStotraVerse({
    required this.id,
    required this.sortOrder,
    required this.ref,
    required this.heading,
    required this.transliteration,
    required this.translationEn,
  });

  factory PrabhupadaStotraVerse.fromMap(Map<String, Object?> map) {
    return PrabhupadaStotraVerse(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      ref: map['ref'] as String? ?? '',
      heading: map['heading'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      translationEn: map['translation_en'] as String? ?? '',
    );
  }
}
