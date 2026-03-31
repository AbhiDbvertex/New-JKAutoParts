import 'ajugnu_auth.dart';
import 'api_handler.dart';

class CategoryRepository {
  static final CategoryRepository _instance = CategoryRepository._internal();
  List<Map<String, String>>? allCategories;

  CategoryRepository._internal();

  factory CategoryRepository() {
    return _instance;
  }

  bool doesCategoriesAvailableLocally() {
    return allCategories != null;
  }
///All product categories
  Future<List<Map<String, String>>> getCategories() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(endpoint:'/api/category/GetAllCategories',
          authorization: AjugnuAuth().getUser()?.token);
      print("  get all api response ${response}");
    } catch (error) {
      rethrow;
    }
    allCategories = [];
    if (response.statusCode == 200) {
      for (var categoryJson in response.responseBody) {
        if (categoryJson is Map<String, dynamic>) {
          allCategories!.add({
            '_id': categoryJson['_id'] ?? '',
            'name': categoryJson['category_name'] ?? '',
            'image': "${categoryJson['category_image'] ?? ''}"

            // 'image': "$ajugnuBaseUrl/${categoryJson['category_image'] ?? ''}"
          });
        }
      }
    }
    return allCategories!;
  }

}