// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetResearchItemCollection on Isar {
  IsarCollection<ResearchItem> get researchItems => this.collection();
}

const ResearchItemSchema = CollectionSchema(
  name: r'ResearchItem',
  id: -8484477884049928559,
  properties: {
    r'citation': PropertySchema(
      id: 0,
      name: r'citation',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'credibility': PropertySchema(
      id: 2,
      name: r'credibility',
      type: IsarType.byte,
      enumMap: _ResearchItemcredibilityEnumValueMap,
    ),
    r'fileName': PropertySchema(
      id: 3,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fileRelPath': PropertySchema(
      id: 4,
      name: r'fileRelPath',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(id: 5, name: r'fileSize', type: IsarType.long),
    r'mimeType': PropertySchema(
      id: 6,
      name: r'mimeType',
      type: IsarType.string,
    ),
    r'note': PropertySchema(id: 7, name: r'note', type: IsarType.string),
    r'previewDescription': PropertySchema(
      id: 8,
      name: r'previewDescription',
      type: IsarType.string,
    ),
    r'previewImageUrl': PropertySchema(
      id: 9,
      name: r'previewImageUrl',
      type: IsarType.string,
    ),
    r'previewTitle': PropertySchema(
      id: 10,
      name: r'previewTitle',
      type: IsarType.string,
    ),
    r'sortIndex': PropertySchema(
      id: 11,
      name: r'sortIndex',
      type: IsarType.long,
    ),
    r'sourceUrl': PropertySchema(
      id: 12,
      name: r'sourceUrl',
      type: IsarType.string,
    ),
    r'stage': PropertySchema(
      id: 13,
      name: r'stage',
      type: IsarType.byte,
      enumMap: _ResearchItemstageEnumValueMap,
    ),
    r'stance': PropertySchema(
      id: 14,
      name: r'stance',
      type: IsarType.byte,
      enumMap: _ResearchItemstanceEnumValueMap,
    ),
    r'tags': PropertySchema(id: 15, name: r'tags', type: IsarType.stringList),
    r'text': PropertySchema(id: 16, name: r'text', type: IsarType.string),
    r'type': PropertySchema(
      id: 17,
      name: r'type',
      type: IsarType.byte,
      enumMap: _ResearchItemtypeEnumValueMap,
    ),
  },

  estimateSize: _researchItemEstimateSize,
  serialize: _researchItemSerialize,
  deserialize: _researchItemDeserialize,
  deserializeProp: _researchItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'stage': IndexSchema(
      id: 4281597865616208537,
      name: r'stage',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'stage',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {
    r'project': LinkSchema(
      id: -3675077521159351622,
      name: r'project',
      target: r'Project',
      single: true,
    ),
    r'claim': LinkSchema(
      id: -1114638231943054340,
      name: r'claim',
      target: r'Claim',
      single: true,
    ),
  },
  embeddedSchemas: {},

  getId: _researchItemGetId,
  getLinks: _researchItemGetLinks,
  attach: _researchItemAttach,
  version: '3.3.2',
);

int _researchItemEstimateSize(
  ResearchItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.citation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileRelPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mimeType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.previewDescription;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.previewImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.previewTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.text;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _researchItemSerialize(
  ResearchItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.citation);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeByte(offsets[2], object.credibility.index);
  writer.writeString(offsets[3], object.fileName);
  writer.writeString(offsets[4], object.fileRelPath);
  writer.writeLong(offsets[5], object.fileSize);
  writer.writeString(offsets[6], object.mimeType);
  writer.writeString(offsets[7], object.note);
  writer.writeString(offsets[8], object.previewDescription);
  writer.writeString(offsets[9], object.previewImageUrl);
  writer.writeString(offsets[10], object.previewTitle);
  writer.writeLong(offsets[11], object.sortIndex);
  writer.writeString(offsets[12], object.sourceUrl);
  writer.writeByte(offsets[13], object.stage.index);
  writer.writeByte(offsets[14], object.stance.index);
  writer.writeStringList(offsets[15], object.tags);
  writer.writeString(offsets[16], object.text);
  writer.writeByte(offsets[17], object.type.index);
}

ResearchItem _researchItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ResearchItem();
  object.citation = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.credibility =
      _ResearchItemcredibilityValueEnumMap[reader.readByteOrNull(offsets[2])] ??
      Credibility.high;
  object.fileName = reader.readStringOrNull(offsets[3]);
  object.fileRelPath = reader.readStringOrNull(offsets[4]);
  object.fileSize = reader.readLongOrNull(offsets[5]);
  object.id = id;
  object.mimeType = reader.readStringOrNull(offsets[6]);
  object.note = reader.readStringOrNull(offsets[7]);
  object.previewDescription = reader.readStringOrNull(offsets[8]);
  object.previewImageUrl = reader.readStringOrNull(offsets[9]);
  object.previewTitle = reader.readStringOrNull(offsets[10]);
  object.sortIndex = reader.readLong(offsets[11]);
  object.sourceUrl = reader.readStringOrNull(offsets[12]);
  object.stage =
      _ResearchItemstageValueEnumMap[reader.readByteOrNull(offsets[13])] ??
      ResearchStage.question;
  object.stance =
      _ResearchItemstanceValueEnumMap[reader.readByteOrNull(offsets[14])] ??
      Stance.supports;
  object.tags = reader.readStringList(offsets[15]) ?? [];
  object.text = reader.readStringOrNull(offsets[16]);
  object.type =
      _ResearchItemtypeValueEnumMap[reader.readByteOrNull(offsets[17])] ??
      ItemType.text;
  return object;
}

P _researchItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (_ResearchItemcredibilityValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              Credibility.high)
          as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (_ResearchItemstageValueEnumMap[reader.readByteOrNull(offset)] ??
              ResearchStage.question)
          as P;
    case 14:
      return (_ResearchItemstanceValueEnumMap[reader.readByteOrNull(offset)] ??
              Stance.supports)
          as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (_ResearchItemtypeValueEnumMap[reader.readByteOrNull(offset)] ??
              ItemType.text)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ResearchItemcredibilityEnumValueMap = {
  'high': 0,
  'medium': 1,
  'low': 2,
  'unknown': 3,
};
const _ResearchItemcredibilityValueEnumMap = {
  0: Credibility.high,
  1: Credibility.medium,
  2: Credibility.low,
  3: Credibility.unknown,
};
const _ResearchItemstageEnumValueMap = {
  'question': 0,
  'background': 1,
  'hypothesis': 2,
  'method': 3,
  'evidence': 4,
  'analysis': 5,
  'conclusion': 6,
  'openQuestion': 7,
  'reference': 8,
};
const _ResearchItemstageValueEnumMap = {
  0: ResearchStage.question,
  1: ResearchStage.background,
  2: ResearchStage.hypothesis,
  3: ResearchStage.method,
  4: ResearchStage.evidence,
  5: ResearchStage.analysis,
  6: ResearchStage.conclusion,
  7: ResearchStage.openQuestion,
  8: ResearchStage.reference,
};
const _ResearchItemstanceEnumValueMap = {
  'supports': 0,
  'refutes': 1,
  'neutral': 2,
};
const _ResearchItemstanceValueEnumMap = {
  0: Stance.supports,
  1: Stance.refutes,
  2: Stance.neutral,
};
const _ResearchItemtypeEnumValueMap = {
  'text': 0,
  'link': 1,
  'image': 2,
  'video': 3,
  'file': 4,
};
const _ResearchItemtypeValueEnumMap = {
  0: ItemType.text,
  1: ItemType.link,
  2: ItemType.image,
  3: ItemType.video,
  4: ItemType.file,
};

Id _researchItemGetId(ResearchItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _researchItemGetLinks(ResearchItem object) {
  return [object.project, object.claim];
}

void _researchItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  ResearchItem object,
) {
  object.id = id;
  object.project.attach(col, col.isar.collection<Project>(), r'project', id);
  object.claim.attach(col, col.isar.collection<Claim>(), r'claim', id);
}

extension ResearchItemQueryWhereSort
    on QueryBuilder<ResearchItem, ResearchItem, QWhere> {
  QueryBuilder<ResearchItem, ResearchItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhere> anyStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'stage'),
      );
    });
  }
}

extension ResearchItemQueryWhere
    on QueryBuilder<ResearchItem, ResearchItem, QWhereClause> {
  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> stageEqualTo(
    ResearchStage stage,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'stage', value: [stage]),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> stageNotEqualTo(
    ResearchStage stage,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stage',
                lower: [],
                upper: [stage],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stage',
                lower: [stage],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stage',
                lower: [stage],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'stage',
                lower: [],
                upper: [stage],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> stageGreaterThan(
    ResearchStage stage, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stage',
          lower: [stage],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> stageLessThan(
    ResearchStage stage, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stage',
          lower: [],
          upper: [stage],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterWhereClause> stageBetween(
    ResearchStage lowerStage,
    ResearchStage upperStage, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'stage',
          lower: [lowerStage],
          includeLower: includeLower,
          upper: [upperStage],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ResearchItemQueryFilter
    on QueryBuilder<ResearchItem, ResearchItem, QFilterCondition> {
  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'citation'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'citation'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'citation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'citation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'citation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'citation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'citation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'citation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'citation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'citation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'citation', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  citationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'citation', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  credibilityEqualTo(Credibility value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'credibility', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  credibilityGreaterThan(Credibility value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'credibility',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  credibilityLessThan(Credibility value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'credibility',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  credibilityBetween(
    Credibility lower,
    Credibility upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'credibility',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileName'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileName'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileRelPath'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileRelPath'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileRelPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileRelPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileRelPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileRelPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileRelPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileRelPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileRelPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileRelPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileRelPath', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileRelPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileRelPath', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileSize'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileSize'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileSizeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileSize', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileSizeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileSizeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  fileSizeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mimeType'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mimeType'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mimeType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mimeType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mimeType', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  mimeTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mimeType', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'previewDescription'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'previewDescription'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'previewDescription',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'previewDescription',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'previewDescription',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'previewDescription',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'previewDescription',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'previewDescription',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'previewDescription',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'previewDescription',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'previewDescription', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'previewDescription', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'previewImageUrl'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'previewImageUrl'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'previewImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'previewImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'previewImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'previewImageUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'previewImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'previewImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'previewImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'previewImageUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'previewImageUrl', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'previewImageUrl', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'previewTitle'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'previewTitle'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'previewTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'previewTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'previewTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'previewTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'previewTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'previewTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'previewTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'previewTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'previewTitle', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  previewTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'previewTitle', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sortIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortIndex', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sortIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sortIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sortIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceUrl'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceUrl'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  sourceUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> stageEqualTo(
    ResearchStage value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stage', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  stageGreaterThan(ResearchStage value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> stageLessThan(
    ResearchStage value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stage',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> stageBetween(
    ResearchStage lower,
    ResearchStage upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> stanceEqualTo(
    Stance value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stance', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  stanceGreaterThan(Stance value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stance',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  stanceLessThan(Stance value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stance',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> stanceBetween(
    Stance lower,
    Stance upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'text'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  textIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'text'),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  textGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'text',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  textStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> textMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'text',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> typeEqualTo(
    ItemType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  typeGreaterThan(ItemType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> typeLessThan(
    ItemType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> typeBetween(
    ItemType lower,
    ItemType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ResearchItemQueryObject
    on QueryBuilder<ResearchItem, ResearchItem, QFilterCondition> {}

extension ResearchItemQueryLinks
    on QueryBuilder<ResearchItem, ResearchItem, QFilterCondition> {
  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> project(
    FilterQuery<Project> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'project');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  projectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'project', 0, true, 0, true);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition> claim(
    FilterQuery<Claim> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'claim');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterFilterCondition>
  claimIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'claim', 0, true, 0, true);
    });
  }
}

extension ResearchItemQuerySortBy
    on QueryBuilder<ResearchItem, ResearchItem, QSortBy> {
  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByCitation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citation', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByCitationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citation', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByCredibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credibility', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByCredibilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credibility', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByFileRelPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileRelPath', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByFileRelPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileRelPath', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByPreviewDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewDescription', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByPreviewDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewDescription', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByPreviewImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewImageUrl', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByPreviewImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewImageUrl', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByPreviewTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTitle', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  sortByPreviewTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTitle', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByStance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stance', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByStanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stance', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ResearchItemQuerySortThenBy
    on QueryBuilder<ResearchItem, ResearchItem, QSortThenBy> {
  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByCitation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citation', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByCitationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'citation', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByCredibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credibility', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByCredibilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credibility', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByFileRelPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileRelPath', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByFileRelPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileRelPath', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByPreviewDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewDescription', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByPreviewDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewDescription', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByPreviewImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewImageUrl', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByPreviewImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewImageUrl', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByPreviewTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTitle', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy>
  thenByPreviewTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previewTitle', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByStance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stance', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByStanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stance', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ResearchItemQueryWhereDistinct
    on QueryBuilder<ResearchItem, ResearchItem, QDistinct> {
  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByCitation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'citation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByCredibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credibility');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByFileName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByFileRelPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileRelPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSize');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByMimeType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mimeType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct>
  distinctByPreviewDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'previewDescription',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct>
  distinctByPreviewImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'previewImageUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByPreviewTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previewTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortIndex');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctBySourceUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stage');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByStance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stance');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResearchItem, ResearchItem, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension ResearchItemQueryProperty
    on QueryBuilder<ResearchItem, ResearchItem, QQueryProperty> {
  QueryBuilder<ResearchItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> citationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'citation');
    });
  }

  QueryBuilder<ResearchItem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ResearchItem, Credibility, QQueryOperations>
  credibilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credibility');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> fileRelPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileRelPath');
    });
  }

  QueryBuilder<ResearchItem, int?, QQueryOperations> fileSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSize');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> mimeTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mimeType');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations>
  previewDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previewDescription');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations>
  previewImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previewImageUrl');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> previewTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previewTitle');
    });
  }

  QueryBuilder<ResearchItem, int, QQueryOperations> sortIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortIndex');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> sourceUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrl');
    });
  }

  QueryBuilder<ResearchItem, ResearchStage, QQueryOperations> stageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stage');
    });
  }

  QueryBuilder<ResearchItem, Stance, QQueryOperations> stanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stance');
    });
  }

  QueryBuilder<ResearchItem, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<ResearchItem, String?, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<ResearchItem, ItemType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
