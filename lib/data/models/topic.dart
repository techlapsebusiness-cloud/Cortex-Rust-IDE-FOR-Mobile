import 'package:isar_community/isar.dart';

import 'item.dart';

part 'topic.g.dart';

@collection
class Topic {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String title;

  String? description;

  /// Per-topic accent; defaults to cyan.
  int colorValue = 0xFF22D3EE;

  String? iconName;

  late DateTime createdAt;
  late DateTime updatedAt;

  int sortIndex = 0;

  /// Lowercase blob for search (title + description).
  @Index(type: IndexType.value, caseSensitive: false)
  String searchText = '';

  @Backlink(to: 'topic')
  final items = IsarLinks<Item>();

  void rebuildSearchText() {
    searchText = [
      title,
      description ?? '',
    ].join(' ').toLowerCase().trim();
  }
}
