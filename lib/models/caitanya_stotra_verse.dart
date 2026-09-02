// models/caitanya_stotra_verse.dart
class CaitanyaStotraVerse {
  final int id;
  final int sortOrder;
  final String? periodCode;
  final String heading;
  final String transliteration;
  final String translationEn;

  const CaitanyaStotraVerse({
    required this.id,
    required this.sortOrder,
    required this.periodCode,
    required this.heading,
    required this.transliteration,
    required this.translationEn,
  });

  factory CaitanyaStotraVerse.fromMap(Map<String, dynamic> row) {
    return CaitanyaStotraVerse(
      id: row['id'] as int,
      sortOrder: row['sort_order'] as int? ?? 0,
      periodCode: row['period_code'] as String?,
      heading: (row['heading'] as String?) ?? '',
      transliteration: (row['transliteration'] as String?) ?? '',
      translationEn: (row['translation_en'] as String?) ?? '',
    );
  }
}