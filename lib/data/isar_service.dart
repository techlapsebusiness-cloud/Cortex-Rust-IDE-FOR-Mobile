import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/item.dart';
import 'models/topic.dart';

class IsarService {
  IsarService._();

  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [TopicSchema, ItemSchema],
      directory: dir.path,
      name: 'cortex',
    );
  }
}
