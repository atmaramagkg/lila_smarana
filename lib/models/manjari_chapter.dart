// models/manjari_chapter.dart
/// A single chapter of a mañjarī treatise. Carries a `bookSlug` to scope the
/// chapter to one work:
/// - "Manjari Svarupa Nirupana" (11 prose chapters) by Śrīla
///   Kunja-bihārī Dāsa Bābājī, and
/// - "Anaṅga-mañjarī-sampuṭikā" (4 laharī chapters) by Śrī Rāmacandra
///   Gosvāmī.
///
/// Each chapter is prose, so it carries one contiguous `content` string
/// (paragraphs separated by blank lines) rather than discrete verses. The
/// chapter reader scrolls through the full text.
class ManjariChapter {
  final int id;
  final int sortOrder;
  final String title;
  final String content;
  final String bookSlug;

  const ManjariChapter({
    required this.id,
    required this.sortOrder,
    required this.title,
    required this.content,
    this.bookSlug = '',
  });

  factory ManjariChapter.fromMap(Map<String, Object?> map) {
    return ManjariChapter(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      bookSlug: map['book_slug'] as String? ?? '',
    );
  }
}