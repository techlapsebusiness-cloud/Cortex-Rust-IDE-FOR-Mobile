// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClaimCollection on Isar {
  IsarCollection<Claim> get claims => this.collection();
}

const ClaimSchema = CollectionSchema(
  name: r'Claim',
  id: -9219224417148451372,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'sortIndex': PropertySchema(
      id: 2,
      name: r'sortIndex',
      type: IsarType.long,
    ),
    r'statement': PropertySchema(
      id: 3,
      name: r'statement',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 4,
      name: r'status',
      type: IsarType.byte,
      enumMap: _ClaimstatusEnumValueMap,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.byte,
      enumMap: _ClaimtypeEnumValueMap,
    ),
  },

  estimateSize: _claimEstimateSize,
  serialize: _claimSerialize,
  deserialize: _claimDeserialize,
  deserializeProp: _claimDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'project': LinkSchema(
      id: -7182174129477536627,
      name: r'project',
      target: r'Project',
      single: true,
    ),
    r'evidence': LinkSchema(
      id: -4200655087159521648,
      name: r'evidence',
      target: r'ResearchItem',
      single: false,
      linkName: r'claim',
    ),
  },
  embeddedSchemas: {},

  getId: _claimGetId,
  getLinks: _claimGetLinks,
  attach: _claimAttach,
  version: '3.3.2',
);

int _claimEstimateSize(
  Claim object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.statement.length * 3;
  return bytesCount;
}

void _claimSerialize(
  Claim object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.confidence);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.sortIndex);
  writer.writeString(offsets[3], object.statement);
  writer.writeByte(offsets[4], object.status.index);
  writer.writeByte(offsets[5], object.type.index);
}

Claim _claimDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Claim();
  object.confidence = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.sortIndex = reader.readLong(offsets[2]);
  object.statement = reader.readString(offsets[3]);
  object.status =
      _ClaimstatusValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      ClaimStatus.open;
  object.type =
      _ClaimtypeValueEnumMap[reader.readByteOrNull(offsets[5])] ??
      ClaimType.question;
  return object;
}

P _claimDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_ClaimstatusValueEnumMap[reader.readByteOrNull(offset)] ??
              ClaimStatus.open)
          as P;
    case 5:
      return (_ClaimtypeValueEnumMap[reader.readByteOrNull(offset)] ??
              ClaimType.question)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ClaimstatusEnumValueMap = {
  'open': 0,
  'supported': 1,
  'refuted': 2,
  'inconclusive': 3,
};
const _ClaimstatusValueEnumMap = {
  0: ClaimStatus.open,
  1: ClaimStatus.supported,
  2: ClaimStatus.refuted,
  3: ClaimStatus.inconclusive,
};
const _ClaimtypeEnumValueMap = {'question': 0, 'hypothesis': 1, 'thesis': 2};
const _ClaimtypeValueEnumMap = {
  0: ClaimType.question,
  1: ClaimType.hypothesis,
  2: ClaimType.thesis,
};

Id _claimGetId(Claim object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _claimGetLinks(Claim object) {
  return [object.project, object.evidence];
}

void _claimAttach(IsarCollection<dynamic> col, Id id, Claim object) {
  object.id = id;
  object.project.attach(col, col.isar.collection<Project>(), r'project', id);
  object.evidence.attach(
    col,
    col.isar.collection<ResearchItem>(),
    r'evidence',
    id,
  );
}

extension ClaimQueryWhereSort on QueryBuilder<Claim, Claim, QWhere> {
  QueryBuilder<Claim, Claim, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClaimQueryWhere on QueryBuilder<Claim, Claim, QWhereClause> {
  QueryBuilder<Claim, Claim, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Claim, Claim, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Claim, Claim, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterWhereClause> idBetween(
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
}

extension ClaimQueryFilter on QueryBuilder<Claim, Claim, QFilterCondition> {
  QueryBuilder<Claim, Claim, QAfterFilterCondition> confidenceEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'confidence', value: value),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> confidenceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'confidence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> confidenceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'confidence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> confidenceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'confidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> sortIndexEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortIndex', value: value),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> sortIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> sortIndexLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> sortIndexBetween(
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'statement',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'statement',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'statement',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'statement',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'statement',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'statement',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'statement',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'statement',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'statement', value: ''),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'statement', value: ''),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statusEqualTo(
    ClaimStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statusGreaterThan(
    ClaimStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statusLessThan(
    ClaimStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> statusBetween(
    ClaimStatus lower,
    ClaimStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> typeEqualTo(
    ClaimType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value),
      );
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> typeGreaterThan(
    ClaimType value, {
    bool include = false,
  }) {
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> typeLessThan(
    ClaimType value, {
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

  QueryBuilder<Claim, Claim, QAfterFilterCondition> typeBetween(
    ClaimType lower,
    ClaimType upper, {
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

extension ClaimQueryObject on QueryBuilder<Claim, Claim, QFilterCondition> {}

extension ClaimQueryLinks on QueryBuilder<Claim, Claim, QFilterCondition> {
  QueryBuilder<Claim, Claim, QAfterFilterCondition> project(
    FilterQuery<Project> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'project');
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> projectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'project', 0, true, 0, true);
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidence(
    FilterQuery<ResearchItem> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'evidence');
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidenceLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'evidence', length, true, length, true);
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'evidence', 0, true, 0, true);
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'evidence', 0, false, 999999, true);
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidenceLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'evidence', 0, true, length, include);
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidenceLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'evidence', length, include, 999999, true);
    });
  }

  QueryBuilder<Claim, Claim, QAfterFilterCondition> evidenceLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'evidence',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ClaimQuerySortBy on QueryBuilder<Claim, Claim, QSortBy> {
  QueryBuilder<Claim, Claim, QAfterSortBy> sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByStatement() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statement', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByStatementDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statement', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ClaimQuerySortThenBy on QueryBuilder<Claim, Claim, QSortThenBy> {
  QueryBuilder<Claim, Claim, QAfterSortBy> thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenBySortIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortIndex', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByStatement() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statement', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByStatementDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statement', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Claim, Claim, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ClaimQueryWhereDistinct on QueryBuilder<Claim, Claim, QDistinct> {
  QueryBuilder<Claim, Claim, QDistinct> distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<Claim, Claim, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Claim, Claim, QDistinct> distinctBySortIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortIndex');
    });
  }

  QueryBuilder<Claim, Claim, QDistinct> distinctByStatement({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statement', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Claim, Claim, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<Claim, Claim, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension ClaimQueryProperty on QueryBuilder<Claim, Claim, QQueryProperty> {
  QueryBuilder<Claim, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Claim, int, QQueryOperations> confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<Claim, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Claim, int, QQueryOperations> sortIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortIndex');
    });
  }

  QueryBuilder<Claim, String, QQueryOperations> statementProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statement');
    });
  }

  QueryBuilder<Claim, ClaimStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Claim, ClaimType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
