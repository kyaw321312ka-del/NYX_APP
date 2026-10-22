import 'package:flutter_test/flutter_test.dart';
import 'package:nyxproject/features/orders/domain/entities/payment.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/domain/entities/product.dart';
import 'package:nyxproject/features/shop/domain/entities/shop_order_request.dart';
import 'package:nyxproject/features/shop/domain/entities/tax.dart';
import 'package:nyxproject/features/shop/domain/repositories/shop_repository.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_categories.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_products.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_shop_payment_methods.dart';
import 'package:nyxproject/features/shop/domain/usecases/get_shop_tax.dart';
import 'package:nyxproject/features/shop/domain/usecases/place_shop_order.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_catalog_state.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_checkout_cubit.dart';
import 'package:nyxproject/features/shop/presentation/bloc/shop_session_cubit.dart';
import 'package:nyxproject/features/shop/domain/usecases/validate_shop_session.dart';

void main() {
  group('ShopCatalogCubit', () {
    test(
      'loads catalog data and applies search, brand, and sort filters',
      () async {
        final repository = _FakeShopRepository(
          products: [
            _product(id: 1, name: 'Phone Pro', brand: 'Acme', price: 300),
            _product(id: 2, name: 'Phone Mini', brand: 'Acme', price: 200),
            _product(id: 3, name: 'Tablet', brand: 'Other', price: 100),
          ],
          categories: [Category(id: 1, name: 'Devices', imageUrl: '')],
        );
        final cubit = ShopCatalogCubit(
          getProducts: GetProducts(repository),
          getCategories: GetCategories(repository),
        );
        addTearDown(cubit.close);

        await cubit.load(includeCategories: true);

        expect(cubit.state.status, ShopCatalogStatus.success);
        expect(cubit.state.categories, hasLength(1));
        expect(cubit.state.brands, containsAll(['All', 'Acme', 'Other']));

        cubit.setSearchQuery('phone');
        cubit.selectBrand('Acme');
        cubit.selectSortOrder(ShopSortOrder.priceAscending);

        expect(cubit.state.filteredProducts.map((product) => product.id), [
          2,
          1,
        ]);
      },
    );

    test('reports product loading failures in state', () async {
      final cubit = ShopCatalogCubit(
        getProducts: GetProducts(
          _FakeShopRepository(productError: Exception('Catalog unavailable')),
        ),
        getCategories: GetCategories(_FakeShopRepository()),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, ShopCatalogStatus.failure);
      expect(
        cubit.state.errorMessage,
        'Something went wrong. Please try again.',
      );
    });
  });

  test('ShopCheckoutCubit submits an order and exposes the response', () async {
    final repository = _FakeShopRepository();
    final cubit = ShopCheckoutCubit(
      getPaymentMethods: GetShopPaymentMethods(repository),
      getTax: GetShopTax(repository),
      placeOrder: PlaceShopOrder(repository),
    );
    addTearDown(cubit.close);
    final request = ShopOrderRequest(
      userId: 7,
      customerName: 'Customer',
      phone: '555',
      email: 'customer@example.com',
      deliveryAddress: 'Main Street',
      remark: '',
      paymentMethod: 'cash on delivery',
      items: const [
        {'product_id': 3, 'quantity': 2},
      ],
      tax: 10,
      totalAmount: 210,
      token: 'token',
    );

    await cubit.placeOrder(request);

    expect(repository.submittedRequest, same(request));
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.orderResponse, {
      'success': true,
      'data': {'id': 42},
    });
    expect(cubit.state.submitError, isNull);
  });

  test('ShopSessionCubit validates a session through its use case', () async {
    final cubit = ShopSessionCubit(
      validateSession: ValidateShopSession(_FakeShopRepository()),
    );
    addTearDown(cubit.close);

    await cubit.validate('valid-token');

    expect(cubit.state.status, ShopSessionStatus.valid);
    expect(cubit.state.shouldLogout, isFalse);
  });
}

Product _product({
  required int id,
  required String name,
  required String brand,
  required int price,
}) {
  return Product(
    id: id,
    productName: name,
    price: price,
    cost: price,
    description: '',
    warranty: '',
    rating: '',
    made: '',
    brand: brand,
    category: 'Devices',
    images: '',
    publicIds: '',
    types: '',
    colors: '',
    sizes: '',
    weights: '',
    totalStock: '10',
    status: 'available',
  );
}

class _FakeShopRepository implements ShopRepository {
  _FakeShopRepository({
    this.products = const [],
    this.categories = const [],
    this.productError,
  });

  final List<Product> products;
  final List<Category> categories;
  final Object? productError;
  ShopOrderRequest? submittedRequest;

  @override
  Future<List<Product>> getProducts() async {
    if (productError != null) throw productError!;
    return products;
  }

  @override
  Future<bool> validateSession({required String token}) async => true;

  @override
  Future<List<Category>> getCategories() async => categories;

  @override
  Future<List<PaymentMethod>> getPaymentMethods({String? token}) async => [];

  @override
  Future<Tax> getTax() async => Tax(id: 1, tax: 5);

  @override
  Future<Map<String, dynamic>> placeOrder(ShopOrderRequest request) async {
    submittedRequest = request;
    return const {
      'success': true,
      'data': {'id': 42},
    };
  }
}
