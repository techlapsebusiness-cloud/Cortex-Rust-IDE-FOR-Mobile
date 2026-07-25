import 'package:isar_community/isar.dart';

import 'item_type.dart';
import 'topic.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  final topic = IsarLink<Topic>();

  @enumerated
  late ItemType type;

  String? text;
  String? note;
  String? sourceUrl;

  /// Path relative to app documents directory (never absolute).
  String? fileRelPath;
  String? fileName;
  String? mimeType;
  int? fileSize;

  String? previewTitle;
  String? previewDescription;

  /// Remote URL or local relative path (under docs) for offline cards.
  String? previewImageUrl;

  /// Local relative path to a generated video thumbnail.
  String? thumbRelPath;

  List<String> tags = [];

  late DateTime createdAt;
  int sortIndex = 0;

  /// Lowercase blob for search across text/note/tags/preview.
  @Index(type: IndexType.value, caseSensitive: false)
  String searchText = '';

  void rebuildSearchText() {
    searchText = [
      text ?? '',
      note ?? '',
      previewTitle ?? '',
      previewDescription ?? '',
      fileName ?? '',
      sourceUrl ?? '',
      ...tags,
    ].join(' ').toLowerCase().trim();
  }
}
