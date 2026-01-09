// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _itemImagePathMeta =
      const VerificationMeta('itemImagePath');
  @override
  late final GeneratedColumn<String> itemImagePath = GeneratedColumn<String>(
      'item_image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [itemId, itemName, itemImagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('item_image_path')) {
      context.handle(
          _itemImagePathMeta,
          itemImagePath.isAcceptableOrUnknown(
              data['item_image_path']!, _itemImagePathMeta));
    } else if (isInserting) {
      context.missing(_itemImagePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      itemImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}item_image_path'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int itemId;
  final String itemName;
  final String itemImagePath;
  const Item(
      {required this.itemId,
      required this.itemName,
      required this.itemImagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<int>(itemId);
    map['item_name'] = Variable<String>(itemName);
    map['item_image_path'] = Variable<String>(itemImagePath);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      itemId: Value(itemId),
      itemName: Value(itemName),
      itemImagePath: Value(itemImagePath),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      itemId: serializer.fromJson<int>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      itemImagePath: serializer.fromJson<String>(json['itemImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<int>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'itemImagePath': serializer.toJson<String>(itemImagePath),
    };
  }

  Item copyWith({int? itemId, String? itemName, String? itemImagePath}) => Item(
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemImagePath: itemImagePath ?? this.itemImagePath,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemImagePath: data.itemImagePath.present
          ? data.itemImagePath.value
          : this.itemImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemImagePath: $itemImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, itemName, itemImagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.itemImagePath == this.itemImagePath);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> itemId;
  final Value<String> itemName;
  final Value<String> itemImagePath;
  const ItemsCompanion({
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemImagePath = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.itemId = const Value.absent(),
    required String itemName,
    required String itemImagePath,
  })  : itemName = Value(itemName),
        itemImagePath = Value(itemImagePath);
  static Insertable<Item> custom({
    Expression<int>? itemId,
    Expression<String>? itemName,
    Expression<String>? itemImagePath,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (itemImagePath != null) 'item_image_path': itemImagePath,
    });
  }

  ItemsCompanion copyWith(
      {Value<int>? itemId,
      Value<String>? itemName,
      Value<String>? itemImagePath}) {
    return ItemsCompanion(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemImagePath: itemImagePath ?? this.itemImagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemImagePath.present) {
      map['item_image_path'] = Variable<String>(itemImagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('itemImagePath: $itemImagePath')
          ..write(')'))
        .toString();
  }
}

class $BagsTable extends Bags with TableInfo<$BagsTable, Bag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdsMeta =
      const VerificationMeta('itemIds');
  @override
  late final GeneratedColumn<String> itemIds = GeneratedColumn<String>(
      'item_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preparedItemIdsMeta =
      const VerificationMeta('preparedItemIds');
  @override
  late final GeneratedColumn<String> preparedItemIds = GeneratedColumn<String>(
      'prepared_item_ids', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _iconCodeMeta =
      const VerificationMeta('iconCode');
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
      'icon_code', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _itemImagePathMeta =
      const VerificationMeta('itemImagePath');
  @override
  late final GeneratedColumn<String> itemImagePath = GeneratedColumn<String>(
      'item_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, itemIds, preparedItemIds, iconCode, itemImagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bags';
  @override
  VerificationContext validateIntegrity(Insertable<Bag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('item_ids')) {
      context.handle(_itemIdsMeta,
          itemIds.isAcceptableOrUnknown(data['item_ids']!, _itemIdsMeta));
    } else if (isInserting) {
      context.missing(_itemIdsMeta);
    }
    if (data.containsKey('prepared_item_ids')) {
      context.handle(
          _preparedItemIdsMeta,
          preparedItemIds.isAcceptableOrUnknown(
              data['prepared_item_ids']!, _preparedItemIdsMeta));
    }
    if (data.containsKey('icon_code')) {
      context.handle(_iconCodeMeta,
          iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta));
    }
    if (data.containsKey('item_image_path')) {
      context.handle(
          _itemImagePathMeta,
          itemImagePath.isAcceptableOrUnknown(
              data['item_image_path']!, _itemImagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      itemIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_ids'])!,
      preparedItemIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prepared_item_ids'])!,
      iconCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code']),
      itemImagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_image_path']),
    );
  }

  @override
  $BagsTable createAlias(String alias) {
    return $BagsTable(attachedDatabase, alias);
  }
}

class Bag extends DataClass implements Insertable<Bag> {
  final int id;
  final String name;
  final String itemIds;
  final String preparedItemIds;
  final int? iconCode;
  final String? itemImagePath;
  const Bag(
      {required this.id,
      required this.name,
      required this.itemIds,
      required this.preparedItemIds,
      this.iconCode,
      this.itemImagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['item_ids'] = Variable<String>(itemIds);
    map['prepared_item_ids'] = Variable<String>(preparedItemIds);
    if (!nullToAbsent || iconCode != null) {
      map['icon_code'] = Variable<int>(iconCode);
    }
    if (!nullToAbsent || itemImagePath != null) {
      map['item_image_path'] = Variable<String>(itemImagePath);
    }
    return map;
  }

  BagsCompanion toCompanion(bool nullToAbsent) {
    return BagsCompanion(
      id: Value(id),
      name: Value(name),
      itemIds: Value(itemIds),
      preparedItemIds: Value(preparedItemIds),
      iconCode: iconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCode),
      itemImagePath: itemImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(itemImagePath),
    );
  }

  factory Bag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      itemIds: serializer.fromJson<String>(json['itemIds']),
      preparedItemIds: serializer.fromJson<String>(json['preparedItemIds']),
      iconCode: serializer.fromJson<int?>(json['iconCode']),
      itemImagePath: serializer.fromJson<String?>(json['itemImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'itemIds': serializer.toJson<String>(itemIds),
      'preparedItemIds': serializer.toJson<String>(preparedItemIds),
      'iconCode': serializer.toJson<int?>(iconCode),
      'itemImagePath': serializer.toJson<String?>(itemImagePath),
    };
  }

  Bag copyWith(
          {int? id,
          String? name,
          String? itemIds,
          String? preparedItemIds,
          Value<int?> iconCode = const Value.absent(),
          Value<String?> itemImagePath = const Value.absent()}) =>
      Bag(
        id: id ?? this.id,
        name: name ?? this.name,
        itemIds: itemIds ?? this.itemIds,
        preparedItemIds: preparedItemIds ?? this.preparedItemIds,
        iconCode: iconCode.present ? iconCode.value : this.iconCode,
        itemImagePath:
            itemImagePath.present ? itemImagePath.value : this.itemImagePath,
      );
  Bag copyWithCompanion(BagsCompanion data) {
    return Bag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      itemIds: data.itemIds.present ? data.itemIds.value : this.itemIds,
      preparedItemIds: data.preparedItemIds.present
          ? data.preparedItemIds.value
          : this.preparedItemIds,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      itemImagePath: data.itemImagePath.present
          ? data.itemImagePath.value
          : this.itemImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('itemIds: $itemIds, ')
          ..write('preparedItemIds: $preparedItemIds, ')
          ..write('iconCode: $iconCode, ')
          ..write('itemImagePath: $itemImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, itemIds, preparedItemIds, iconCode, itemImagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bag &&
          other.id == this.id &&
          other.name == this.name &&
          other.itemIds == this.itemIds &&
          other.preparedItemIds == this.preparedItemIds &&
          other.iconCode == this.iconCode &&
          other.itemImagePath == this.itemImagePath);
}

class BagsCompanion extends UpdateCompanion<Bag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> itemIds;
  final Value<String> preparedItemIds;
  final Value<int?> iconCode;
  final Value<String?> itemImagePath;
  const BagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.itemIds = const Value.absent(),
    this.preparedItemIds = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.itemImagePath = const Value.absent(),
  });
  BagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String itemIds,
    this.preparedItemIds = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.itemImagePath = const Value.absent(),
  })  : name = Value(name),
        itemIds = Value(itemIds);
  static Insertable<Bag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? itemIds,
    Expression<String>? preparedItemIds,
    Expression<int>? iconCode,
    Expression<String>? itemImagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (itemIds != null) 'item_ids': itemIds,
      if (preparedItemIds != null) 'prepared_item_ids': preparedItemIds,
      if (iconCode != null) 'icon_code': iconCode,
      if (itemImagePath != null) 'item_image_path': itemImagePath,
    });
  }

  BagsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? itemIds,
      Value<String>? preparedItemIds,
      Value<int?>? iconCode,
      Value<String?>? itemImagePath}) {
    return BagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds,
      preparedItemIds: preparedItemIds ?? this.preparedItemIds,
      iconCode: iconCode ?? this.iconCode,
      itemImagePath: itemImagePath ?? this.itemImagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (itemIds.present) {
      map['item_ids'] = Variable<String>(itemIds.value);
    }
    if (preparedItemIds.present) {
      map['prepared_item_ids'] = Variable<String>(preparedItemIds.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (itemImagePath.present) {
      map['item_image_path'] = Variable<String>(itemImagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('itemIds: $itemIds, ')
          ..write('preparedItemIds: $preparedItemIds, ')
          ..write('iconCode: $iconCode, ')
          ..write('itemImagePath: $itemImagePath')
          ..write(')'))
        .toString();
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  $MyDatabaseManager get managers => $MyDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $BagsTable bags = $BagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [items, bags];
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  Value<int> itemId,
  required String itemName,
  required String itemImagePath,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<int> itemId,
  Value<String> itemName,
  Value<String> itemImagePath,
});

class $$ItemsTableFilterComposer extends Composer<_$MyDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemImagePath => $composableBuilder(
      column: $table.itemImagePath, builder: (column) => ColumnFilters(column));
}

class $$ItemsTableOrderingComposer extends Composer<_$MyDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemImagePath => $composableBuilder(
      column: $table.itemImagePath,
      builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$MyDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemImagePath => $composableBuilder(
      column: $table.itemImagePath, builder: (column) => column);
}

class $$ItemsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$MyDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()> {
  $$ItemsTableTableManager(_$MyDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> itemId = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<String> itemImagePath = const Value.absent(),
          }) =>
              ItemsCompanion(
            itemId: itemId,
            itemName: itemName,
            itemImagePath: itemImagePath,
          ),
          createCompanionCallback: ({
            Value<int> itemId = const Value.absent(),
            required String itemName,
            required String itemImagePath,
          }) =>
              ItemsCompanion.insert(
            itemId: itemId,
            itemName: itemName,
            itemImagePath: itemImagePath,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$MyDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$MyDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()>;
typedef $$BagsTableCreateCompanionBuilder = BagsCompanion Function({
  Value<int> id,
  required String name,
  required String itemIds,
  Value<String> preparedItemIds,
  Value<int?> iconCode,
  Value<String?> itemImagePath,
});
typedef $$BagsTableUpdateCompanionBuilder = BagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> itemIds,
  Value<String> preparedItemIds,
  Value<int?> iconCode,
  Value<String?> itemImagePath,
});

class $$BagsTableFilterComposer extends Composer<_$MyDatabase, $BagsTable> {
  $$BagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemIds => $composableBuilder(
      column: $table.itemIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preparedItemIds => $composableBuilder(
      column: $table.preparedItemIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemImagePath => $composableBuilder(
      column: $table.itemImagePath, builder: (column) => ColumnFilters(column));
}

class $$BagsTableOrderingComposer extends Composer<_$MyDatabase, $BagsTable> {
  $$BagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemIds => $composableBuilder(
      column: $table.itemIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preparedItemIds => $composableBuilder(
      column: $table.preparedItemIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemImagePath => $composableBuilder(
      column: $table.itemImagePath,
      builder: (column) => ColumnOrderings(column));
}

class $$BagsTableAnnotationComposer extends Composer<_$MyDatabase, $BagsTable> {
  $$BagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get itemIds =>
      $composableBuilder(column: $table.itemIds, builder: (column) => column);

  GeneratedColumn<String> get preparedItemIds => $composableBuilder(
      column: $table.preparedItemIds, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get itemImagePath => $composableBuilder(
      column: $table.itemImagePath, builder: (column) => column);
}

class $$BagsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $BagsTable,
    Bag,
    $$BagsTableFilterComposer,
    $$BagsTableOrderingComposer,
    $$BagsTableAnnotationComposer,
    $$BagsTableCreateCompanionBuilder,
    $$BagsTableUpdateCompanionBuilder,
    (Bag, BaseReferences<_$MyDatabase, $BagsTable, Bag>),
    Bag,
    PrefetchHooks Function()> {
  $$BagsTableTableManager(_$MyDatabase db, $BagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> itemIds = const Value.absent(),
            Value<String> preparedItemIds = const Value.absent(),
            Value<int?> iconCode = const Value.absent(),
            Value<String?> itemImagePath = const Value.absent(),
          }) =>
              BagsCompanion(
            id: id,
            name: name,
            itemIds: itemIds,
            preparedItemIds: preparedItemIds,
            iconCode: iconCode,
            itemImagePath: itemImagePath,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String itemIds,
            Value<String> preparedItemIds = const Value.absent(),
            Value<int?> iconCode = const Value.absent(),
            Value<String?> itemImagePath = const Value.absent(),
          }) =>
              BagsCompanion.insert(
            id: id,
            name: name,
            itemIds: itemIds,
            preparedItemIds: preparedItemIds,
            iconCode: iconCode,
            itemImagePath: itemImagePath,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BagsTableProcessedTableManager = ProcessedTableManager<
    _$MyDatabase,
    $BagsTable,
    Bag,
    $$BagsTableFilterComposer,
    $$BagsTableOrderingComposer,
    $$BagsTableAnnotationComposer,
    $$BagsTableCreateCompanionBuilder,
    $$BagsTableUpdateCompanionBuilder,
    (Bag, BaseReferences<_$MyDatabase, $BagsTable, Bag>),
    Bag,
    PrefetchHooks Function()>;

class $MyDatabaseManager {
  final _$MyDatabase _db;
  $MyDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$BagsTableTableManager get bags => $$BagsTableTableManager(_db, _db.bags);
}
