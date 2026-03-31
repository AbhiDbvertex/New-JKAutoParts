// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jkautomed/JKAutoMed/screens/prduct_detail_screen.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../Services/Api_Service.dart';
// import '../providers/product_list_provider.dart'; // ← Yeh provider jahan favoriteProvider define hai
//
// class RecentProductsSection extends ConsumerStatefulWidget {
//   const RecentProductsSection({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<RecentProductsSection> createState() => _RecentProductsSectionState();
// }
//
// class _RecentProductsSectionState extends ConsumerState<RecentProductsSection> {
//   List<Map<String, dynamic>> recentProducts = [];
//   bool isLoading = true;
//   bool hasError = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchRecentProducts();
//     Future.microtask(() {
//       ref.read(favoriteProvider.notifier).clearAll();
//     });
//   }
//
//   Future<void> fetchRecentProducts() async {
//     try {
//       final apiService = ApiService();
//       final data = await apiService.getRecentProducts();
//
//       setState(() {
//         recentProducts = List<Map<String, dynamic>>.from(data);
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
//   // Shimmer Card
//   Widget shimmerCard() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           height: 190,
//           width: 170,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildProductCard(Map<String, dynamic> product) {
//     final String prodId = product['_id'] ?? "";
//     final String prodName = product['product_name'] ?? "No Name";
//     final double prodPrice = (product['price'] ?? 0).toDouble();
//     final List<String> prodImages = List<String>.from(product['product_images'] ?? []);
//     final String subcategoryName =
//         product['subcategory_name'] ?? product['category_name'] ?? "Category";
//
//     // Favorite status from Riverpod
//     final favs = ref.watch(favoriteProvider);
//     final bool isFavorite = favs.contains(prodId);
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
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Main Card Background
//             Container(
//               height: 190,
//               width: 170,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 6,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Product Image
//             Positioned(
//               bottom: 100,
//               child: Container(
//                 height: 110,
//                 width: 140,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFDCE1FF),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Center(
//                   child: prodImages.isEmpty
//                       ? Image.asset("assets/images/about_us_logo.png", height: 60)
//                       : CachedNetworkImage(
//                     imageUrl: prodImages[0],
//                     height: 60,
//                     placeholder: (_, __) => Shimmer.fromColors(
//                       baseColor: Colors.grey[300]!,
//                       highlightColor: Colors.grey[100]!,
//                       child: Container(color: Colors.white, height: 60, width: 60),
//                     ),
//                     errorWidget: (_, __, ___) => Image.asset("assets/images/about_us_logo.png", height: 60),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Rating Badge (Top Left)
//             Positioned(
//               top: 8,
//               left: 12,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.star, size: 14, color: Colors.amber),
//                     SizedBox(width: 4),
//                     Text("4.3", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Favorite Button (Top Right)
//             Positioned(
//               top: 8,
//               right: 12,
//               child: InkWell(
//                 onTap: () async {
//                   try {
//                     if (isFavorite) {
//                       // Remove from favorites (local only – agar remove API nahi hai)
//                       ref.read(favoriteProvider.notifier).remove(prodId);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Removed from favorites 💔")),
//                       );
//                     } else {
//                       // Add to favorites
//                       final res = await ApiService.addToFavorite(prodId);
//                       ref.read(favoriteProvider.notifier).add(prodId);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(res['message'] ?? "Added to favorites ❤️"),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Something went wrong"), backgroundColor: Colors.red),
//                     );
//                   }
//                 },
//                 child: CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     isFavorite ? Icons.favorite : Icons.favorite_border,
//                     color: isFavorite ? Colors.red : Colors.grey,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//
//             // Product Name & Price (Bottom)
//             Positioned(
//               bottom: 38,
//               child: SizedBox(
//                 width: 140,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       prodName,
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
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return SizedBox(
//         height: 240,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: 4,
//           itemBuilder: (_, __) => shimmerCard(),
//         ),
//       );
//     }
//
//     if (hasError || recentProducts.isEmpty) {
//       return const SizedBox(); // Ya kuch message dikha sakte ho
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Optional Title
//         // const Padding(
//         //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         //   child: Text("Recently Viewed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         // ),
//
//         SizedBox(
//           height: 240,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: recentProducts.length,
//             itemBuilder: (context, index) {
//               return SizedBox(
//                 width: 186,
//                 child: buildProductCard(recentProducts[index]),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jkautomed/JKAutoMed/screens/prduct_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Services/Api_Service.dart';
import '../providers/product_list_provider.dart'; // ← Yeh provider jahan favoriteProvider define hai

class RecentProductsSection extends ConsumerStatefulWidget {
  const RecentProductsSection({Key? key}) : super(key: key);

  @override
  ConsumerState<RecentProductsSection> createState() => _RecentProductsSectionState();
}

class _RecentProductsSectionState extends ConsumerState<RecentProductsSection> {
  List<Map<String, dynamic>> recentProducts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecentProducts();
    // Future.microtask(() {
    //   ref.read(favoriteProvider.notifier).clearAll();
    // });
  }

  Future<void> fetchRecentProducts() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getRecentProducts();

      setState(() {
        recentProducts = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Shimmer Card (ek single card ka loading effect)
  Widget shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 240, // Grid ke liye thoda zyada height diya
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Loading ke time pura GridView shimmer
  Widget buildShimmerGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 170 / 240, // card ka shape
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 8, // loading mein 8 fake cards
      itemBuilder: (_, __) => shimmerCard(),
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final String prodId = product['_id'] ?? "";
    final String prodName = product['product_name'] ?? "No Name";
    final String partsNumber = product['part_number'] ?? "No Parts";
    final String refranceNumber = product['reference_number'] ?? "No Parts";
    final String categoryName = product['category_name'] ?? "Category";
    final double prodPrice = (product['price'] ?? 0).toDouble();
    final List<String> prodImages = List<String>.from(product['product_images'] ?? []);
    final String subcategoryName =
        product['subcategory_name'] ?? product['category_name'] ?? "Category";

    // Favorite status Riverpod se
    final favs = ref.watch(favoriteProvider);
    final bool isFavorite = favs.contains(prodId);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // return GestureDetector(
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (_) => ProductDetailScreen(productId: prodId),
    //         ),
    //       );
    //     },
    //     child: Padding(
    //       padding: const EdgeInsets.all(2.0),
    //       child: Stack(
    //         alignment: Alignment.center,
    //         clipBehavior: Clip.hardEdge, // ⭐ MAIN FIX
    //         children: [
    //           // Main Card Background
    //           Card(
    //             clipBehavior: Clip.hardEdge,
    //             child: Container(
    //               height: height*1.9,
    //               width: /*170*/ width*1.9,
    //               decoration: BoxDecoration(
    //                 color: Colors.red,
    //                 borderRadius: BorderRadius.circular(16),
    //                 boxShadow: [
    //                   // BoxShadow(
    //                   //   color: Colors.black.withOpacity(0.8),
    //                   //   blurRadius: 6,
    //                   //   offset: const Offset(0, 6),
    //                   // ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //
    //           // Product Image
    //           // Positioned(
    //           //   // bottom: 100 ,
    //           //   bottom: /*100*/ height*0.1,
    //           //   child: Container(
    //           //     height: height*0.17,
    //           //     width: width *0.9,
    //           //     decoration: BoxDecoration(
    //           //       color: const Color(0xFFDCE1FF),
    //           //       borderRadius: BorderRadius.circular(14),
    //           //     ),
    //           //     child: Center(
    //           //       child: prodImages.isEmpty
    //           //           ? Image.asset("assets/images/about_us_logo.png", height: height*2,)
    //           //           : CachedNetworkImage(
    //           //         imageUrl: prodImages[0],
    //           //         // height: height*2,
    //           //         placeholder: (_, __) => Shimmer.fromColors(
    //           //           baseColor: Colors.grey[300]!,
    //           //           highlightColor: Colors.grey[100]!,
    //           //           child: Container(color: Colors.white, height: 60, width: width *0.5,),
    //           //         ),
    //           //         errorWidget: (_, __, ___) => Image.asset("assets/images/about_us_logo.png", height: 60,width: width *0.5,),
    //           //       ),
    //           //     ),
    //           //   ),
    //           // ),
    //           Positioned(
    //             bottom: height * 0.1,
    //             child: ClipRRect(
    //               borderRadius: BorderRadius.circular(14),
    //               child: Container(
    //                 height: height * 0.17,
    //                 width: width * 0.9,
    //                 color: const Color(0xFFDCE1FF),
    //                 child: CachedNetworkImage(
    //                   imageUrl: prodImages[0],
    //                   fit: BoxFit.contain, // IMPORTANT
    //                   placeholder: (_, __) => Shimmer.fromColors(
    //                     baseColor: Colors.grey[300]!,
    //                     highlightColor: Colors.grey[100]!,
    //                     child: Container(color: Colors.white),
    //                   ),
    //                   errorWidget: (_, __, ___) =>
    //                       Image.asset("assets/images/about_us_logo.png", fit: BoxFit.contain),
    //                 ),
    //               ),
    //             ),
    //           ),
    //
    //
    //           // Rating Badge (Top Left)
    //           Positioned(
    //             top: 8,
    //             left: 12,
    //             child: Container(
    //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(6),
    //               ),
    //               child: const Row(
    //                 children: [
    //                   Icon(Icons.star, size: 14, color: Colors.amber),
    //                   SizedBox(width: 4),
    //                   Text("4.3", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    //                 ],
    //               ),
    //             ),
    //           ),
    //
    //           // Favorite Button (Top Right)
    //           Positioned(
    //             top: 8,
    //             right: 12,
    //             child: InkWell(
    //               onTap: () async {
    //                 try {
    //                   if (isFavorite) {
    //                     // Remove from favorites (local only – agar remove API nahi hai)
    //                     ref.read(favoriteProvider.notifier).remove(prodId);
    //                     ScaffoldMessenger.of(context).showSnackBar(
    //                       const SnackBar(content: Text("Removed from favorites 💔")),
    //                     );
    //                   } else {
    //                     // Add to favorites
    //                     final res = await ApiService.addToFavorite(prodId);
    //                     ref.read(favoriteProvider.notifier).add(prodId);
    //                     ScaffoldMessenger.of(context).showSnackBar(
    //                       SnackBar(
    //                         content: Text(res['message'] ?? "Added to favorites ❤️"),
    //                         backgroundColor: Colors.green,
    //                       ),
    //                     );
    //                   }
    //                 } catch (e) {
    //                   ScaffoldMessenger.of(context).showSnackBar(
    //                     const SnackBar(content: Text("Something went wrong"), backgroundColor: Colors.red),
    //                   );
    //                 }
    //               },
    //               child: CircleAvatar(
    //                 radius: 16,
    //                 backgroundColor: Colors.white,
    //                 child: Icon(
    //                   isFavorite ? Icons.favorite : Icons.favorite_border,
    //                   color: isFavorite ? Colors.red : Colors.grey,
    //                   size: 20,
    //                 ),
    //               ),
    //             ),
    //           ),
    //
    //           // Product Name & Price (Bottom)
    //           Positioned(
    //             // bottom: 38,
    //             bottom: /*100*/ height*0.02,
    //             child: SizedBox(
    //               width: 140,
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     partsNumber,
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                     style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    //                   ),
    //                   Text(
    //                     prodName,
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    //                   ),
    //                   const SizedBox(height: 4),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Expanded(
    //                         child: Text(
    //                           categoryName,
    //                           maxLines: 1,
    //                           overflow: TextOverflow.ellipsis,
    //                           style: const TextStyle(fontSize: 10, color: Colors.black54),
    //                         ),
    //                       ),
    //                       Container(
    //                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    //                         decoration: BoxDecoration(
    //                           color: const Color(0xFF2F3FD4),
    //                           borderRadius: BorderRadius.circular(10),
    //                         ),
    //                         child: Text(
    //                           "₹ ${prodPrice.toStringAsFixed(2)}",
    //                           style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
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
    //     ),
    //   );
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: prodId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            // OUTER SHADOW
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [

                  // 🧱 MAIN CARD
                  Container(
                    height: height * 1.9,
                    width: width * 1.9,
                    color: Colors.white,
                  ),

                  // 🟦 PRODUCT IMAGE BOX
                  Positioned(
                    bottom: height * 0.1,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: height * 0.15,
                          width: width * 0.9,
                          color: const Color(0xFFDCE1FF),
                          child: prodImages.isEmpty
                              ? Image.asset(
                            "assets/images/about_us_logo.png",
                            fit: BoxFit.contain,
                          )
                              : CachedNetworkImage(
                            imageUrl: prodImages[0],
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (_, __, ___) =>
                                Image.asset(
                                  "assets/images/about_us_logo.png",
                                  fit: BoxFit.contain,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ⭐ RATING
                  Positioned(
                    top: 8,
                    left: 10,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            "4.3",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ❤️ FAVOURITE
                  Positioned(
                    top: 8,
                    right: 10,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: /*Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                        isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),*/ InkWell(
                        onTap: () async {
                          final notifier = ref.read(favoriteProvider.notifier);
                          final productId =prodId;

                          // Optimistic UI update
                          if (notifier.isFav(productId)) {
                            notifier.remove(productId);
                          //  Fluttertoast.showToast(msg: "Removing from favorites...");
                          } else {
                            notifier.add(productId);
                          //  Fluttertoast.showToast(msg: "Adding to favorites...");
                          }

                          try {
                            final response = await ApiService.toggleFavorite(productId);

                            if (response['status'] == true) {
                              // Success – already local mein update kar chuke ho, kuch nahi karna
                              //Fluttertoast.showToast(msg: response['message'] ?? "Favorite updated");
                            } else {
                              // Fail hua to rollback kar do
                              if (notifier.isFav(productId)) {
                                notifier.remove(productId);
                              } else {
                                notifier.add(productId);
                              }
                             // Fluttertoast.showToast(msg: "Failed, try again");
                            }
                          } catch (e) {
                            // Error pe rollback
                            if (notifier.isFav(productId)) {
                              notifier.remove(productId);
                            } else {
                              notifier.add(productId);
                            }
                           // Fluttertoast.showToast(msg: "Network error");
                          }
                        },
                        child: Icon(
                          ref.watch(favoriteProvider).contains(prodId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: ref.watch(favoriteProvider).contains(prodId)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // 📝 BOTTOM DETAILS
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   partsNumber,
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: const TextStyle(
                        //     fontSize: 10,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Part Nub:",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                            ), Text(
                              partsNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
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
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                            ), Expanded(
                              child: Text(
                                refranceNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        // Text(
                        //   prodName,
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),
                        Text(
                          prodName.isNotEmpty
                              ? prodName[0].toUpperCase() + prodName.substring(1)
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F3FD4),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Text(
                                "₹ ${prodPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
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
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildShimmerGrid();
    }

    if (hasError || recentProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "No product found!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 170 / 240,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: recentProducts.length,
        itemBuilder: (context, index) {
          return buildProductCard(recentProducts[index]);
        },
      ),
    );
  }
}