// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;
  const CategoryRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoryRow copyWith({int? id, String? name}) => CategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
      'sale_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stockActualMeta =
      const VerificationMeta('stockActual');
  @override
  late final GeneratedColumn<int> stockActual = GeneratedColumn<int>(
      'stock_actual', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minStockMeta =
      const VerificationMeta('minStock');
  @override
  late final GeneratedColumn<int> minStock = GeneratedColumn<int>(
      'min_stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        name,
        description,
        categoryId,
        purchasePrice,
        salePrice,
        stockActual,
        minStock,
        photoPath,
        active
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
          _stockActualMeta,
          stockActual.isAcceptableOrUnknown(
              data['stock_actual']!, _stockActualMeta));
    }
    if (data.containsKey('min_stock')) {
      context.handle(_minStockMeta,
          minStock.isAcceptableOrUnknown(data['min_stock']!, _minStockMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price'])!,
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sale_price'])!,
      stockActual: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_actual'])!,
      minStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_stock'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final int id;
  final String code;
  final String name;
  final String description;
  final int categoryId;
  final double purchasePrice;
  final double salePrice;

  /// Existencias derivadas: solo cambian mediante movimientos confirmados.
  final int stockActual;
  final int minStock;
  final String? photoPath;
  final bool active;
  const ProductRow(
      {required this.id,
      required this.code,
      required this.name,
      required this.description,
      required this.categoryId,
      required this.purchasePrice,
      required this.salePrice,
      required this.stockActual,
      required this.minStock,
      this.photoPath,
      required this.active});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['category_id'] = Variable<int>(categoryId);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['sale_price'] = Variable<double>(salePrice);
    map['stock_actual'] = Variable<int>(stockActual);
    map['min_stock'] = Variable<int>(minStock);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      description: Value(description),
      categoryId: Value(categoryId),
      purchasePrice: Value(purchasePrice),
      salePrice: Value(salePrice),
      stockActual: Value(stockActual),
      minStock: Value(minStock),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      active: Value(active),
    );
  }

  factory ProductRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      stockActual: serializer.fromJson<int>(json['stockActual']),
      minStock: serializer.fromJson<int>(json['minStock']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<int>(categoryId),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'salePrice': serializer.toJson<double>(salePrice),
      'stockActual': serializer.toJson<int>(stockActual),
      'minStock': serializer.toJson<int>(minStock),
      'photoPath': serializer.toJson<String?>(photoPath),
      'active': serializer.toJson<bool>(active),
    };
  }

  ProductRow copyWith(
          {int? id,
          String? code,
          String? name,
          String? description,
          int? categoryId,
          double? purchasePrice,
          double? salePrice,
          int? stockActual,
          int? minStock,
          Value<String?> photoPath = const Value.absent(),
          bool? active}) =>
      ProductRow(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        stockActual: stockActual ?? this.stockActual,
        minStock: minStock ?? this.minStock,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        active: active ?? this.active,
      );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      stockActual:
          data.stockActual.present ? data.stockActual.value : this.stockActual,
      minStock: data.minStock.present ? data.minStock.value : this.minStock,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('stockActual: $stockActual, ')
          ..write('minStock: $minStock, ')
          ..write('photoPath: $photoPath, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, description, categoryId,
      purchasePrice, salePrice, stockActual, minStock, photoPath, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.purchasePrice == this.purchasePrice &&
          other.salePrice == this.salePrice &&
          other.stockActual == this.stockActual &&
          other.minStock == this.minStock &&
          other.photoPath == this.photoPath &&
          other.active == this.active);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> description;
  final Value<int> categoryId;
  final Value<double> purchasePrice;
  final Value<double> salePrice;
  final Value<int> stockActual;
  final Value<int> minStock;
  final Value<String?> photoPath;
  final Value<bool> active;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.minStock = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.active = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    this.description = const Value.absent(),
    required int categoryId,
    this.purchasePrice = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.minStock = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.active = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        categoryId = Value(categoryId);
  static Insertable<ProductRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? categoryId,
    Expression<double>? purchasePrice,
    Expression<double>? salePrice,
    Expression<int>? stockActual,
    Expression<int>? minStock,
    Expression<String>? photoPath,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (salePrice != null) 'sale_price': salePrice,
      if (stockActual != null) 'stock_actual': stockActual,
      if (minStock != null) 'min_stock': minStock,
      if (photoPath != null) 'photo_path': photoPath,
      if (active != null) 'active': active,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? description,
      Value<int>? categoryId,
      Value<double>? purchasePrice,
      Value<double>? salePrice,
      Value<int>? stockActual,
      Value<int>? minStock,
      Value<String?>? photoPath,
      Value<bool>? active}) {
    return ProductsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stockActual: stockActual ?? this.stockActual,
      minStock: minStock ?? this.minStock,
      photoPath: photoPath ?? this.photoPath,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<int>(stockActual.value);
    }
    if (minStock.present) {
      map['min_stock'] = Variable<int>(minStock.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('salePrice: $salePrice, ')
          ..write('stockActual: $stockActual, ')
          ..write('minStock: $minStock, ')
          ..write('photoPath: $photoPath, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $MovementsTable extends Movements
    with TableInfo<$MovementsTable, MovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _previousStockMeta =
      const VerificationMeta('previousStock');
  @override
  late final GeneratedColumn<int> previousStock = GeneratedColumn<int>(
      'previous_stock', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _resultingStockMeta =
      const VerificationMeta('resultingStock');
  @override
  late final GeneratedColumn<int> resultingStock = GeneratedColumn<int>(
      'resulting_stock', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _responsibleMeta =
      const VerificationMeta('responsible');
  @override
  late final GeneratedColumn<String> responsible = GeneratedColumn<String>(
      'responsible', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        type,
        quantity,
        previousStock,
        resultingStock,
        reason,
        responsible,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movements';
  @override
  VerificationContext validateIntegrity(Insertable<MovementRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('previous_stock')) {
      context.handle(
          _previousStockMeta,
          previousStock.isAcceptableOrUnknown(
              data['previous_stock']!, _previousStockMeta));
    } else if (isInserting) {
      context.missing(_previousStockMeta);
    }
    if (data.containsKey('resulting_stock')) {
      context.handle(
          _resultingStockMeta,
          resultingStock.isAcceptableOrUnknown(
              data['resulting_stock']!, _resultingStockMeta));
    } else if (isInserting) {
      context.missing(_resultingStockMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('responsible')) {
      context.handle(
          _responsibleMeta,
          responsible.isAcceptableOrUnknown(
              data['responsible']!, _responsibleMeta));
    } else if (isInserting) {
      context.missing(_responsibleMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      previousStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}previous_stock'])!,
      resultingStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}resulting_stock'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      responsible: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}responsible'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $MovementsTable createAlias(String alias) {
    return $MovementsTable(attachedDatabase, alias);
  }
}

class MovementRow extends DataClass implements Insertable<MovementRow> {
  final int id;
  final int productId;
  final String type;
  final int quantity;
  final int previousStock;
  final int resultingStock;
  final String reason;
  final String responsible;
  final DateTime occurredAt;
  const MovementRow(
      {required this.id,
      required this.productId,
      required this.type,
      required this.quantity,
      required this.previousStock,
      required this.resultingStock,
      required this.reason,
      required this.responsible,
      required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    map['previous_stock'] = Variable<int>(previousStock);
    map['resulting_stock'] = Variable<int>(resultingStock);
    map['reason'] = Variable<String>(reason);
    map['responsible'] = Variable<String>(responsible);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  MovementsCompanion toCompanion(bool nullToAbsent) {
    return MovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      type: Value(type),
      quantity: Value(quantity),
      previousStock: Value(previousStock),
      resultingStock: Value(resultingStock),
      reason: Value(reason),
      responsible: Value(responsible),
      occurredAt: Value(occurredAt),
    );
  }

  factory MovementRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementRow(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      previousStock: serializer.fromJson<int>(json['previousStock']),
      resultingStock: serializer.fromJson<int>(json['resultingStock']),
      reason: serializer.fromJson<String>(json['reason']),
      responsible: serializer.fromJson<String>(json['responsible']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'previousStock': serializer.toJson<int>(previousStock),
      'resultingStock': serializer.toJson<int>(resultingStock),
      'reason': serializer.toJson<String>(reason),
      'responsible': serializer.toJson<String>(responsible),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  MovementRow copyWith(
          {int? id,
          int? productId,
          String? type,
          int? quantity,
          int? previousStock,
          int? resultingStock,
          String? reason,
          String? responsible,
          DateTime? occurredAt}) =>
      MovementRow(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        previousStock: previousStock ?? this.previousStock,
        resultingStock: resultingStock ?? this.resultingStock,
        reason: reason ?? this.reason,
        responsible: responsible ?? this.responsible,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  MovementRow copyWithCompanion(MovementsCompanion data) {
    return MovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      previousStock: data.previousStock.present
          ? data.previousStock.value
          : this.previousStock,
      resultingStock: data.resultingStock.present
          ? data.resultingStock.value
          : this.resultingStock,
      reason: data.reason.present ? data.reason.value : this.reason,
      responsible:
          data.responsible.present ? data.responsible.value : this.responsible,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('previousStock: $previousStock, ')
          ..write('resultingStock: $resultingStock, ')
          ..write('reason: $reason, ')
          ..write('responsible: $responsible, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, type, quantity, previousStock,
      resultingStock, reason, responsible, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.previousStock == this.previousStock &&
          other.resultingStock == this.resultingStock &&
          other.reason == this.reason &&
          other.responsible == this.responsible &&
          other.occurredAt == this.occurredAt);
}

class MovementsCompanion extends UpdateCompanion<MovementRow> {
  final Value<int> id;
  final Value<int> productId;
  final Value<String> type;
  final Value<int> quantity;
  final Value<int> previousStock;
  final Value<int> resultingStock;
  final Value<String> reason;
  final Value<String> responsible;
  final Value<DateTime> occurredAt;
  const MovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.previousStock = const Value.absent(),
    this.resultingStock = const Value.absent(),
    this.reason = const Value.absent(),
    this.responsible = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  MovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required String type,
    required int quantity,
    required int previousStock,
    required int resultingStock,
    required String reason,
    required String responsible,
    required DateTime occurredAt,
  })  : productId = Value(productId),
        type = Value(type),
        quantity = Value(quantity),
        previousStock = Value(previousStock),
        resultingStock = Value(resultingStock),
        reason = Value(reason),
        responsible = Value(responsible),
        occurredAt = Value(occurredAt);
  static Insertable<MovementRow> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<int>? previousStock,
    Expression<int>? resultingStock,
    Expression<String>? reason,
    Expression<String>? responsible,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (previousStock != null) 'previous_stock': previousStock,
      if (resultingStock != null) 'resulting_stock': resultingStock,
      if (reason != null) 'reason': reason,
      if (responsible != null) 'responsible': responsible,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  MovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<String>? type,
      Value<int>? quantity,
      Value<int>? previousStock,
      Value<int>? resultingStock,
      Value<String>? reason,
      Value<String>? responsible,
      Value<DateTime>? occurredAt}) {
    return MovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousStock: previousStock ?? this.previousStock,
      resultingStock: resultingStock ?? this.resultingStock,
      reason: reason ?? this.reason,
      responsible: responsible ?? this.responsible,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (previousStock.present) {
      map['previous_stock'] = Variable<int>(previousStock.value);
    }
    if (resultingStock.present) {
      map['resulting_stock'] = Variable<int>(resultingStock.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (responsible.present) {
      map['responsible'] = Variable<String>(responsible.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('previousStock: $previousStock, ')
          ..write('resultingStock: $resultingStock, ')
          ..write('reason: $reason, ')
          ..write('responsible: $responsible, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _responsibleNameMeta =
      const VerificationMeta('responsibleName');
  @override
  late final GeneratedColumn<String> responsibleName = GeneratedColumn<String>(
      'responsible_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _storeNameMeta =
      const VerificationMeta('storeName');
  @override
  late final GeneratedColumn<String> storeName = GeneratedColumn<String>(
      'store_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _seededMeta = const VerificationMeta('seeded');
  @override
  late final GeneratedColumn<bool> seeded = GeneratedColumn<bool>(
      'seeded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("seeded" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, responsibleName, storeName, seeded];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('responsible_name')) {
      context.handle(
          _responsibleNameMeta,
          responsibleName.isAcceptableOrUnknown(
              data['responsible_name']!, _responsibleNameMeta));
    }
    if (data.containsKey('store_name')) {
      context.handle(_storeNameMeta,
          storeName.isAcceptableOrUnknown(data['store_name']!, _storeNameMeta));
    }
    if (data.containsKey('seeded')) {
      context.handle(_seededMeta,
          seeded.isAcceptableOrUnknown(data['seeded']!, _seededMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      responsibleName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}responsible_name'])!,
      storeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_name'])!,
      seeded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}seeded'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String responsibleName;
  final String storeName;
  final bool seeded;
  const ProfileRow(
      {required this.id,
      required this.responsibleName,
      required this.storeName,
      required this.seeded});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['responsible_name'] = Variable<String>(responsibleName);
    map['store_name'] = Variable<String>(storeName);
    map['seeded'] = Variable<bool>(seeded);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      responsibleName: Value(responsibleName),
      storeName: Value(storeName),
      seeded: Value(seeded),
    );
  }

  factory ProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      responsibleName: serializer.fromJson<String>(json['responsibleName']),
      storeName: serializer.fromJson<String>(json['storeName']),
      seeded: serializer.fromJson<bool>(json['seeded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'responsibleName': serializer.toJson<String>(responsibleName),
      'storeName': serializer.toJson<String>(storeName),
      'seeded': serializer.toJson<bool>(seeded),
    };
  }

  ProfileRow copyWith(
          {int? id,
          String? responsibleName,
          String? storeName,
          bool? seeded}) =>
      ProfileRow(
        id: id ?? this.id,
        responsibleName: responsibleName ?? this.responsibleName,
        storeName: storeName ?? this.storeName,
        seeded: seeded ?? this.seeded,
      );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      responsibleName: data.responsibleName.present
          ? data.responsibleName.value
          : this.responsibleName,
      storeName: data.storeName.present ? data.storeName.value : this.storeName,
      seeded: data.seeded.present ? data.seeded.value : this.seeded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('responsibleName: $responsibleName, ')
          ..write('storeName: $storeName, ')
          ..write('seeded: $seeded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, responsibleName, storeName, seeded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.responsibleName == this.responsibleName &&
          other.storeName == this.storeName &&
          other.seeded == this.seeded);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> responsibleName;
  final Value<String> storeName;
  final Value<bool> seeded;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.responsibleName = const Value.absent(),
    this.storeName = const Value.absent(),
    this.seeded = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.responsibleName = const Value.absent(),
    this.storeName = const Value.absent(),
    this.seeded = const Value.absent(),
  });
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? responsibleName,
    Expression<String>? storeName,
    Expression<bool>? seeded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (responsibleName != null) 'responsible_name': responsibleName,
      if (storeName != null) 'store_name': storeName,
      if (seeded != null) 'seeded': seeded,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? responsibleName,
      Value<String>? storeName,
      Value<bool>? seeded}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      responsibleName: responsibleName ?? this.responsibleName,
      storeName: storeName ?? this.storeName,
      seeded: seeded ?? this.seeded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (responsibleName.present) {
      map['responsible_name'] = Variable<String>(responsibleName.value);
    }
    if (storeName.present) {
      map['store_name'] = Variable<String>(storeName.value);
    }
    if (seeded.present) {
      map['seeded'] = Variable<bool>(seeded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('responsibleName: $responsibleName, ')
          ..write('storeName: $storeName, ')
          ..write('seeded: $seeded')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $MovementsTable movements = $MovementsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [categories, products, movements, profiles];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
      _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.products,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.products.categoryId));

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter productsRefs(
      ComposableFilter Function($$ProductsTableFilterComposer f) f) {
    final $$ProductsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder, parentComposers) =>
            $$ProductsTableFilterComposer(ComposerState(
                $state.db, $state.db.products, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, $$CategoriesTableReferences),
    CategoryRow,
    PrefetchHooks Function({bool productsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._productsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .productsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, $$CategoriesTableReferences),
    CategoryRow,
    PrefetchHooks Function({bool productsRefs})>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String code,
  required String name,
  Value<String> description,
  required int categoryId,
  Value<double> purchasePrice,
  Value<double> salePrice,
  Value<int> stockActual,
  Value<int> minStock,
  Value<String?> photoPath,
  Value<bool> active,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> name,
  Value<String> description,
  Value<int> categoryId,
  Value<double> purchasePrice,
  Value<double> salePrice,
  Value<int> stockActual,
  Value<int> minStock,
  Value<String?> photoPath,
  Value<bool> active,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.products.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MovementsTable, List<MovementRow>>
      _movementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.movements,
              aliasName:
                  $_aliasNameGenerator(db.products.id, db.movements.productId));

  $$MovementsTableProcessedTableManager get movementsRefs {
    final manager = $$MovementsTableTableManager($_db, $_db.movements)
        .filter((f) => f.productId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_movementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get purchasePrice => $state.composableBuilder(
      column: $state.table.purchasePrice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get salePrice => $state.composableBuilder(
      column: $state.table.salePrice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get stockActual => $state.composableBuilder(
      column: $state.table.stockActual,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get minStock => $state.composableBuilder(
      column: $state.table.minStock,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get photoPath => $state.composableBuilder(
      column: $state.table.photoPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get active => $state.composableBuilder(
      column: $state.table.active,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $state.db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriesTableFilterComposer(ComposerState($state.db,
                $state.db.categories, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter movementsRefs(
      ComposableFilter Function($$MovementsTableFilterComposer f) f) {
    final $$MovementsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.movements,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder, parentComposers) =>
            $$MovementsTableFilterComposer(ComposerState(
                $state.db, $state.db.movements, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get purchasePrice => $state.composableBuilder(
      column: $state.table.purchasePrice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get salePrice => $state.composableBuilder(
      column: $state.table.salePrice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get stockActual => $state.composableBuilder(
      column: $state.table.stockActual,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get minStock => $state.composableBuilder(
      column: $state.table.minStock,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get photoPath => $state.composableBuilder(
      column: $state.table.photoPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get active => $state.composableBuilder(
      column: $state.table.active,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $state.db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CategoriesTableOrderingComposer(ComposerState($state.db,
                $state.db.categories, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, $$ProductsTableReferences),
    ProductRow,
    PrefetchHooks Function({bool categoryId, bool movementsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProductsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProductsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<double> salePrice = const Value.absent(),
            Value<int> stockActual = const Value.absent(),
            Value<int> minStock = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<bool> active = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            code: code,
            name: name,
            description: description,
            categoryId: categoryId,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            stockActual: stockActual,
            minStock: minStock,
            photoPath: photoPath,
            active: active,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String name,
            Value<String> description = const Value.absent(),
            required int categoryId,
            Value<double> purchasePrice = const Value.absent(),
            Value<double> salePrice = const Value.absent(),
            Value<int> stockActual = const Value.absent(),
            Value<int> minStock = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<bool> active = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            code: code,
            name: name,
            description: description,
            categoryId: categoryId,
            purchasePrice: purchasePrice,
            salePrice: salePrice,
            stockActual: stockActual,
            minStock: minStock,
            photoPath: photoPath,
            active: active,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false, movementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (movementsRefs) db.movements],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ProductsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ProductsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (movementsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProductsTableReferences._movementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .movementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, $$ProductsTableReferences),
    ProductRow,
    PrefetchHooks Function({bool categoryId, bool movementsRefs})>;
typedef $$MovementsTableCreateCompanionBuilder = MovementsCompanion Function({
  Value<int> id,
  required int productId,
  required String type,
  required int quantity,
  required int previousStock,
  required int resultingStock,
  required String reason,
  required String responsible,
  required DateTime occurredAt,
});
typedef $$MovementsTableUpdateCompanionBuilder = MovementsCompanion Function({
  Value<int> id,
  Value<int> productId,
  Value<String> type,
  Value<int> quantity,
  Value<int> previousStock,
  Value<int> resultingStock,
  Value<String> reason,
  Value<String> responsible,
  Value<DateTime> occurredAt,
});

final class $$MovementsTableReferences
    extends BaseReferences<_$AppDatabase, $MovementsTable, MovementRow> {
  $$MovementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.movements.productId, db.products.id));

  $$ProductsTableProcessedTableManager? get productId {
    if ($_item.productId == null) return null;
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id($_item.productId!));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MovementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get previousStock => $state.composableBuilder(
      column: $state.table.previousStock,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get resultingStock => $state.composableBuilder(
      column: $state.table.resultingStock,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get reason => $state.composableBuilder(
      column: $state.table.reason,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get responsible => $state.composableBuilder(
      column: $state.table.responsible,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get occurredAt => $state.composableBuilder(
      column: $state.table.occurredAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $state.db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProductsTableFilterComposer(ComposerState(
                $state.db, $state.db.products, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MovementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get previousStock => $state.composableBuilder(
      column: $state.table.previousStock,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get resultingStock => $state.composableBuilder(
      column: $state.table.resultingStock,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get reason => $state.composableBuilder(
      column: $state.table.reason,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get responsible => $state.composableBuilder(
      column: $state.table.responsible,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get occurredAt => $state.composableBuilder(
      column: $state.table.occurredAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $state.db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProductsTableOrderingComposer(ComposerState(
                $state.db, $state.db.products, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MovementsTable,
    MovementRow,
    $$MovementsTableFilterComposer,
    $$MovementsTableOrderingComposer,
    $$MovementsTableCreateCompanionBuilder,
    $$MovementsTableUpdateCompanionBuilder,
    (MovementRow, $$MovementsTableReferences),
    MovementRow,
    PrefetchHooks Function({bool productId})> {
  $$MovementsTableTableManager(_$AppDatabase db, $MovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MovementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MovementsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> previousStock = const Value.absent(),
            Value<int> resultingStock = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> responsible = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
          }) =>
              MovementsCompanion(
            id: id,
            productId: productId,
            type: type,
            quantity: quantity,
            previousStock: previousStock,
            resultingStock: resultingStock,
            reason: reason,
            responsible: responsible,
            occurredAt: occurredAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required String type,
            required int quantity,
            required int previousStock,
            required int resultingStock,
            required String reason,
            required String responsible,
            required DateTime occurredAt,
          }) =>
              MovementsCompanion.insert(
            id: id,
            productId: productId,
            type: type,
            quantity: quantity,
            previousStock: previousStock,
            resultingStock: resultingStock,
            reason: reason,
            responsible: responsible,
            occurredAt: occurredAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$MovementsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$MovementsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MovementsTable,
    MovementRow,
    $$MovementsTableFilterComposer,
    $$MovementsTableOrderingComposer,
    $$MovementsTableCreateCompanionBuilder,
    $$MovementsTableUpdateCompanionBuilder,
    (MovementRow, $$MovementsTableReferences),
    MovementRow,
    PrefetchHooks Function({bool productId})>;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> responsibleName,
  Value<String> storeName,
  Value<bool> seeded,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> responsibleName,
  Value<String> storeName,
  Value<bool> seeded,
});

class $$ProfilesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get responsibleName => $state.composableBuilder(
      column: $state.table.responsibleName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get storeName => $state.composableBuilder(
      column: $state.table.storeName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get seeded => $state.composableBuilder(
      column: $state.table.seeded,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ProfilesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get responsibleName => $state.composableBuilder(
      column: $state.table.responsibleName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get storeName => $state.composableBuilder(
      column: $state.table.storeName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get seeded => $state.composableBuilder(
      column: $state.table.seeded,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    ProfileRow,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
    ProfileRow,
    PrefetchHooks Function()> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfilesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProfilesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> responsibleName = const Value.absent(),
            Value<String> storeName = const Value.absent(),
            Value<bool> seeded = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            responsibleName: responsibleName,
            storeName: storeName,
            seeded: seeded,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> responsibleName = const Value.absent(),
            Value<String> storeName = const Value.absent(),
            Value<bool> seeded = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            responsibleName: responsibleName,
            storeName: storeName,
            seeded: seeded,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    ProfileRow,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
    ProfileRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$MovementsTableTableManager get movements =>
      $$MovementsTableTableManager(_db, _db.movements);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
}
