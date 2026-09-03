// models/gauranga_stotra_verse.dart
/// A single verse of the Śrī Śrīmad Gaurāṅga-līlā-smaraṇa-maṅgala-stotram
/// by Śrīla Bhaktivinoda Ṭhākura (104 verses).
///
/// Each verse carries its Devanāgarī text, IAST transliteration, and an
/// English translation. The reader shows the translated list; the full
/// Devanāgarī and transliteration are revealed when a verse is opened.
class GaurangaStotraVerse {
  final int id;
  final int sortOrder;
  final String ref;
  final String heading;
  final String devanagari;
  final String transliteration;
  final String translationEn;

  const GaurangaStotraVerse({
    required this.id,
    required this.sortOrder,
    required this.ref,
    required this.heading,
    required this.devanagari,
    required this.transliteration,
    required this.translationEn,
  });

  factory GaurangaStotraVerse.fromMap(Map<String, Object?> map) {
    return GaurangaStotraVerse(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      ref: map['ref'] as String? ?? '',
      heading: map['heading'] as String? ?? '',
      devanagari: map['devanagari'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      translationEn: map['translation_en'] as String? ?? '',
    );
  }
}