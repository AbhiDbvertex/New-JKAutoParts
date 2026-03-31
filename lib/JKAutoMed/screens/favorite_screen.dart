// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../Modelss/favorite_model.dart'; // Tumhara naye models wala file
// import '../Services/Api_Service.dart';
//
// class FavoriteScreen extends StatefulWidget {
//   const FavoriteScreen({Key? key}) : super(key: key);
//
//   @override
//   State<FavoriteScreen> createState() => _FavoriteScreenState();
// }
//
// class _FavoriteScreenState extends State<FavoriteScreen> {
//   List<Product> favorites = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchFavorites();
//   }
//
//   Future<void> _fetchFavorites() async {
//     setState(() => isLoading = true);
//
//     try {
//       final response = await ApiService.getFavoriteProducts();
//
//       if (response == null) {
//         setState(() {
//           favorites = [];
//         });
//         Fluttertoast.showToast(msg: 'No data found');
//         return;
//       }
//
//       final favoriteResponse =
//       FavoriteProductResponse.fromJson(response);
//
//       if (favoriteResponse.status == true) {
//         setState(() {
//           favorites = favoriteResponse.favorites
//               .map((item) => item.product)
//               .toList();
//         });
//       } else {
//         setState(() {
//           favorites = [];
//         });
//         Fluttertoast.showToast(msg: favoriteResponse.message);
//       }
//     } catch (e) {
//       debugPrint("Favorite fetch error: $e");
//       setState(() {
//         favorites = [];
//       });
//       Fluttertoast.showToast(msg: 'Something went wrong');
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }
//
//
//
//   Future<void> _removeFavorite(String productId) async {
//     // Pehle local list se remove kar do – instant UI update
//     setState(() {
//       favorites.removeWhere((item) => item.id == productId);
//     });
//
//     try {
//       final response = await ApiService.removeFavoriteProduct(productId);
//       if (response['status'] == true) {
//         Fluttertoast.showToast(msg: 'Removed from favorites');
//
//         // Ab server se fresh data lao (sync ke liye)
//         await _fetchFavorites();
//       } else {
//         Fluttertoast.showToast(msg: response['message'] ?? 'Failed to remove');
//         // Agar server se fail hua to local wapas add kar do (rollback)
//         await _fetchFavorites();
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error removing favorite');
//       // Error par bhi sync kar lo
//       await _fetchFavorites();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Favorites'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         foregroundColor: Colors.black,
//       ),
//
//       body: RefreshIndicator(
//         onRefresh: _fetchFavorites,
//         color: Colors.orange,
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(), // Yeh zaroori hai empty state ke liye
//           children: [
//             isLoading
//                 ? _buildShimmerGrid()
//                 : favorites.isEmpty
//                 ? SizedBox(
//               height: MediaQuery.of(context).size.height - 100,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     const Text('No favorites yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
//                     const SizedBox(height: 8),
//                     Text('Pull down to refresh', style: TextStyle(color: Colors.grey[600])),
//                   ],
//                 ),
//               ),
//             )
//                 : GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(), // GridView ko scroll na karne do
//               padding: const EdgeInsets.all(12),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.78,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//               ),
//               itemCount: favorites.length,
//               itemBuilder: (context, index) {
//                 final Product product = favorites[index];
//                 return _buildProductCard(context, product);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductCard(BuildContext context, Product product) {
//     const String baseUrl = 'https://api.jkautomed.graphicsvolume.com/';
//     bool isFav = true; // Yeh favorite screen hai to always filled heart
//
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     return GestureDetector(
//       onTap: () {
//         // Future mein product details page par navigate kar sakte ho
//         // Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
//       },
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Main Card Shadow
//           Container(
//             height: height*0.29,
//             width: 170,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 6,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//           ),
//
//           // Image Section
//           Positioned(
//             bottom: height*0.1,
//             child: Container(
//               height: height*0.16,
//               width: 140,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFDCE1FF),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Stack(
//                 children: [
//                   // Rating Badge
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         children: const [
//                           Icon(Icons.star, size: 12, color: Colors.black),
//                           SizedBox(width: 2),
//                           Text(
//                             "4.5", // Agar dynamic chahiye to: product.averageRating.toStringAsFixed(1)
//                             style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Remove Favorite Button
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: InkWell(
//                       onTap: () async {
//                         await _removeFavorite(product.id);
//                       },
//                       child: const CircleAvatar(
//                         radius: 14,
//                         backgroundColor: Colors.white,
//                         child: Icon(
//                           Icons.favorite,
//                           size: 16,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Product Image
//                   Center(
//                     child: product.productImages.isEmpty
//                         ? Image.asset(
//                       "assets/images/about_us_logo.png",
//                       height: 60,
//                       fit: BoxFit.contain,
//                     )
//                         : CachedNetworkImage(
//                       imageUrl: baseUrl + product.productImages[0],
//                       height: 60,
//                       fit: BoxFit.contain,
//                       placeholder: (context, url) => Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Container(color: Colors.white, height: 60, width: 60),
//                       ),
//                       errorWidget: (context, url, error) => Image.asset(
//                         "assets/images/about_us_logo.png",
//                         height: 60,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Product Name & Price Section
//           Positioned(
//             bottom: height*0.03,
//             child: SizedBox(
//               width: 140,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.partnumber ?? "",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),Text(
//                     product.productName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           product.subcategoryName,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Colors.black54,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF2F3FD4),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           "\$${product.price.toStringAsFixed(2)}",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShimmerGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(12),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.78,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       itemCount: 6,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             height: 190,
//             width: 170,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Modelss/favorite_model.dart';
import '../Services/Api_Service.dart';
// import '../../providers/favorite_provider.dart';
import '../providers/product_list_provider.dart'; // upar wala file

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);
    await ref.read(favoritesSyncProvider.future); // server se sync
    setState(() => isLoading = false);
  }

  Future<void> _removeFavorite(String productId) async {
    // Optimistic remove
    ref.read(favoriteProvider.notifier).remove(productId);

    try {
      // Tumhari toggle API ya remove API
      final response = await ApiService.toggleFavorite(productId);
      // ya await ApiService.removeFavoriteProduct(productId);

      if (response['status'] != true) {
        // Rollback
        ref.read(favoriteProvider.notifier).add(productId);
       // Fluttertoast.showToast(msg: response['message'] ?? 'Failed');
      } else {
       // Fluttertoast.showToast(msg: 'Removed from favorites');
      }
    } catch (e) {
      ref.read(favoriteProvider.notifier).add(productId);
     // Fluttertoast.showToast(msg: 'Network error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: Colors.orange,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            isLoading
                ? _buildShimmerGrid()
                : favoriteIds.isEmpty
                ? _buildEmptyState()
                : FutureBuilder<List<Product>>(
              future: _fetchFavoriteProductsDetails(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, products[index]);
                    },
                  );
                }
                return _buildShimmerGrid();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No favorites yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Pull down to refresh', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Server se full product details wali list laao
  Future<List<Product>> _fetchFavoriteProductsDetails() async {
    final response = await ApiService.getFavoriteProducts();
    if (response != null && response['status'] == true) {
      return FavoriteProductResponse.fromJson(response)
          .favorites
          .map((item) => item.product)
          .toList();
    }
    return [];
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // const String baseUrl = 'https://api.jkautomed.graphicsvolume.com/';
    const String baseUrl = 'https://api.jkautomedglobal.in/';
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // Navigator.push to detail
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: height * 0.29,
            width: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 6)),
              ],
            ),
          ),
          Positioned(
            bottom: height * 0.1,
            child: Container(
              height: height * 0.16,
              width: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  // Rating
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.black),
                            SizedBox(width: 2),
                            Text("4.5", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => _removeFavorite(product.id),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite, size: 16, color: Colors.red),
                      ),
                    ),
                  ),
                  // Image
                  Center(
                    child: product.productImages.isEmpty
                        ? Image.asset("assets/images/about_us_logo.png", height: 60)
                        : CachedNetworkImage(
                      imageUrl: baseUrl + product.productImages[0],
                      height: 60,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Image.asset("assets/images/about_us_logo.png", height: 60),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Text section
          Positioned(
            bottom: height * 0.03,
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.partnumber ?? "", maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  Text(product.productName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.subcategoryName,
                            style: const TextStyle(fontSize: 10, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF2F3FD4), borderRadius: BorderRadius.circular(10)),
                        child: Text("\$${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 190,
          width: 170,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}