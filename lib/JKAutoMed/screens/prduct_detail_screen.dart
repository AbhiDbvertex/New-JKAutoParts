import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jkautomed/JKAutoMed/screens/viewImages.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ajugnu_constants.dart';
import '../Services/Api_Service.dart';
import '../providers/product_list_provider.dart';
import 'get_card_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends ConsumerState<ProductDetailScreen> {

  Map<String, dynamic>? productData;
  List<Map<String, dynamic>> relatedProducts = [];
  bool isLoading = true;
  bool isLoadingRelated = true;
  bool hasError = false;
  String errorMessage = "";

  int quantity = 1;

  @override
  void initState() {
    super.initState();
    fetchProduct();
    // ref.read(favoriteProvider.notifier).clearAll();
    // Yeh line change kar do
    // Future.microtask(() {
    //   ref.read(favoriteProvider.notifier).clearAll();
    // });
    Future.microtask(() async {
      try {
        final response = await ApiService.getFavoriteProducts();
        if (response != null && response['status'] == true) {
          final List<String> favoriteIds = (response['favorites'] as List)
              .map((item) => item['product_id']['_id'] as String)
              .toList();
          ref.read(favoriteProvider.notifier).syncWithServer(favoriteIds);
        }
      } catch (e) {
        debugPrint("Favorite sync failed in SearchScreen: $e");
      }
    });
  }

  Future<void> fetchProduct() async {
    try {
      final ApiService apiService = ApiService();
      final data = await apiService.getProductById(widget.productId);

      setState(() {
        productData = data;
        isLoading = false;
      });

      fetchRelatedProducts();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchRelatedProducts() async {
    if (productData == null) return;

    try {
      final ApiService apiService = ApiService();

      final String categoryId = productData!['category_id'] ?? "";
      final String subcategoryId = productData!['subcategory_id'] ?? "";

      if (categoryId.isEmpty) {
        setState(() => isLoadingRelated = false);
        return;
      }

      final data = await apiService.getRelatedProducts(
        categoryId,
        [subcategoryId],
        widget.productId,
      );

      if (data['status'] == true) {
        setState(() {
          relatedProducts = List<Map<String, dynamic>>.from(data['products']);
          isLoadingRelated = false;
        });
      } else {
        setState(() => isLoadingRelated = false);
      }
    } catch (e) {
      setState(() => isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || productData == null) {
      return Scaffold(body: Center(child: Text("Error: $errorMessage")));
    }

    final List<String> productImages = List<String>.from(productData?['product_images']);
    final String productName = productData?['product_name'] ?? "No Name";
    final double price = (productData?['price'] ?? 0).toDouble();
    final int availableQuantity = productData?['quantity'] ?? 0;
    final String descriptionHtml = productData?['product_description'] ?? "";
    final String brandName = productData?['brand_name'] ?? "";
    final String modelName = productData?['model_name'] ?? "";
    final String variantName = productData?['variant_name'] ?? "";
    final String unit=productData?['unit']?? "";

    final apiService = ApiService();
    final favs = ref.watch(favoriteProvider);

    // Yeh sirf main product ke liye hai (header wala favorite button)
    final bool isMainProductFav = favs.contains(widget.productId);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Container(
              decoration: BoxDecoration(
                color: AjugnuTheme.appColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextButton(
                  onPressed: () async {
                    try {
                      await apiService.addToCard(productData!['_id'], quantity);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyCartScreens()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error adding to cart: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/icons/add_to_cart.png", scale: 13, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text("Add to Cart",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      Text("₹ ${(price * quantity).toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Icon(Icons.arrow_forward,color: Colors.white,size: 26,)
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back)),
                      Text("Product Detail", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      // Text(productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      /*GestureDetector(
                        onTap: () async {
                          try {
                            if (isMainProductFav) {
                              // Remove karo (API call nahi hai to sirf local)
                              final res = await ApiService.addToFavorite(widget.productId);
                              ref.read(favoriteProvider.notifier).remove(widget.productId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Removed from favorites 💔")),
                              );
                            } else {
                              final res = await ApiService.addToFavorite(widget.productId);
                              ref.read(favoriteProvider.notifier).add(widget.productId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res['message'] ?? "Added to favorite ❤️"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Something went wrong"), backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: Icon(
                          isMainProductFav ? Icons.favorite : Icons.favorite_border,
                          color: isMainProductFav ? Colors.red : Colors.black,
                        ),
                      ),*/
                      InkWell(
                        onTap: () async {
                          final notifier = ref.read(favoriteProvider.notifier);
                          final productId =widget.productId;

                          // Optimistic UI update
                          if (notifier.isFav(productId)) {
                            notifier.remove(productId);
                           // Fluttertoast.showToast(msg: "Removing from favorites...");
                          } else {
                            notifier.add(productId);
                          //  Fluttertoast.showToast(msg: "Adding to favorites...");
                          }

                          try {
                            final response = await ApiService.toggleFavorite(productId);

                            if (response['status'] == true) {
                              // Success – already local mein update kar chuke ho, kuch nahi karna
                             // Fluttertoast.showToast(msg: response['message'] ?? "Favorite updated");
                            } else {
                              // Fail hua to rollback kar do
                              if (notifier.isFav(productId)) {
                                notifier.remove(productId);
                              } else {
                                notifier.add(productId);
                              }
                            //  Fluttertoast.showToast(msg: "Failed, try again");
                            }
                          } catch (e) {
                            // Error pe rollback
                            if (notifier.isFav(productId)) {
                              notifier.remove(productId);
                            } else {
                              notifier.add(productId);
                            }
                            Fluttertoast.showToast(msg: "Network error");
                          }
                        },
                        child: Icon(
                          ref.watch(favoriteProvider).contains(widget.productId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: ref.watch(favoriteProvider).contains(widget.productId)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),

              /*  InkWell(
                  onTap: () async {
                    final notifier = ref.read(favoriteProvider.notifier);
                    final productId = widget.productId  ;

                    // Optimistic UI update
                    if (notifier.isFav(productId)) {
                      notifier.remove(productId);
                      Fluttertoast.showToast(msg: "Removing from favorites...");
                    } else {
                      notifier.add(productId);
                      Fluttertoast.showToast(msg: "Adding to favorites...");
                    }

                    try {
                      final response = await ApiService.toggleFavorite(productId);

                      if (response['status'] == true) {
                        // Success – already local mein update kar chuke ho, kuch nahi karna
                        Fluttertoast.showToast(msg: response['message'] ?? "Favorite updated");
                      } else {
                        // Fail hua to rollback kar do
                        if (notifier.isFav(productId)) {
                          notifier.remove(productId);
                        } else {
                          notifier.add(productId);
                        }
                        Fluttertoast.showToast(msg: "Failed, try again");
                      }
                    } catch (e) {
                      // Error pe rollback
                      if (notifier.isFav(productId)) {
                        notifier.remove(productId);
                      } else {
                        notifier.add(productId);
                      }
                      Fluttertoast.showToast(msg: "Network error");
                    }
                  },
                  child: Icon(
                    ref.watch(favoriteProvider).contains(widget.productId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: ref.watch(favoriteProvider).contains(widget.productId)
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),*/

                const SizedBox(height: 20),

                // Carousel
                CarouselSlider(
                  options: CarouselOptions(
                    height: height * 0.3,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: false,
                    enableInfiniteScroll: productImages.length > 1,
                  ),
                  // items: productImages.map((imageUrl) {
                  //   String safeUrl = Uri.encodeFull(imageUrl);
                  //   return Builder(
                  //     builder: (context) => Container(
                  //       width: width,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(12),
                  //         image: DecorationImage(
                  //           image: NetworkImage(safeUrl),  // Yahan safeUrl use karo
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  // }).toList(),
                  items: productImages.map((imageUrl) {
                    String safeUrl = Uri.encodeFull(imageUrl);

                    return Builder(
                      builder: (context) => Container(
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Viewimages(ImageList: safeUrl,)));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              safeUrl,
                              // fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/about_us_logo.png",
                                  fit: BoxFit.contain,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: height * 0.016),

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: productImages.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: entry.key == 0 ? Colors.black : Colors.grey.withOpacity(0.4),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: height * 0.016),

                // Description Section
                Container(
                  decoration: BoxDecoration(color: AjugnuTheme.secondery.withOpacity(0.1)),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Description:", style: TextStyle(fontSize: 19)),
                            Container(
                              height: height * 0.033,
                              width: width * 0.27,
                              decoration: BoxDecoration(color: AjugnuTheme.appColor, borderRadius: BorderRadius.circular(15)),
                              child: Center(child: Text("₹ ${price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white))),
                            ),
                          ],
                        ),
                        SizedBox(height: height*0.02,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text("Brand",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w700)),
                                Text(brandName == "N/A" ? "No data" : brandName,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100)),
                              ],
                            ),
                            Column(
                              children: [
                                Text("Model",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w700)),
                                Text(modelName == "N/A" ? "No data" : modelName,style: TextStyle(fontSize: 12,)),
                              ],
                            ),
                            Column(
                              children: [
                                Text("Year",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w700)),
                                Text(variantName == "N/A" ? "No data" : variantName,style: TextStyle(fontSize: 12),),
                              ],

                            ),

                            Column(
                              children: [
                                Text("Unit",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w700)),
                                Text((unit == null || unit.isEmpty) ? "No data" : unit,style: TextStyle(fontSize: 12),),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Html(
                          data: descriptionHtml,
                          style: {"*": Style(fontSize: FontSize(16), color: Colors.black87)},
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Quantity: $availableQuantity available", style: const TextStyle(fontSize: 16)),
                            Container(
                              height: height * 0.033,
                              width: width * 0.27,
                              decoration: BoxDecoration(color: AjugnuTheme.appColor, borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => quantity > 1 ? quantity-- : null),
                                    child: const Text("-", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  ),
                                  Text("$quantity", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                    onTap: () {
                                      if (quantity < availableQuantity) {
                                        setState(() => quantity++);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can’t add more than available stock")));

                                      }
                                    },
                                    child: const Text("+", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Related Products
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Related Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                isLoadingRelated
                    ? const Center(child: CircularProgressIndicator())
                    : relatedProducts.isEmpty
                    ? const Padding(padding: EdgeInsets.only(left: 16.0, right: 12,top: 60), child: Center(child: Text("No related products found")))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 11,
                    crossAxisSpacing: 11,
                  ),
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = relatedProducts[index];
                    final String prodId = product['_id'] ?? "";
                    final String prodName = product['product_name'] ?? "No Name";
                    final String partNumber = product['part_number'] ?? "No part";
                    final String referenceNumer = product['reference_number'] ?? "No part";
                    final double prodPrice = (product['price'] ?? 0).toDouble();
                    final List<String> prodImages = List<String>.from(product['product_images'] ?? []);
                    final String subcategoryName = product['subcategory_name'] ?? "Subcategory";

                    // Har related product ke liye alag favorite status
                    final bool isThisFav = favs.contains(prodId);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(productId: prodId),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height*0.28,
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
                            bottom: MediaQuery.of(context).size.height*0.12,
                            child: Container(
                              height: 120,
                              width: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCE1FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Stack(
                                children: [
                                  const Positioned(
                                    top: 2,
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
                                  Positioned(
                                    top: 0,
                                    right: 6,
                                    child: /*InkWell(
                                      onTap: () async {
                                        try {
                                          if (isThisFav) {
                                            ref.read(favoriteProvider.notifier).remove(prodId);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Removed from favorite 💔")),
                                            );
                                          } else {
                                            final res = await ApiService.addToFavorite(prodId);
                                            ref.read(favoriteProvider.notifier).add(prodId);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(res['message'] ?? "Added to favorite ❤️"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Something went wrong"), backgroundColor: Colors.red),
                                          );
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          isThisFav ? Icons.favorite : Icons.favorite_border,
                                          color: isThisFav ? Colors.red : Colors.black,
                                          size: 18,
                                        ),
                                      ),
                                    )*/InkWell(
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
                                          //  Fluttertoast.showToast(msg: "Failed, try again");
                                          }
                                        } catch (e) {
                                          // Error pe rollback
                                          if (notifier.isFav(productId)) {
                                            notifier.remove(productId);
                                          } else {
                                            notifier.add(productId);
                                          }
                                        //  Fluttertoast.showToast(msg: "Network error");
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Center(
                                      child: prodImages.isEmpty
                                          ? Image.asset("assets/images/about_us_logo.png", height: 50)
                                          : /*CachedNetworkImage(
                                        imageUrl: prodImages[0],
                                        height: 60,
                                        placeholder: (_, __) => Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white, height: 60, width: 60),
                                        ),
                                        errorWidget: (_, __, ___) => Image.asset("assets/images/about_us_logo.png", height: 60),
                                      ),*/
                                      CachedNetworkImage(
                                        imageUrl: Uri.encodeFull(prodImages[0]),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        ),
                                        errorWidget: (context, url, error) => Image.asset("assets/images/about_us_logo.png",height: 65),  // Fallback image
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: MediaQuery.of(context).size.height*0.03,
                            child: SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(

                                    children: [
                                      Text("Part Nub:   ", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                      Text(partNumber, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                    ],
                                  ), Row(

                                    children: [
                                      Text("Reference Nub: ", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                      Expanded(child: Text(referenceNumer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                                    ],
                                  ),

                                  // Text(prodName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  //     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  Text(
                                    prodName.isNotEmpty
                                        ? prodName[0].toUpperCase() + prodName.substring(1)
                                        : '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(subcategoryName,
                                            style: const TextStyle(fontSize: 10, color: Colors.black54), maxLines: 1),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xFF2F3FD4), borderRadius: BorderRadius.circular(10)),
                                        child: Text("₹ ${prodPrice.toStringAsFixed(2)}",
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
                  },
                ),
                const SizedBox(height: 100), // FAB ke liye space
              ],
            ),
          ),
        ),
      ),
    );
  }
}