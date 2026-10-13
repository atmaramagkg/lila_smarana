// models/book_chapter.dart

/// One chapter (or section) of a source scripture's full text, stored in the
/// `book_chapters` table. A full work is an ordered list of these.
class BookChapter {
  final int id;
  final int bookId;
  final String lang;
  final int sortOrder;
  final String title;
  final String content;

  const BookChapter({
    required this.id,
    required this.bookId,
    required this.lang,
    required this.sortOrder,
    required this.title,
    required this.content,
  });

  factory BookChapter.fromMap(Map<String, dynamic> map) {
    return BookChapter(
      id: (map['id'] as int?) ?? 0,
      bookId: (map['book_id'] as int?) ?? 0,
      lang: (map['lang'] as String?) ?? 'en',
      sortOrder: (map['sort_order'] as int?) ?? 0,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
    );
  }
}
