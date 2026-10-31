import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/core/utils/file_exporter.dart';
import 'package:inventario/features/inventory/data/repositories/drift_movement_repository.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_filter.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/repositories/movement_repository.dart';
import 'package:inventario/features/inventory/domain/usecases/get_low_stock_products_use_case.dart';
import 'package:inventario/features/inventory/domain/usecases/get_movement_history_use_case.dart';
import 'package:inventario/features/inventory/domain/usecases/register_movement_use_case.dart';
import 'package:inventario/features/products/data/repositories/drift_product_repository.dart';
import 'package:inventario/features/products/domain/entities/category.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';
import 'package:inventario/features/products/domain/usecases/create_product_use_case.dart';
import 'package:inventario/features/products/domain/usecases/deactivate_product_use_case.dart';
import 'package:inventario/features/products/domain/usecases/find_product_use_case.dart';
import 'package:inventario/features/products/domain/usecases/update_product_use_case.dart';
import 'package:inventario/features/reports/data/drift_report_repository.dart';
import 'package:inventario/features/reports/domain/entities/inventory_report.dart';
import 'package:inventario/features/reports/domain/repositories/report_repository.dart';
import 'package:inventario/features/reports/domain/usecases/build_inventory_report_use_case.dart';
import 'package:inventario/features/reports/domain/usecases/export_inventory_csv_use_case.dart';
import 'package:inventario/features/settings/data/demo_data_seeder.dart';
import 'package:inventario/features/settings/data/repositories/drift_profile_repository.dart';
import 'package:inventario/features/settings/domain/entities/local_profile.dart';
import 'package:inventario/features/settings/domain/repositories/demo_data_repository.dart';
import 'package:inventario/features/settings/domain/repositories/profile_repository.dart';
import 'package:inventario/features/settings/domain/usecases/profile_use_cases.dart';
import 'package:inventario/features/settings/domain/usecases/seed_demo_data_use_case.dart';

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<ProductRepository> productRepositoryProvider =
    Provider<ProductRepository>(
  (Ref ref) => DriftProductRepository(ref.watch(appDatabaseProvider)),
);

final Provider<MovementRepository> movementRepositoryProvider =
    Provider<MovementRepository>(
  (Ref ref) => DriftMovementRepository(ref.watch(appDatabaseProvider)),
);

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
  (Ref ref) => DriftProfileRepository(ref.watch(appDatabaseProvider)),
);

final Provider<ReportRepository> reportRepositoryProvider =
    Provider<ReportRepository>(
  (Ref ref) => DriftReportRepository(ref.watch(productRepositoryProvider)),
);

final Provider<DemoDataRepository> demoDataRepositoryProvider =
    Provider<DemoDataRepository>(
  (Ref ref) => DemoDataSeeder(ref.watch(appDatabaseProvider)),
);

final Provider<FileExporter> fileExporterProvider =
    Provider<FileExporter>((Ref ref) => const FileExporter());

final Provider<CreateProductUseCase> createProductUseCaseProvider =
    Provider<CreateProductUseCase>(
  (Ref ref) => CreateProductUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<UpdateProductUseCase> updateProductUseCaseProvider =
    Provider<UpdateProductUseCase>(
  (Ref ref) => UpdateProductUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<DeactivateProductUseCase> deactivateProductUseCaseProvider =
    Provider<DeactivateProductUseCase>(
  (Ref ref) => DeactivateProductUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<ReactivateProductUseCase> reactivateProductUseCaseProvider =
    Provider<ReactivateProductUseCase>(
  (Ref ref) => ReactivateProductUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<FindProductByCodeUseCase> findProductByCodeUseCaseProvider =
    Provider<FindProductByCodeUseCase>(
  (Ref ref) => FindProductByCodeUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<SearchProductsUseCase> searchProductsUseCaseProvider =
    Provider<SearchProductsUseCase>(
  (Ref ref) => SearchProductsUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<RegisterMovementUseCase> registerMovementUseCaseProvider =
    Provider<RegisterMovementUseCase>(
  (Ref ref) => RegisterMovementUseCase(ref.watch(movementRepositoryProvider)),
);

final Provider<GetMovementHistoryUseCase> getMovementHistoryUseCaseProvider =
    Provider<GetMovementHistoryUseCase>(
  (Ref ref) => GetMovementHistoryUseCase(ref.watch(movementRepositoryProvider)),
);

final Provider<GetLowStockProductsUseCase> getLowStockProductsUseCaseProvider =
    Provider<GetLowStockProductsUseCase>(
  (Ref ref) => GetLowStockProductsUseCase(ref.watch(productRepositoryProvider)),
);

final Provider<BuildInventoryReportUseCase> buildInventoryReportUseCaseProvider =
    Provider<BuildInventoryReportUseCase>(
  (Ref ref) => BuildInventoryReportUseCase(ref.watch(reportRepositoryProvider)),
);

final Provider<ExportInventoryCsvUseCase> exportInventoryCsvUseCaseProvider =
    Provider<ExportInventoryCsvUseCase>(
  (Ref ref) => ExportInventoryCsvUseCase(
    ref.watch(reportRepositoryProvider),
    ref.watch(fileExporterProvider),
  ),
);

final Provider<GetProfileUseCase> getProfileUseCaseProvider =
    Provider<GetProfileUseCase>(
  (Ref ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)),
);

final Provider<SaveProfileUseCase> saveProfileUseCaseProvider =
    Provider<SaveProfileUseCase>(
  (Ref ref) => SaveProfileUseCase(ref.watch(profileRepositoryProvider)),
);

final Provider<SeedDemoDataUseCase> seedDemoDataUseCaseProvider =
    Provider<SeedDemoDataUseCase>(
  (Ref ref) => SeedDemoDataUseCase(ref.watch(demoDataRepositoryProvider)),
);

/// Carga los datos de demostración antes de mostrar la aplicación.
final FutureProvider<bool> bootstrapProvider = FutureProvider<bool>(
  (Ref ref) => ref.watch(seedDemoDataUseCaseProvider)(),
);

final StreamProvider<LocalProfile> profileProvider =
    StreamProvider<LocalProfile>(
  (Ref ref) => ref.watch(getProfileUseCaseProvider).watch(),
);

final StreamProvider<List<Product>> productsProvider =
    StreamProvider<List<Product>>(
  (Ref ref) => ref.watch(productRepositoryProvider).watchProducts(),
);

final StreamProvider<List<Product>> allProductsProvider =
    StreamProvider<List<Product>>(
  (Ref ref) =>
      ref.watch(productRepositoryProvider).watchProducts(includeInactive: true),
);

final StreamProvider<List<Product>> lowStockProvider =
    StreamProvider<List<Product>>(
  (Ref ref) => ref.watch(productRepositoryProvider).watchLowStockProducts(),
);

final StreamProvider<List<Category>> categoriesProvider =
    StreamProvider<List<Category>>(
  (Ref ref) => ref.watch(productRepositoryProvider).watchCategories(),
);

final FutureProvider<InventoryReport> inventoryReportProvider =
    FutureProvider<InventoryReport>((Ref ref) async {
  await ref.watch(allProductsProvider.future);
  return ref.watch(buildInventoryReportUseCaseProvider)();
});

final AutoDisposeFutureProviderFamily<Product?, int> productByIdProvider =
    FutureProvider.autoDispose.family<Product?, int>(
  (Ref ref, int id) => ref.watch(productRepositoryProvider).findById(id),
);

final AutoDisposeFutureProviderFamily<Product?, String> productByCodeProvider =
    FutureProvider.autoDispose.family<Product?, String>(
  (Ref ref, String code) =>
      ref.watch(productRepositoryProvider).findByCode(code),
);

/// Filtro activo del historial de movimientos.
class MovementFilterNotifier extends Notifier<MovementFilter> {
  @override
  MovementFilter build() => const MovementFilter();

  void setProduct(int? productId) {
    state = productId == null
        ? state.copyWith(clearProduct: true)
        : state.copyWith(productId: productId);
  }

  void setType(MovementType? type) {
    state =
        type == null ? state.copyWith(clearType: true) : state.copyWith(type: type);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = (from == null && to == null)
        ? state.copyWith(clearDates: true)
        : state.copyWith(from: from, to: to);
  }

  void clear() => state = const MovementFilter();
}

final NotifierProvider<MovementFilterNotifier, MovementFilter>
    movementFilterProvider =
    NotifierProvider<MovementFilterNotifier, MovementFilter>(
  MovementFilterNotifier.new,
);

final StreamProviderFamily<List<Movement>, MovementFilter>
    movementHistoryProvider =
    StreamProvider.family<List<Movement>, MovementFilter>(
  (Ref ref, MovementFilter filter) =>
      ref.watch(getMovementHistoryUseCaseProvider).watch(filter),
);
