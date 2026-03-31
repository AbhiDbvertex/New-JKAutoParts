import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jkautomed/JKAutoMed/screens/product_list_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../../ajugnu_constants.dart';
import '../providers/category_provider.dart';
import '../widgets/My_Button.dart';
import '../widgets/custom_AppBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
class SubCategoryScreen extends ConsumerStatefulWidget {
  final String initialCategoryId;
  final String initialCategoryName;

  const SubCategoryScreen(this.initialCategoryId, this.initialCategoryName, {Key? key})
      : super(key: key);

  @override
  ConsumerState<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends ConsumerState<SubCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial selected category set करो
      ref.read(selectedCategoryIdProvider.notifier).state = widget.initialCategoryId;
      // Subcategory selection clear करो (fresh start)
      ref.read(selectedSubcategoryIdsProvider.notifier).state = {};

      // Screen खुलते ही latest data API से fetch करो
      ref.refresh(categoriesProvider);
    });
  }

  // Pull to refresh function
  Future<void> _onRefresh() async {
    await ref.refresh(categoriesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final selectedSubIds = ref.watch(selectedSubcategoryIdsProvider);

    return Scaffold(
      appBar: JKCustomAppbar(
        title: "Sub Categories",
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: JKCustomButton(
          text: "Submit",
          backgroundColor: AjugnuTheme.appColor,
          onPressed: () {
            if (selectedSubIds.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select at least one subcategory!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
              return;
            }

            print("Selected Subcategory IDs: ${selectedSubIds.toList()}");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductListScreen("hideKey"),
              ),
            );
          },
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AjugnuTheme.appColor,
        backgroundColor: Colors.white,
        child: categoriesAsync.when(
          loading: () => _buildShimmerLoading(height),
          error: (err, stack) => Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      "Error: $err",
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => ref.refresh(categoriesProvider),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return const Center(child: Text("No categories found"));
            }

            final selectedCategory = categories.firstWhere(
                  (cat) => cat.id == selectedCategoryId,
              orElse: () => categories[0],
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // छोटे content पर भी pull work करे
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("All Categories", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    color: AjugnuTheme.secondery,
                    height: height * 0.12,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat.id == selectedCategoryId;

                        return Padding(
                          padding: const EdgeInsets.all(3),
                          child: InkWell(
                            onTap: () {
                              ref.read(selectedCategoryIdProvider.notifier).state = cat.id;
                              // Category बदलने पर subcategory selection clear (optional)
                              ref.read(selectedSubcategoryIdsProvider.notifier).state = {};
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(004),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AjugnuTheme.appColor : Colors.grey.shade300,
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      height: MediaQuery.of(context).size.width * 0.13,
                                      width: MediaQuery.of(context).size.width * 0.13,
                                      imageUrl: cat.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Text(
                                //   cat.name,
                                //   style: TextStyle(
                                //     fontSize: 11,
                                //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                //     color: isSelected ? AjugnuTheme.appColor : Colors.black,
                                //   ),
                                // ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.18, // sabke liye same width
                                  height: 16,
                                  child: cat.name.toString().length > 6
                                      ? Marquee(
                                    text: cat.name,
                                    style: TextStyle(fontSize: 11),
                                    blankSpace: 20,
                                    velocity: 25,
                                    pauseAfterRound: Duration(seconds: 1),
                                  )
                                      : Center(
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(fontSize: 11),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Sub Categories",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  selectedCategory.subcategories.isEmpty
                      ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: height * 0.28),
                      child: Column(
                        children: [
                          Icon(Icons.category,size: 30,color: Colors.grey,),
                          const Text(
                            "No subcategories available",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                      : GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: height * 0.015,
                    crossAxisSpacing: height * 0.01,
                    children: selectedCategory.subcategories.map((sub) {
                      final isSelected = selectedSubIds.contains(sub.id);
                      return InkWell(
                        onTap: () {
                          final notifier = ref.read(selectedSubcategoryIdsProvider.notifier);
                          if (isSelected) {
                            notifier.state = {...notifier.state}..remove(sub.id);
                          } else {
                            notifier.state = {...notifier.state}..add(sub.id);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected ? AjugnuTheme.appColor.withOpacity(0.2) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AjugnuTheme.appColor : Colors.grey,
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                              ),
                              child: CachedNetworkImage(
                                height: MediaQuery.of(context).size.width * 0.12,
                                width: MediaQuery.of(context).size.width * 0.12,
                                imageUrl: sub.imageUrl ?? '',
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
                              ),
                            ),*/
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AjugnuTheme.appColor.withOpacity(0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AjugnuTheme.appColor : Colors.grey,
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  height: MediaQuery.of(context).size.width * 0.12,
                                  width: MediaQuery.of(context).size.width * 0.12,
                                  imageUrl: sub.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),
                            // Text(
                            //   sub.name,
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     fontSize: 11,
                            //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            //     color: isSelected ? AjugnuTheme.appColor : Colors.black,
                            //   ),
                            // ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.18, // sabke liye same width
                              height: 16,
                              child: sub.name.toString().length > 6
                                  ? Marquee(
                                text: sub.name,
                                style: TextStyle(fontSize: 11),
                                blankSpace: 20,
                                velocity: 25,
                                pauseAfterRound: Duration(seconds: 1),
                              )
                                  : Center(
                                child: Text(
                                  sub.name,
                                  style: TextStyle(fontSize: 11),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(double height) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 160, height: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: AjugnuTheme.secondery,
            height: height * 0.1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(width: 60, height: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 200, height: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: height * 0.015,
            crossAxisSpacing: height * 0.01,
            children: List.generate(12, (_) => _buildShimmerGridItem()),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGridItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Container(width: 28, height: 28, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(width: 60, height: 12, color: Colors.white),
        ),
      ],
    );
  }
}