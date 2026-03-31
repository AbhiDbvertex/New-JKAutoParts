import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Modelss/product_list_model.dart' show Product;
import '../Services/Api_Service.dart';
import 'category_provider.dart'; // agar category wale providers alag file mein hain

// API service provider
final productApiServiceProvider = Provider<ApiService>(
      (ref) => ApiService(),
);

// Products list provider
final productsProvider = FutureProvider<List<Product>>((ref) async {
  // Pehle favorites sync ho jaaye
  await ref.watch(favoritesSyncProvider.future);

  final categoryId = ref.watch(selectedCategoryIdProvider);
  final subcategoryIds = ref.watch(selectedSubcategoryIdsProvider).toList();

  if (subcategoryIds.isEmpty) {
    return [];
  }

  final apiService = ref.read(productApiServiceProvider);

  return await apiService.getProductsByCategory(
    categoryId: categoryId,
    subcategoryIds: subcategoryIds,
  );
});

// ❤️ Favorite state provider (Set of product IDs)
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, Set<String>>(
      (ref) => FavoriteNotifier(),
);

// ← YE NAJA PROVIDER YAHAN ADD KARO
final favoritesSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  try {
    final response = await ApiService.getFavoriteProducts();

    if (response != null && response['status'] == true) {
      final List<dynamic> favoritesList = response['favorites'];

      final List<String> favoriteIds = favoritesList
          .map((item) => item['product_id']['_id'] as String)
          .toList();

      // Local favorite state ko server ke according sync kar do
      ref.read(favoriteProvider.notifier).syncWithServer(favoriteIds);
    } else {
      ref.read(favoriteProvider.notifier).clearAll();
    }
  } catch (e) {
    debugPrint("Favorites sync error: $e");
    ref.read(favoriteProvider.notifier).clearAll();
  }
});

class FavoriteNotifier extends StateNotifier<Set<String>> {
  FavoriteNotifier() : super({});

  void add(String id) {
    state = {...state, id};
  }

  void remove(String id) {
    state = state.where((e) => e != id).toSet();
  }

  bool isFav(String id) => state.contains(id);

  void syncWithServer(List<String> favoriteProductIds) {
    state = favoriteProductIds.toSet();
  }

  void clearAll() {
    state = {};
  }
}