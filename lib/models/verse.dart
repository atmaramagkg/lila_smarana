// models/verse.dart
import '../services/translations.dart';

/// A single verse from the unified `verses` table. Contains transliteration
/// and translations in all three languages.
class Verse {
  final int id;
  final int? sectionId;
  final int sortOrder;
  final String refDisplay;
  final String transliteration;
  final String translationEn;
  final String translationRu;
  final String translationHi;
  final int? bookId;
  final String sourceRefs;

  const Verse({
    required this.id,
    this.sectionId,
    this.sortOrder = 0,
    required this.refDisplay,
    this.sourceRefs = '',
    this.transliteration = '',
    this.translationEn = '',
    this.translationRu = '',
    this.translationHi = '',
    this.bookId,
  });

  /// Returns the translation for the given language code.
  /// Falls back to the transliteration, so a verse whose prose translation
  /// isn't in yet still shows the romanized Sanskrit instead of going blank.
  String translationForCode(String code) {
    switch (code) {
      case 'ru':
        if (translationRu.isNotEmpty) return translationRu;
        return transliteration;
      default:
        if (translationEn.isNotEmpty) return translationEn;
        return transliteration;
    }
  }

  /// The citation shown to the reader: for verses quoted from an external
  /// book, that book's ref (e.g. 'Govinda-līlāmṛta 1.107'). For verses from
  /// the compilation itself, the external scripture they cite (sourceRefs,
  /// translated via [Translations.translateSourceRef]) when known, falling
  /// back to the compilation's own internal numbering (refDisplay) so the
  /// reader always sees *some* citation rather than nothing.
  String get displayCitation {
    if (bookId != null) return refDisplay;
    final translated = Translations.translateSourceRef(sourceRefs);
    return translated;
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: (map['id'] as num?)?.toInt() ?? 0,
      sectionId: (map['section_id'] as num?)?.toInt(),
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      refDisplay: (map['ref_display'] as String?) ?? '',
      transliteration: (map['transliteration'] as String?) ?? '',
      translationEn: (map['translation_en'] as String?) ?? '',
      translationRu: (map['translation_ru'] as String?) ?? '',
      translationHi: (map['translation_hi'] as String?) ?? '',
      bookId: (map['book_id'] as num?)?.toInt(),
      sourceRefs: (map['source_refs'] as String?) ?? '',
    );
  }
}
