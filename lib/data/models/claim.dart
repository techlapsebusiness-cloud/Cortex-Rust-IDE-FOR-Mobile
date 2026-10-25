import 'package:isar_community/isar.dart';

import 'project.dart';
import 'research_enums.dart';
import 'research_item.dart';

part 'claim.g.dart';

@collection
class Claim {
  Id id = Isar.autoIncrement;

  final project = IsarLink<Project>();

  @enumerated
  late ClaimType type;

  late String statement;

  @enumerated
  ClaimStatus status = ClaimStatus.open;

  /// 0–100, user-set or derived from evidence balance.
  int confidence = 50;

  late DateTime createdAt;

  int sortIndex = 0;

  @Backlink(to: 'claim')
  final evidence = IsarLinks<ResearchItem>();
}
