// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shimmer/shimmer.dart';
// import '../providers/address_provider.dart';
//
// class AddNewAddressScreen extends ConsumerWidget {
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController buildingController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//
//   AddNewAddressScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final statesAsync = ref.watch(statesProvider);
//     final selectedState = ref.watch(selectedStateProvider);
//     final citiesAsync = ref.watch(citiesProvider);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Add New Address",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("Select State", style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//
//               // States Dropdown with Shimmer
//               statesAsync.when(
//                 loading: () => _buildShimmerDropdown(),
//                 error: (_, __) => _buildErrorDropdown("Error loading states"),
//                 data: (states) {
//                   if (states.isEmpty) {
//                     return _buildErrorDropdown("No states available");
//                   }
//                   return DropdownButtonFormField<String>(
//                     value: selectedState,
//                     hint: const Text("Select State"),
//                     isExpanded: true,
//                     decoration: _dropdownDecoration(),
//                     items: states.map((state) {
//                       return DropdownMenuItem(
//                         value: state.name,
//                         child: Text(state.name),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       ref.read(selectedStateProvider.notifier).state = value;
//                     },
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               // City Field - Only show when state is selected
//               if (selectedState != null) ...[
//                 const Text("Select City", style: TextStyle(fontSize: 16)),
//                 const SizedBox(height: 8),
//
//                 citiesAsync.when(
//                   loading: () => _buildShimmerDropdown(),
//                   error: (_, __) => _buildErrorDropdown("Error loading cities"),
//                   data: (cities) {
//                     if (cities.isEmpty) {
//                       return _buildErrorDropdown("No cities found for this state");
//                     }
//                     return DropdownButtonFormField<String>(
//                       hint: const Text("Select City"),
//                       isExpanded: true,
//                       decoration: _dropdownDecoration(),
//                       items: cities.map((city) {
//                         return DropdownMenuItem(
//                           value: city.name,
//                           child: Text(city.name),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         // Yahan selected city save kar sakte ho agar chahiye
//                         // ref.read(selectedCityProvider.notifier).state = value;
//                       },
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//               ],
//
//               // Address Field
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    Text("Enter Address", style: TextStyle(fontSize: 16)),
//                    Row(
//                      children: [
//                        Image.asset("assets/icons/locationIcon.png",color: Colors.black,height: 22,),
//                        Text("Find me")
//                      ],
//                    )
//                  ],
//                ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: addressController,
//                 maxLines: 1,
//                 decoration: InputDecoration(
//                   hintText: "Address",
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.my_location,color: Colors.transparent,),
//                     onPressed: () {
//                       // Current location fetch logic baad mein
//                     },
//                   ),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Building Name/Number
//               const Text("Building Name/Number", style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: buildingController,
//                 decoration: InputDecoration(
//                   hintText: "Optional",
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Address Description
//               const Text("Add Address Description", style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(
//                   hintText: "Optional",
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Add Address Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Validation + Save logic yahan
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Address Saved Successfully!")),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.indigo,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     "Add Address",
//                     style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Reusable Dropdown Decoration
//   InputDecoration _dropdownDecoration() {
//     return InputDecoration(
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//     );
//   }
//
//   // Shimmer Loading Dropdown
//   Widget _buildShimmerDropdown() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         height: 56,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//       ),
//     );
//   }
//
//   // Error Dropdown
//   Widget _buildErrorDropdown(String message) {
//     return DropdownButtonFormField<String>(
//       hint: Text(message, style: const TextStyle(color: Colors.red)),
//       isExpanded: true,
//       decoration: _dropdownDecoration().copyWith(
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//       ),
//       items: const [],
//       onChanged: null,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/address_provider.dart';
import '../Services/Api_Service.dart';

class AddNewAddressScreen extends ConsumerStatefulWidget {
  // final String userId;

  const AddNewAddressScreen({super.key,});

  @override
  ConsumerState<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends ConsumerState<AddNewAddressScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  String? selectedCity;
  bool isLoadingLocation = false;

  // Current location fetch
  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      setState(() => isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        setState(() => isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permissions are permanently denied")),
      );
      setState(() => isLoadingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      String fullAddress = "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";

      setState(() {
        addressController.text = fullAddress.trim();
        pincodeController.text = place.postalCode ?? "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location fetched successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching address: $e")),
      );
    }

    setState(() => isLoadingLocation = false);
  }

  // Save address to API
  Future<void> _saveAddress() async {
    final selectedState = ref.read(selectedStateProvider);

    if (selectedState == null || selectedCity == null || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final body = {
      "state": selectedState,
      "city": selectedCity,
      "pincode": int.tryParse(pincodeController.text) ?? 0,
      "building_name": buildingController.text.trim(),
      "address_line": addressController.text.trim(),
      "address_description": descriptionController.text.trim(),
    };

    try {
      final apiService = ref.read(addressApiProvider);
      final success = await apiService.updateUserAddress(body);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Address saved successfully!",),
             backgroundColor: Colors.green,
           ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save address"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yahan sirf context aata hai, ref already available hai
    final statesAsync = ref.watch(statesProvider);
    final selectedState = ref.watch(selectedStateProvider);
    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Address",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select State", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              statesAsync.when(
                loading: () => _buildShimmerDropdown(),
                error: (_, __) => _buildErrorDropdown("Error loading states"),
                data: (states) {
                  if (states.isEmpty) return _buildErrorDropdown("No states available");
                  return DropdownButtonFormField<String>(
                    value: selectedState,
                    hint: const Text("Select State"),
                    isExpanded: true,
                    decoration: _dropdownDecoration(),
                    items: states.map((state) => DropdownMenuItem(value: state.name, child: Text(state.name))).toList(),
                    onChanged: (value) {
                      ref.read(selectedStateProvider.notifier).state = value;
                      setState(() => selectedCity = null);
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              if (selectedState != null) ...[
                const Text("Select City", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                citiesAsync.when(
                  loading: () => _buildShimmerDropdown(),
                  error: (_, __) => _buildErrorDropdown("Error loading cities"),
                  data: (cities) {
                    if (cities.isEmpty) return _buildErrorDropdown("No cities found");
                    return DropdownButtonFormField<String>(
                      value: selectedCity,
                      hint: const Text("Select City"),
                      isExpanded: true,
                      decoration: _dropdownDecoration(),
                      items: cities.map((city) => DropdownMenuItem(value: city.name, child: Text(city.name))).toList(),
                      onChanged: (value) => setState(() => selectedCity = value),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              const Text("Pincode", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Pincode",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Enter Address", style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: isLoadingLocation ? null : _getCurrentLocation,
                    child: Row(
                      children: [
                        isLoadingLocation
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Image.asset("assets/icons/locationIcon.png", color: Colors.black, height: 22),
                        const SizedBox(width: 6),
                        Text(isLoadingLocation ? "Finding..." : "Find me", style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Address",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Building Name/Number", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: buildingController,
                decoration: InputDecoration(
                  hintText: "Optional",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Add Address Description", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Optional",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Add Address",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _buildShimmerDropdown() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildErrorDropdown(String message) {
    return DropdownButtonFormField<String>(
      hint: Text(message, style: const TextStyle(color: Colors.red)),
      isExpanded: true,
      decoration: _dropdownDecoration().copyWith(
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      items: const [],
      onChanged: null,
    );
  }
}