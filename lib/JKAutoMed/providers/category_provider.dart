import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Modelss/category_model.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getAllCategories();
});

//   Sub Categories provider
final selectedCategoryIdProvider = StateProvider<String>((ref) => "");
final selectedSubcategoryIdsProvider = StateProvider<Set<String>>((ref) => {});
