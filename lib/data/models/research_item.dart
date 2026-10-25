import 'package:isar_community/isar.dart';

import 'claim.dart';
import 'project.dart';
import 'research_enums.dart';

part 'research_item.g.dart';

@collection
class ResearchItem {
  Id id = Isar.autoIncrement;

  final project = IsarLink<Project>();

  @enumerated
  @Index()
  late ResearchStage stage;

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
  String? previewImageUrl;

  List<String> tags = [];

  /// Optional evidence → claim linkage.
  final claim = IsarLink<Claim>();

  /// Stance relative to [claim]. Ignored when claim is unset.
  /// (Isar cannot store nullable enums — §3 `Stance?` mapped to default neutral.)
  @enumerated
  Stance stance = Stance.neutral;

  @enumerated
  Credibility credibility = Credibility.unknown;

  /// Formatted citation for References aggregation.
  String? citation;

  late DateTime createdAt;

  int sortIndex = 0;
}
