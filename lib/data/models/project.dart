import 'package:isar_community/isar.dart';

import 'claim.dart';
import 'research_item.dart';

part 'project.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  late String title;

  /// Headline research question, shown as subtitle on project cards.
  String researchQuestion = '';

  /// Discipline (e.g. "Security", "Biology").
  String? field;

  String? description;

  int colorValue = 0xFF22D3EE;

  late DateTime createdAt;
  late DateTime updatedAt;

  int sortIndex = 0;

  @Backlink(to: 'project')
  final items = IsarLinks<ResearchItem>();

  @Backlink(to: 'project')
  final claims = IsarLinks<Claim>();
}
