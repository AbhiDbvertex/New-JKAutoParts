//  import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jkautomed/JKAutoMed/Services/Api_Service.dart';
// import 'package:jkautomed/JKAutoMed/screens/prduct_detail_screen.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../Modelss/product_list_model.dart';
// import '../providers/category_provider.dart';
// import '../providers/product_list_provider.dart';
//
// class ProductListScreen extends ConsumerWidget {
//   final hidekey;
//   const ProductListScreen(this.hidekey, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
//     final selectedSubIds = ref.watch(selectedSubcategoryIdsProvider);
//
//     final productsAsync = ref.watch(productsProvider);
//     // final isFav = ref.watch(favoriteProvider).contains(prodId);
//
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value:  SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               /*hidekey == "hidekey" ?*/  Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: const Icon(
//                         Icons.arrow_back,
//                         color: Color(0xFF2F3FD4),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Expanded(
//                       child: Text(
//                         "Products",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ) /*: SizedBox()*/ ,
//
//               Expanded(
//                 child: productsAsync.when(
//                   loading: () => _buildShimmerGrid(), // Loading → Shimmer
//                   error:
//                       (err, stack) => Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.error_outline,
//                               size: 60,
//                               color: Colors.red,
//                             ),
//                             const SizedBox(height: 16),
//                             Text("Error: $err"),
//                             const SizedBox(height: 8),
//                             ElevatedButton(
//                               // onPressed:
//                                   // () => ref.refresh(
//                                   //   productsBySelectionProvider((
//                                   //     categoryId: selectedCategoryId,
//                                   //     subcategoryIds: selectedSubIds.toList(),
//                                   //   )),
//                                   // ),
//                               onPressed: () => ref.refresh(productsProvider),
//                               child: const Text("Retry"),
//                             ),
//                           ],
//                         ),
//                       ),
//                   data: (products) {
//                     if (products.isEmpty) {
//                       return const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.inventory_2_outlined,
//                               size: 80,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               "No products found",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "No product found on this subcategory",
//                               style: TextStyle(color: Colors.grey),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//
//                     return GridView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             childAspectRatio: 0.9,
//                             crossAxisSpacing: 6,
//                             mainAxisSpacing: 6,
//                           ),
//                       itemCount: products.length,
//                       itemBuilder: (context, index) {
//                         return _buildProductCard(products[index],context,ref);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Shimmer Grid (loading)
//   Widget _buildShimmerGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.9,
//         crossAxisSpacing: 6,
//         mainAxisSpacing: 6,
//       ),
//       itemCount: 8,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   height: 190,
//                   width: 170,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 60,
//                   child: Container(
//                     height: 110,
//                     width: 140,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFDCE1FF),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 8,
//                   child: Container(width: 140, height: 50, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // // Real Product Card (तुम्हारा original design)
//   // Widget _buildProductCard(Product product,context) {
//   //   final favs = ref.watch(favoriteProvider);
//   //   final isFav = favs.contains(product.id);
//
//   Widget _buildProductCard(Product product, BuildContext context, WidgetRef ref) {
//     final favs = ref.watch(favoriteProvider);
//     final isFav = favs.contains(product.id);
//
//
//     return GestureDetector(
//       onTap: (){
//         print("Abhi:- print OrderId: ${product.id ?? ""}");
//         Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductDetailScreen(productId: product.id,)));
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(3.0),
//               child: Container(
//                 height: 190,
//                 width: 170,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 6,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             Positioned(
//               bottom: 60,
//               child: Container(
//                 height: 115,
//                 width: 140,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFDCE1FF),
//                   // color: const Color(0xFFDCE1FF),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       top: 8,
//                       left: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 6,
//                           vertical: 2,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.star, size: 12, color: Colors.black),
//                             SizedBox(width: 2),
//                             Text(
//                               "4.5",
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 6,
//                       right: 6,
//                       child: InkWell(
//                         // onTap: (){
//                         //   ApiService.addToFavorite(product.id);
//                         // },
//                         onTap: () async {
//                           try {
//                             final res = await ApiService.addToFavorite(product.id);
//
//                             ref.read(favoriteProvider.notifier).add(product.id);
//
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(res['message'] ?? "Added to favorite ❤️"),
//                                 backgroundColor: Colors.green,
//                               ),
//                             );
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text("Something went wrong"),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           }
//                         },
//                         child: CircleAvatar(
//                           radius: 14,
//                           backgroundColor: Colors.white,
//                           child: /*Icon(
//                             Icons.favorite_border,
//                             size: 16,
//                             color: Color(0xFF6A6FCB),
//                           ),*/
//                           Icon(
//                             isFav ? Icons.favorite : Icons.favorite_border,
//                             size: 16,
//                             color: isFav ? Colors.red : Color(0xFF6A6FCB),
//                           ),
//
//                         ),
//                       ),
//                     ),
//                     Center(
//                       child:
//                           product.images.isEmpty
//                               ? Image.asset(
//                                 "assets/images/about_us_logo.png",
//                                 height: 60,
//                               )
//                               : CachedNetworkImage(
//                                 imageUrl: product.images[0],
//                                 height: 60,
//                                 placeholder:
//                                     (context, url) => Shimmer.fromColors(
//                                       baseColor: Colors.grey[300]!,
//                                       highlightColor: Colors.grey[100]!,
//                                       child: Container(
//                                         color: Colors.white,
//                                         height: 60,
//                                         width: 60,
//                                       ),
//                                     ),
//                                 errorWidget:
//                                     (context, url, error) => Image.asset(
//                                       "assets/images/about_us_logo.png",
//                                       height: 60,
//                                     ),
//                               ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             Positioned(
//               bottom: 4,
//               child: SizedBox(
//                 width: 140,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.partnumber,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 8,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ), Text(
//                       product.name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//
//                     const SizedBox(height: 2),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             product.categoryName,
//                             style:  TextStyle(
//                               fontSize: 10,
//                               color: Colors.black54,
//                             ),
//                             maxLines: 1,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2F3FD4),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             "₹ ${product.price.toStringAsFixed(2)}",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jkautomed/JKAutoMed/Services/Api_Service.dart';
import 'package:jkautomed/JKAutoMed/screens/prduct_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Modelss/product_list_model.dart';
import '../providers/category_provider.dart';
import '../providers/product_list_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String hidekey;
  const ProductListScreen(this.hidekey, {Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2F3FD4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Products",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF2F3FD4)),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: ProductSearchDelegate(
                            allProducts: productsAsync.value ?? [],
                            ref: ref,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: productsAsync.when(
                  loading: () => _buildShimmerGrid(),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Error: $err"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.refresh(productsProvider),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No products found",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "No product found on this subcategory",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(products[index], context, ref);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 260,
                  width: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  child: Container(
                    height: 260,
                    width: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE1FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  child: Container(width: 140, height: 50, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoriteProvider);
    final isFav = favs.contains(product.id);

    return GestureDetector(
      onTap: () {
        print("Abhi:- print OrderId: ${product.avgRating ?? ""}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                height: 230,
                width: 170,
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
              ),
            ),
            Positioned(
              bottom: 60,
              child: Container(
                height: 115,
                width: 140,
                decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.black),
                            SizedBox(width: 2),
                            Text(
                                product.avgRating,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () async {
                          try {
                            final res = await ApiService.addToFavorite(product.id);
                            ref.read(favoriteProvider.notifier).add(product.id);

                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(res['message'] ?? "Added to favorite"),
                            //     backgroundColor: Colors.green,
                            //   ),
                            // );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Something went wrong"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : const Color(0xFF6A6FCB),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: product.images.isEmpty
                          ? Image.asset("assets/images/about_us_logo.png", height: 60)
                          : CachedNetworkImage(
                        imageUrl: product.images[0],
                        height: 60,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white, height: 60, width: 60),
                        ),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/images/about_us_logo.png", height: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 3,
              child: SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Part Nub:",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700),
                        ),  Text(
                          product.partnumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reference Nub:",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700),
                        ),  Expanded(
                          child: Text(
                            product.refranceNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    // const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.subcategoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F3FD4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "₹ ${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Delegate
class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> allProducts;
  final WidgetRef ref;

  ProductSearchDelegate({required this.allProducts, required this.ref});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Start typing to search products"));
    }

    final lowerQuery = query.toLowerCase();
    final results = allProducts.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.partnumber.toLowerCase().contains(lowerQuery) ||
          p.refranceNumber.toLowerCase().contains(lowerQuery) ||
          p.subcategoryName.toLowerCase().contains(lowerQuery);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildProductCardStatic(results[index], context, ref);
      },
    );
  }

  Widget _buildProductCardStatic(Product product, BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoriteProvider);
    final isFav = favs.contains(product.id);

    return GestureDetector(
      onTap: () {
        print("Abhi:- print OrderId: ${product.id ?? ""}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                height: 190,
                width: 170,
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
              ),
            ),
            Positioned(
              bottom: 65,
              child: Container(
                height: 115,
                width: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.black),
                            SizedBox(width: 2),
                            Text(
                              "4.5",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 6,
                      child: InkWell(
                        onTap: () async {
                          try {
                            final res = await ApiService.addToFavorite(product.id);
                            ref.read(favoriteProvider.notifier).add(product.id);
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(res['message'] ?? "Added to favorite ❤️"),
                            //     backgroundColor: Colors.green,
                            //   ),
                            // );
                          } catch (e) {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text("Something went wrong"),
                            //     backgroundColor: Colors.red,
                            //   ),
                            // );
                          }
                        },
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : const Color(0xFF6A6FCB),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: product.images.isEmpty
                          ? Image.asset("assets/images/about_us_logo.png", height: 60)
                          : CachedNetworkImage(
                        imageUrl: product.images[0],
                        height: 60,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white, height: 60, width: 60),
                        ),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/images/about_us_logo.png", height: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              child: SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.partnumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      product.refranceNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.subcategoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F3FD4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "₹ ${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}