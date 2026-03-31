import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Services/Api_Service.dart';
import '../Modelss/get_card_model.dart';
// import '../Modelss/cart_full_response_model.dart'; // Naya model import

class CartNotifier extends StateNotifier<AsyncValue<CartResponse>> {
  final ApiService _apiService;

  // Har product ke liye individual loading state
  final Map<String, bool> _loadingMap = {};

  CartNotifier(this._apiService) : super(const AsyncLoading()) {
    fetchCart();
  }

  // Product loading mein hai ya nahi
  bool isLoading(String productId) => _loadingMap[productId] ?? false;

  // Subtotal calculate (latest cart items se)
  double get subtotal {
    if (state is! AsyncData) return 0.0;
    final items = state.value!.cartItems;
    return items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Shipping charge API se
  double get shipping => state.value?.courierData?.rate?.toDouble() ?? 0.0;

  // Total
  double get total => subtotal + shipping;

  // Address access karne ke liye helper
  UserFullAddress? get userAddress => state.value?.userfulladdress;

  // Server se full cart data lao
  Future<void> fetchCart() async {
    state = const AsyncLoading();
    _loadingMap.clear();

    try {
      final response = await _apiService.getCartProducts();

      final fullResponse = CartResponse.fromJson(response);

      if (fullResponse.status) {
        state = AsyncData(fullResponse);
      } else {
        state = AsyncData(CartResponse(
          status: false,
          message: fullResponse.message,
          cartItems: [],
          totalAmount: 0,
          totalWeight: 0,
        ));
      }
    } catch (e, stack) {
      debugPrint("Cart fetch error: $e");
      debugPrint(stack.toString());
      state = AsyncData(CartResponse(
        status: false,
        message: 'Error loading cart',
        cartItems: [],
        totalAmount: 0,
        totalWeight: 0,
      ));
    }
  }

  // Increase Quantity
  Future<void> increaseQuantity(String productId) async {
    if (isLoading(productId)) return;

    _loadingMap[productId] = true;
    _triggerRebuild();

    try {
      final currentItems = state.value?.cartItems ?? [];
      final index = currentItems.indexWhere((item) => item.product.id == productId);

      if (index != -1) {
        final newQty = currentItems[index].quantity + 1;
        await _apiService.increaseCartQuantity(productId, newQty);
      }

      await fetchCart(); // Fresh data lao
    } catch (e) {
      debugPrint("Increase quantity error: $e");
      await fetchCart();
    } finally {
      _loadingMap[productId] = false;
      _triggerRebuild();
    }
  }

  // Decrease Quantity
  Future<void> decreaseQuantity(String productId) async {
    if (isLoading(productId)) return;

    _loadingMap[productId] = true;
    _triggerRebuild();

    try {
      final currentItems = state.value?.cartItems ?? [];
      final index = currentItems.indexWhere((item) => item?.product.id == productId);

      if (index != -1) {
        final currentQty = currentItems[index].quantity;
        final newQty = currentQty - 1;

        if (newQty <= 0) {
          await removeItem(productId);
          return;
        }

        await _apiService.decreaseCartQuantity(productId, newQty);
      }

      await fetchCart();
    } catch (e) {
      debugPrint("Decrease quantity error: $e");
      await fetchCart();
    } finally {
      _loadingMap[productId] = false;
      _triggerRebuild();
    }
  }

  // Remove Item
  // Future<void> removeItem(String productId) async {
  //   if (isLoading(productId)) return;
  //
  //   _loadingMap[productId] = true;
  //   _triggerRebuild();
  //
  //   try {
  //     await _apiService.decreaseCartQuantity(productId, 0); // API mein 0 bhejke remove
  //     await fetchCart();
  //   } catch (e) {
  //     debugPrint("Remove item error: $e");
  //     await fetchCart();
  //   } finally {
  //     _loadingMap[productId] = false;
  //     _triggerRebuild();
  //   }
  // }

  // CartNotifier mein removeItem ko update kar do
  Future<void> removeItem(String productId) async {
    if (isLoading(productId)) return;

    _loadingMap[productId] = true;
    _triggerRebuild();

    try {
      // Tumhara dedicated delete endpoint
      await _apiService.deleteCartitem(productId);

      // Delete success ke baad fresh cart fetch karo
      await fetchCart();
    } catch (e) {
      debugPrint("Remove item error: $e");
      await fetchCart(); // Error mein bhi refresh kar do, item hata hoga
    } finally {
      _loadingMap[productId] = false;
      _triggerRebuild();
    }
  }

  // UI ko rebuild trigger karne ke liye (loading spinner ke liye)
  void _triggerRebuild() {
    if (state is AsyncData) {
      state = AsyncData(state.value!);
    } else if (state is AsyncLoading) {
      state = const AsyncLoading();
    }
  }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<CartResponse>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CartNotifier(apiService);
});
