// models/manjari_chapter.dart
/// A single chapter of the Manjari Svarupa Nirupana treatise (11 chapters)
/// by Śrīla Bhaktivinoda Ṭhākura.
///
/// Each chapter is prose, so it carries one contiguous `content` string
/// (paragraphs separated by blank lines) rather than discrete verses. The
/// chapter reader scrolls through the full text.
class ManjariChapter {
  final int id;
  final int sortOrder;
  final String title;
  final String content;

  const ManjariChapter({
    required this.id,
    required this.sortOrder,
    required this.title,
    required this.content,
  });

  factory ManjariChapter.fromMap(Map<String, Object?> map) {
    return ManjariChapter(
      id: map['id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
    );
  }
}