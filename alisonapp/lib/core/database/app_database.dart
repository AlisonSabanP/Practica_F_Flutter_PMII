import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:inventario/core/utils/app_directories.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
}

@DataClassName('ProductRow')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 1, max: 32).unique()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
  RealColumn get salePrice => real().withDefault(const Constant(0))();

  /// Existencias derivadas: solo cambian mediante movimientos confirmados.
  IntColumn get stockActual => integer().withDefault(const Constant(0))();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  TextColumn get photoPath => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('MovementRow')
class Movements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get type => text().withLength(min: 1, max: 10)();
  IntColumn get quantity => integer()();
  IntColumn get previousStock => integer()();
  IntColumn get resultingStock => integer()();
  TextColumn get reason => text().withLength(min: 1, max: 200)();
  TextColumn get responsible => text().withLength(min: 1, max: 120)();
  DateTimeColumn get occurredAt => dateTime()();
}

@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get responsibleName => text().withDefault(const Constant(''))();
  TextColumn get storeName => text().withDefault(const Constant(''))();
  BoolColumn get seeded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(tables: <Type>[Categories, Products, Movements, Profiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory directory = await resolveAppDirectory();
    final File file = File(p.join(directory.path, 'inventario.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

