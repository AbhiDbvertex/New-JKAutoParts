// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jkautomed/JKAutoMed/screens/prduct_detail_screen.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../Services/Api_Service.dart';
// import '../providers/product_list_provider.dart';
//
// class SearchScreen extends ConsumerStatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends ConsumerState<SearchScreen> {
//   List<Map<String, dynamic>> allProducts = [];       // All fetched products
//   List<Map<String, dynamic>> filteredProducts = [];  // Filtered based on search
//   bool isLoading = true;
//   bool hasError = false;
//   final TextEditingController _searchController = TextEditingController();
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   fetchRecentProducts();
//   //   // Future.microtask(() {
//   //   //   ref.read(favoriteProvider.notifier).clearAll();
//   //   // });
//   //
//   //   Future.microtask(() async {
//   //     try {
//   //       final response = await ApiService.getFavoriteProducts();
//   //       if (response != null && response['status'] == true) {
//   //         final List<String> favoriteIds = (response['favorites'] as List)
//   //             .map((item) => item['product_id']['_id'] as String)
//   //             .toList();
//   //         ref.read(favoriteProvider.notifier).syncWithServer(favoriteIds);
//   //       }
//   //     } catch (e) {
//   //       debugPrint("Favorite sync failed in SearchScreen: $e");
//   //     }
//   //   });
//   //
//   //   // Listen to search input changes
//   //   _searchController.addListener(_onSearchChanged);
//   // }
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   // List<Map<String, dynamic>> filteredProducts = [];
//   // bool isLoading = false;
//
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> fetchRecentProducts() async {
//     try {
//       final apiService = ApiService();
//       final data = await apiService.getRecentProducts();
//
//       setState(() {
//         allProducts = List<Map<String, dynamic>>.from(data);
//         filteredProducts = allProducts; // Initially show all
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }
//
//   // void _onSearchChanged() {
//   //   final query = _searchController.text.toLowerCase().trim();
//   //
//   //   if (query.isEmpty) {
//   //     setState(() {
//   //       filteredProducts = allProducts;
//   //     });
//   //     return;
//   //   }
//   //
//   //   setState(() {
//   //     filteredProducts = allProducts.where((product) {
//   //       final String prodName = (product['product_name'] ?? "").toLowerCase();
//   //       final String partNumber = (product['part_number'] ?? "").toLowerCase();
//   //       final String rafrenceNumber = (product['reference_number'] ?? "").toLowerCase();
//   //       final String categoryName = (product['category_name'] ?? "").toLowerCase();
//   //       final String subcategoryName = (product['subcategory_name'] ?? "").toLowerCase();
//   //
//   //       return prodName.contains(query) ||
//   //           partNumber.contains(query) ||
//   //           rafrenceNumber.contains(query) ||
//   //           categoryName.contains(query) ||
//   //           subcategoryName.contains(query);
//   //     }).toList();
//   //   });
//   // }
//
//   void _onSearchChanged() async {
//     final query = _searchController.text.trim();
//
//     if (query.isEmpty) {
//       setState(() {
//         filteredProducts = [];
//       });
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final result = await ApiService.searchProducts(query);
//
//       setState(() {
//         filteredProducts = result;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         hasError = true;
//       });
//     }
//   }
//
//
//   // Realistic shimmer card
//   Widget shimmerCard() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 6,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Positioned(
//               top: 20,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   height: 140,
//                   width: 140,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//               ),
//             ),
//             const Positioned(
//               top: 8,
//               left: 12,
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   color: Colors.grey,
//                   borderRadius: BorderRadius.all(Radius.circular(6)),
//                 ),
//                 child: SizedBox(width: 50, height: 20),
//               ),
//             ),
//             const Positioned(
//               top: 8,
//               right: 12,
//               child: CircleAvatar(radius: 16, backgroundColor: Colors.grey),
//             ),
//             Positioned(
//               bottom: 16,
//               left: 12,
//               right: 12,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(height: 10, width: 100, color: Colors.grey),
//                   const SizedBox(height: 4),
//                   Container(height: 12, width: double.infinity, color: Colors.grey),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(height: 10, width: 80, color: Colors.grey),
//                       Container(
//                         height: 20,
//                         width: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.grey,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildShimmerGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(8),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 170 / 240,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//       ),
//       itemCount: 8,
//       itemBuilder: (_, __) => shimmerCard(),
//     );
//   }
//
//   Widget buildProductCard(Map<String, dynamic> product) {
//     final String prodId = product['_id'] ?? "";
//     final String prodName = product['product_name'] ?? "No Name";
//     final String categoryName = product['category_name'] ?? "Category";
//     final String partNumber = product['part_number'] ?? "";
//     final String refranceNumber = product['reference_number'] ?? "";
//     final double prodPrice = (product['price'] ?? 0).toDouble();
//     final List<String> prodImages = List<String>.from(product['product_images'] ?? []);
//     final String subcategoryName = product['subcategory_name'] ?? categoryName;
//
//     final bool isFavorite = ref.watch(favoriteProvider).contains(prodId);
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailScreen(productId: prodId),
//           ),
//         );
//       },
//       child: Material(
//         type: MaterialType.transparency,
//         child: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 6,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               // Product Image
//               Positioned(
//                 top: 20,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: Container(
//                     height: height*0.16,
//                     width: 140,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFDCE1FF),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Center(
//                       child: prodImages.isEmpty
//                           ? Image.asset("assets/images/about_us_logo.png", height: 100)
//                           : CachedNetworkImage(
//                         imageUrl: prodImages[0],
//                         height: 100,
//                         fit: BoxFit.contain,
//                         placeholder: (_, __) => Shimmer.fromColors(
//                           baseColor: Colors.grey[300]!,
//                           highlightColor: Colors.grey[100]!,
//                           child: Container(color: Colors.white),
//                         ),
//                         errorWidget: (_, __, ___) => Image.asset(
//                           "assets/images/about_us_logo.png",
//                           height: 60,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Rating Badge
//               const Positioned(
//                 top: 8,
//                 left: 12,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.all(Radius.circular(6)),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.star, size: 14, color: Colors.amber),
//                         SizedBox(width: 4),
//                         Text("4.3", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Favorite Button
//               Positioned(
//                 top: 8,
//                 right: 12,
//                 child: /*InkWell(
//                   onTap: () async {
//                     try {
//                       if (isFavorite) {
//                         ref.read(favoriteProvider.notifier).remove(prodId);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Removed from favorites")),
//                         );
//                       } else {
//                         final res = await ApiService.addToFavorite(prodId);
//                         ref.read(favoriteProvider.notifier).add(prodId);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(res['message'] ?? "Added to favorites"),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Something went wrong"),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   },
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       isFavorite ? Icons.favorite : Icons.favorite_border,
//                       color: isFavorite ? Colors.red : Colors.grey,
//                       size: 20,
//                     ),
//                   ),
//                 ),*/
//                 InkWell(
//                   onTap: () async {
//                     final notifier = ref.read(favoriteProvider.notifier);
//                     final productId =prodId;
//
//                     // Optimistic UI update
//                     if (notifier.isFav(productId)) {
//                       notifier.remove(productId);
//                     //  Fluttertoast.showToast(msg: "Removing from favorites...");
//                     } else {
//                       notifier.add(productId);
//                      // Fluttertoast.showToast(msg: "Adding to favorites...");
//                     }
//
//                     try {
//                       final response = await ApiService.toggleFavorite(productId);
//
//                       if (response['status'] == true) {
//                         // Success – already local mein update kar chuke ho, kuch nahi karna
//                        // Fluttertoast.showToast(msg: response['message'] ?? "Favorite updated");
//                       } else {
//                         // Fail hua to rollback kar do
//                         if (notifier.isFav(productId)) {
//                           notifier.remove(productId);
//                         } else {
//                           notifier.add(productId);
//                         }
//                        // Fluttertoast.showToast(msg: "Failed, try again");
//                       }
//                     } catch (e) {
//                       // Error pe rollback
//                       if (notifier.isFav(productId)) {
//                         notifier.remove(productId);
//                       } else {
//                         notifier.add(productId);
//                       }
//                      // Fluttertoast.showToast(msg: "Network error");
//                     }
//                   },
//                   child: Icon(
//                     ref.watch(favoriteProvider).contains(prodId)
//                         ? Icons.favorite
//                         : Icons.favorite_border,
//                     color: ref.watch(favoriteProvider).contains(prodId)
//                         ? Colors.red
//                         : Colors.grey,
//                   ),
//                 )
//               ),
//
//               // Product Info (Part Number, Name, Category, Price)
//               Positioned(
//                 bottom: 16,
//                 left: 12,
//                 right: 12,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (partNumber.isNotEmpty)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Part Nub:",
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 10, color: Colors.black87),
//                           ), Text(
//                             partNumber,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 10, color: Colors.black87),
//                           ),
//                         ],
//                       ),
//                     Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Reference Nub:",
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 10, color: Colors.black87),
//                           ), Expanded(
//                             child: Text(
//                               refranceNumber,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(fontSize: 10, color: Colors.black87),
//                             ),
//                           ),
//                         ],
//                       ),
//                     // Text(
//                     //   prodName,
//                     //   maxLines: 1,
//                     //   overflow: TextOverflow.ellipsis,
//                     //   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
//                     // ),
//                     Text(
//                       prodName.isNotEmpty
//                           ? prodName[0].toUpperCase() + prodName.substring(1)
//                           : '',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             subcategoryName,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 10, color: Colors.black54),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2F3FD4),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             "₹ ${prodPrice.toStringAsFixed(2)}",
//                             style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: (){
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text("Search Products"),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//         ),
//         body: Column(
//           children: [
//             // Search Bar
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search by name, part number or category...",
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                 ),
//               ),
//             ),
//
//             // Products Grid or Loading/Empty State
//             Expanded(
//               child: isLoading
//                   ? buildShimmerGrid()
//                   : (hasError || allProducts.isEmpty)
//                   ? const Center(
//                 child: Text(
//                   "No products found",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               )
//                   : filteredProducts.isEmpty
//                   ? const Center(
//                 child: Text(
//                   "No results match your search",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               )
//                   : GridView.builder(
//                 padding: const EdgeInsets.all(8),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 170 / 240,
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
//                 ),
//                 itemCount: filteredProducts.length,
//                 itemBuilder: (context, index) {
//                   return buildProductCard(filteredProducts[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jkautomed/JKAutoMed/screens/prduct_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../Services/Api_Service.dart';
import '../providers/product_list_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = false;
  bool hasError = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // 🔍 Search API Call
  void _onSearchChanged() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        filteredProducts = [];
        isLoading = false;
        hasError = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final result = await ApiService.searchProducts(query);

      // final results = await ApiService.removeFavoriteProduct();
      print("Abhi:- apiservice searchproduct query: ${query}");

      setState(() {
        filteredProducts = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // 🌀 Shimmer Card
  Widget shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 170 / 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => shimmerCard(),
    );
  }

  // 🛒 Product Card
  Widget buildProductCard(Map<String, dynamic> product) {
    final String prodId = product['_id'] ?? "";
    final String prodName = product['product_name'] ?? "";
    final String partNumber = product['part_number'] ?? "";
    final String referenceNumber = product['reference_number'] ?? "";
    final double prodPrice = (product['price'] ?? 0).toDouble();
    final List<String> prodImages =
    List<String>.from(product['product_images'] ?? []);
    final String subcategoryName = product['subcategory_name'] ?? "";

    final bool isFavorite = ref.watch(favoriteProvider).contains(prodId);

    // final isSetting = ref.watch(favoriteProvider).(pro)

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: prodId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: 120,
                  child: prodImages.isEmpty
                      ? Image.asset("assets/images/about_us_logo.png")
                      : CachedNetworkImage(
                    imageUrl: prodImages[0],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const CircularProgressIndicator(),
                    errorWidget: (_, __, ___) => Image.asset(
                      "assets/images/about_us_logo.png",
                    ),
                  ),
                ),
              ),
            ),//11+6+

            // Favourite
            Positioned(
              top: 8,
              right: 12,
              child: InkWell(
                onTap: () async {
                  final notifier = ref.read(favoriteProvider.notifier);
                  if (notifier.isFav(prodId)) {
                    notifier.remove(prodId);
                  } else {
                    notifier.add(prodId);
                  }
                  await ApiService.toggleFavorite(prodId);
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),

            // Info
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Part No: $partNumber",
                      style:
                      const TextStyle(fontSize: 10, color: Colors.black87)),
                  Text("Ref No: $referenceNumber",
                      style:
                      const TextStyle(fontSize: 10, color: Colors.black87)),
                  Text(
                    prodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subcategoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F3FD4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "₹ ${prodPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧱 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Search Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, part number or category...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? buildShimmerGrid()
                : hasError
                ? const Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
                : filteredProducts.isEmpty
                ? const Center(
              child: Text(
                "Search for products",
                style: TextStyle(
                    fontSize: 16, color: Colors.grey),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 170 / 240,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return buildProductCard(
                    filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}