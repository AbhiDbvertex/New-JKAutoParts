 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import '../../ajugnu_constants.dart';
import '../../main.dart';
 import '../../models/ajugnu_product.dart';
import '../common/backend/api_handler.dart';
import '../common/common_widgets.dart';
import '../common/form_validator.dart';
import '../common/products_grid_list.dart';
import 'backend/customer_product_repository.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomerSearchState();
  }
}

class CustomerSearchState extends State<CustomerSearchScreen> {
  final searchController = TextEditingController();
  bool isSearching = false;
  String errorMessage = 'Enter product name to search';

  final searchResults = <AjugnuProduct>[];

  void onSearchRequest() {
    if (!isSearching && searchController.text.trim().isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      isSearching = true;
      errorMessage = '';
      setState(() {
        searchResults.clear();
      });
      CustomerProductRepository().searchProducts(searchController.text.trim()).then((results) {
        isSearching = false;
        if (results.isNotEmpty) {
          errorMessage = 'Enter product name to search';
          setState(() {
            searchResults.addAll(results);
          });
        } else {
          setState(() {
            errorMessage = "No Search Results";
          });
        }
      }, onError: (error) {
        isSearching = false;
        setState(() {
          errorMessage = error;
        });
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: AjugnuTheme.appColorScheme.onPrimary,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    ajugnuGlobalContext.currentState?.pop();
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
                Expanded(
                  child: SearchField(
                    controller: searchController,
                    onChanged: (val) {
                      // Handle search input change if needed
                    }, onSearchRequest: onSearchRequest,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: isSearching ? ProductsGridList(
              enableShimmer: true,
              products: [
                AjugnuProduct.dummy(),
                AjugnuProduct.dummy(),
                AjugnuProduct.dummy(),
                AjugnuProduct.dummy(),
              ],
            ) : searchResults.isEmpty ? Center(
              child:  Card(
                elevation: 0,
                color: AjugnuTheme.appColorScheme.surface,
                margin: EdgeInsets.symmetric(horizontal: 18),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        errorMessage == 'Enter product name to search' ? 'assets/icons/search_hint_icon.png' : 'assets/icons/no_results.png',
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.3,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CommonWidgets.text(errorMessage, alignment: TextAlign.center, textColor: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            ) : SingleChildScrollView(
              child: ProductsGridList(
                products: searchResults,
              ) // CommonWidgets.createProductsGrid(context, searchResults)
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function() onSearchRequest;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSearchRequest,
  });

  @override
  State<StatefulWidget> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool showClearButton = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      showClearButton = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: widget.controller,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontFamily: 'Poly',
        ),
        onChanged: widget.onChanged,
        onEditingComplete: widget.onSearchRequest,
        keyboardType: TextInputType.text,
        maxLines: 1,
        textInputAction: TextInputAction.search,
        textAlign: TextAlign.start,
        textCapitalization: TextCapitalization.words,
        maxLength: FormValidators.maxNameChunkLength,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          hintText: 'Search product here',
          counterText: '',
          hintStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            fontFamily: 'Poly',
          ),
          fillColor: const Color.fromARGB(255, 231, 231, 231),
          filled: true,
          prefixIcon: const Icon(Icons.search_rounded, color: AjugnuTheme.appColor),
          suffixIcon: showClearButton
              ? IconButton(
            icon: const Icon(Icons.clear, color: AjugnuTheme.appColor),
            onPressed: () {
              widget.controller.clear();
            },
          ) : null,
          focusedBorder: border,
          enabledBorder: border,
          disabledBorder: border,
          border: border,
        ),
      ),
    );
  }
}
