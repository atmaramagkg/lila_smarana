// models/bss2.dart
/// Data model for the second Bhavanāsāra-saṅgraha edition (translation by
/// Haricaraṇa Dāsa), which is read verse-by-verse with its Devanāgarī, IAST
/// transliteration, English translation, and source reference.
///
/// The book is arranged as a four-level tree:
///
///   period  (one eight-period līlā division, e.g. Niśānta-līḷā)
///     └─ section  (a time-window subdivision of the period)
///          └─ chapter  (a narrative unit of the period)
///               └─ verse  (one Sanskrit verse with its blocks)
library;

/// One period of the divine couple's daily līlā.
class Bs2Period {
  final int id;
  final int sortOrder;
  final String title;
  final String timeRange;

  const Bs2Period({
    required this.id,
    required this.sortOrder,
    required this.title,
    this.timeRange = '',
  });

  factory Bs2Period.fromMap(Map<String, Object?> map) {
    return Bs2Period(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      timeRange: map['time_range'] as String? ?? '',
    );
  }
}

/// A time-window subdivision of a period, holding its chapters.
class Bs2Section {
  final int id;
  final int sortOrder;
  final int periodId;
  final String title;
  final String timeRange;

  const Bs2Section({
    required this.id,
    required this.sortOrder,
    required this.periodId,
    required this.title,
    this.timeRange = '',
  });

  factory Bs2Section.fromMap(Map<String, Object?> map) {
    return Bs2Section(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      periodId: map['period_id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      timeRange: map['time_range'] as String? ?? '',
    );
  }
}

/// A narrative unit within a section, holding several verses.
class Bs2Chapter {
  final int id;
  final int sortOrder;
  final int sectionId;
  final String title;

  const Bs2Chapter({
    required this.id,
    required this.sortOrder,
    required this.sectionId,
    required this.title,
  });

  factory Bs2Chapter.fromMap(Map<String, Object?> map) {
    return Bs2Chapter(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      sectionId: map['section_id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
    );
  }
}

/// One verse of the second BSS edition, with its Devanāgarī text, IAST
/// transliteration, English translation, and the scripture it cites.
class Bs2Verse {
  final int id;
  final int sortOrder;
  final int chapterId;
  final String devanagari;
  final String transliteration;
  final String translation;
  final String reference;

  const Bs2Verse({
    required this.id,
    required this.sortOrder,
    required this.chapterId,
    this.devanagari = '',
    this.transliteration = '',
    required this.translation,
    this.reference = '',
  });

  factory Bs2Verse.fromMap(Map<String, Object?> map) {
    return Bs2Verse(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      chapterId: map['chapter_id'] as int? ?? 0,
      devanagari: map['devanagari'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
    );
  }
}

/// One flattened row of the second-BSS continuous reader feed. Each row is
/// either a heading (period, section, or chapter) or a verse. Assembling the
/// whole book into one ordered list of these lets the reader flow top to
/// bottom with the headings shown inline between the verses, exactly like the
/// Bhanu Swami time-of-day reader.
enum Bs2RowType { periodHeading, sectionHeading, chapterHeading, verse }

class Bs2FeedRow {
  final Bs2RowType type;
  final String title; // heading text, or blank for a verse row
  final Bs2Verse? verse;

  const Bs2FeedRow.periodHeading(String t)
      : type = Bs2RowType.periodHeading,
        title = t,
        verse = null;
  const Bs2FeedRow.sectionHeading(String t)
      : type = Bs2RowType.sectionHeading,
        title = t,
        verse = null;
  const Bs2FeedRow.chapterHeading(String t)
      : type = Bs2RowType.chapterHeading,
        title = t,
        verse = null;
  const Bs2FeedRow.verseRow(Bs2Verse v)
      : type = Bs2RowType.verse,
        title = '',
        verse = v;
}