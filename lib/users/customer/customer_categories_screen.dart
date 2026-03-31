import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/users/customer/product_change_listeners.dart';
import '../../JKAutoMed/screens/notification_screen.dart';
import '../../JKAutoMed/screens/recent_product_screen.dart';
import '../../JKAutoMed/screens/search_product_screen.dart';
import '../../JKAutoMed/screens/sub_category_screen.dart';
import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_product.dart';
import '../common/AjugnuFlushbar.dart';
import '../common/backend/api_handler.dart';
import '../common/backend/category_repository.dart';
import '../common/common_widgets.dart';
import 'backend/customer_product_repository.dart';
import 'package:marquee/marquee.dart';
class CustomerCategoriesScreen extends StatefulWidget {

  const CustomerCategoriesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomerCategoriesState();
  }
}

class CustomerCategoriesState extends State<CustomerCategoriesScreen> {
  List<Map<String, String>>? allCategories;
  List<AjugnuProduct>? popularProducts;

  int notificationCounts = 0;

  void onLocationChanged() {
    CustomerProductRepository().popularProducts = null;
    fetchPopularProducts();
  }

  void onProductChange(AjugnuProduct product, bool completeProduct) {
    int index = popularProducts?.indexWhere((prod) => prod.id == product.id) ?? -1;
    if (index > -1) {
      if (completeProduct) {
        setState(() {
          popularProducts?[index] = product;
        });
      } else {
        fetchPopularProducts();
      }
    }
  }

  @override
  void dispose() {
    ProductChangeListeners.removeAllListeners();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Always fetch fresh categories from API
    Future.delayed(const Duration(milliseconds: 10), () {
      CategoryRepository().getCategories().then((categories) {
        setState(() {
          allCategories = CategoryRepository().allCategories;
        });
      }, onError: (error) {
        AjugnuFlushbar.showError(context, error);
        setState(() {
          allCategories = [];
        });
      });
    });

    // Always fetch fresh popular products
    Future.delayed(const Duration(milliseconds: 10), () => fetchPopularProducts());
    // Future.microtask(() {
    //   ref.read(favoriteProvider.notifier).clearAll();
    // });
  }

  void fetchPopularProducts() {
    // Always fetch fresh, no local check or loading count limit
    ProductChangeListeners.clearChanges();
    popularProducts = null;
    CustomerProductRepository().getPopularProducts().then((popularProducts) {
      adebug('popular products : ${popularProducts.totalPages}');
      setState(() {
        this.popularProducts = popularProducts.data;
        notificationCounts = popularProducts.notificationCounts;
        ProductChangeListeners.addListener(onProductChange);
      });
    }, onError: (error) {
      setState(() {
        this.popularProducts = [];
      });
      if (!error.toString().toLowerCase().contains('no') && !error.toString().toLowerCase().contains('popular')) {
        AjugnuFlushbar.showError(context, error.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.red
      ),
      child: Scaffold(
        // backgroundColor: AjugnuTheme.appColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              Container(
                child: SliverAppBar(
                  automaticallyImplyLeading: false,
                  forceMaterialTransparency: true,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            // color: AjugnuTheme.secondery,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              color: AjugnuTheme.secondery,
                              child: InkWell(
                                onTap: () {
                                  // AjugnuNavigations.customerSearchScreen();
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Image.asset('assets/icons/icon_search.png', height: 18, width: 18, color: Colors.black54),
                                      const SizedBox(width: 11),
                                      CommonWidgets.text('Search product here..', textColor: Colors.black54),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(right: 16),
                              // color: const Color.fromARGB(255, 231, 231, 231),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AjugnuTheme.secondery,
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: InkWell(
                                  // onTap: () => AjugnuNavigations.customerNotificationsScreen(onNotificationRead: () => setState(() {notificationCounts = 0;})),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationScreen()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Image.asset("assets/icons/icon_notification.png", height: 19, width: 19),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: notificationCounts > 0,
                              child: Positioned(
                                left: 34,
                                top: 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(1000),
                                  ),
                                  height: 6,
                                  width: 6,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  pinned: false,
                  floating: true,
                  titleSpacing: 0,
                  expandedHeight: MediaQuery.of(context).size.width * 0.68,
                  // backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                            // image: AssetImage('assets/images/customer_home_image.jpg'),
                            image: AssetImage('assets/images/homeimage.png'),
                            fit: BoxFit.cover,
                          )
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07).copyWith(top: MediaQuery.of(context).size.width * 0.15),
                          child: CommonWidgets.text(
                              "Buy Your Favorite Parts,\nOnly Here!",
                              textColor: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.06
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ];
          },
          body: RefreshIndicator(  // Added Pull-to-Refresh for manual refresh
            onRefresh: () async {
              fetchPopularProducts();
              // Also refetch categories if needed
              CategoryRepository().getCategories().then((categories) {
                setState(() {
                  allCategories = CategoryRepository().allCategories;
                });
              });
            },
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),  // For RefreshIndicator to work
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonWidgets.text('Category', fontSize: 17),
                          InkWell(
                            onTap: () {
                              if (allCategories != null && allCategories!.isNotEmpty) {
                                final firstCategory = allCategories![0];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubCategoryScreen(
                                      firstCategory['_id'] ?? '',
                                      firstCategory['name'] ?? 'Unknown',
                                      // firstCategory['image'] ?? '',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      decoration: BoxDecoration(
                        color: AjugnuTheme.secondery,
                        // border: Border.all(
                        //   color: Colors.green, // jo color chahiye
                        //   width: 2,
                        // ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.27,
                        child: allCategories != null
                            ? ListView(
                          scrollDirection: Axis.horizontal,
                          children: allCategories!.map<Widget>((map) => Padding(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
                            child: InkWell(
                              onTap: () {
                                print("category image ${map['image']}");
                                // AjugnuNavigations.customerCategoryProductScreen(
                                //   categoryName: map['name'] ?? "Unknown",
                                //   categoryID: map['_id'] ?? '',
                                // );
                                // SubCategoryScreen(map['_id'] ?? '',map['name'] ?? "Unknown");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubCategoryScreen(
                                      map['_id'] ?? '',
                                      map['name'] ?? 'Unknown',
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width * 0.005),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        // shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(7)
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        height: MediaQuery.of(context).size.width * 0.12,
                                        width: MediaQuery.of(context).size.width * 0.16,
                                        imageUrl: map['image'] ?? '',
                                        fit: BoxFit.cover,
                                        // color: Colors.red,
                                        errorWidget: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // CommonWidgets.text(map['name']!, fontFamily: 'Poly'),
                                  // Text("${map['name']!}",style: TextStyle(fontSize: 11),)
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.18, // sabke liye same width
                                    height: 16,
                                    child: map['name'].toString().length > 6
                                        ? Marquee(
                                      text: map['name'] ?? "",
                                      style: TextStyle(fontSize: 11),
                                      blankSpace: 20,
                                      velocity: 25,
                                      pauseAfterRound: Duration(seconds: 1),
                                    )
                                        : Center(
                                      child: Text(
                                        map['name']!,
                                        style: TextStyle(fontSize: 11),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          )).toList(),
                        )
                            : const SizedBox(),
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
                    //   child: CommonWidgets.text('Recent Product', fontSize: 17),
                    // ),
                    // const RecentProductsSection(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
                      child: CommonWidgets.text('Recent Products', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const RecentProductsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}