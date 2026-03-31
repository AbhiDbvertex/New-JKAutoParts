import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../main.dart';
import 'AjugnuFlushbar.dart';
import 'backend/ajugnu_auth.dart';
import 'backend/api_handler.dart';
import 'common_widgets.dart';
import 'form_validator.dart';

class LocationSelectorScreen extends StatefulWidget {
  final Function()? onLocationChanged;
  final bool forceToSelect;

  const LocationSelectorScreen({super.key, this.onLocationChanged, this.forceToSelect = false});

  @override
  State<StatefulWidget> createState() {
    return LocationSelectorState();
  }

}

 class LocationSelectorState extends State<LocationSelectorScreen> {
   GoogleMapController? mapController;
   Marker? currentLocation;
   Marker? myLocation = const Marker(markerId: MarkerId('myLocation'));
   String? postalCode;
   MapType mapType = MapType.normal;

   var searchController = TextEditingController();

   @override
  void initState() {
    super.initState();
    adebug(widget.forceToSelect);

    Future.delayed(const Duration(milliseconds: 10), () => configureMap());
  }

  @override
  void dispose() {
     mapController?.dispose();
     searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent
      ),
      child: Scaffold(
        body: PopScope(
          canPop: !widget.forceToSelect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                onMapCreated: (mapController) {
                  this.mapController = mapController;
                },
                onTap: (latlong) async {
                  postalCode = null;
                  List<Placemark> placemarks = [];
                  try {
                    setState(() {
                      currentLocation = Marker(
                        markerId: MarkerId('ishwar${latlong.hashCode}'),
                        position: latlong,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                      );
                    });
                    placemarks.addAll(await placemarkFromCoordinates(latlong.latitude, latlong.longitude));
                    postalCode = placemarks.firstOrNull?.postalCode;
                    if (postalCode != null) {
                      setState(() {
                        currentLocation = Marker(
                          markerId: MarkerId('ishwar${latlong.hashCode}'),
                          position: latlong,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                          infoWindow: InfoWindow(
                            title: placemarks.firstOrNull?.locality??'Unknown',
                            snippet: placemarks.firstOrNull?.administrativeArea??'Unknown',
                          ),
                        );
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        if (currentLocation != null) {
                          mapController?.showMarkerInfoWindow(currentLocation!.markerId);
                        }
                      });
                    } else {
                      AjugnuFlushbar.showError(context, 'Marked area is not supported by our services yet, please select another.');
                    }
                  } catch (e) {
                    AjugnuFlushbar.showError(context, 'Location services are not working properly.');
                  }
                },
                mapType: mapType,
                markers: currentLocation != null && myLocation != null ? {currentLocation!, myLocation!} : currentLocation != null ? {currentLocation!} : myLocation != null ? {myLocation!} : {},
                initialCameraPosition: const CameraPosition(
                  target: LatLng(12.2958, 76.6394), // lat and long of Mysore
                  zoom: 11.0,
                  tilt: 30
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Visibility(
                            visible: !widget.forceToSelect,
                            child: IconButton(
                              onPressed: () {
                                ajugnuGlobalContext.currentState?.pop();
                              },
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                          ),
                          Expanded(
                            child: SearchField(
                              controller: searchController,
                              onChanged: (val) {
                                // Handle search input change if needed
                              }, onSearchRequest: searchLocation,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 12),
                      IconButton(
                          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
                          onPressed: () {
                            configureMap();
                          },
                          icon: const Icon(Icons.location_searching, color: Colors.white)
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
                          onPressed: () {
                            setState(() {
                              mapType = mapType == MapType.normal ? MapType.hybrid : MapType.normal;
                            });
                          },
                          icon: const Icon(Icons.map, color: Colors.white)
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(postalCode == null ? Colors.green.shade200 : Colors.green)),
                          onPressed: () {
                            if (postalCode != null) {
                              CommonWidgets.showProgress();
                              AjugnuAuth().updateUserPinCode(postalCode!).then((response) {
                                CommonWidgets.removeProgress();

                                if (widget.forceToSelect) {
                                  AjugnuNavigations.customerHomeScreen(type: AjugnuNavigations.typeRemoveAllAndPush);
                                } else {
                                  Navigator.of(context).pop();
                                  if (widget.onLocationChanged != null) {
                                    widget.onLocationChanged!();
                                  }
                                }
                                AjugnuFlushbar.showSuccess(context, 'Location updated successfully.');
                              }, onError: (error) {
                                CommonWidgets.removeProgress();
                                AjugnuFlushbar.showError(context, 'Something went wrong while updating your location');
                              });
                            }
                          },
                          icon: const Icon(Icons.check_sharp, color: Colors.white)
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> searchLocation() async {
     String term = searchController.text.trim();
     if (term.isNotEmpty) {
       FocusManager.instance.primaryFocus?.unfocus();

       CommonWidgets.showProgress();
       try {
         Location locations = (await locationFromAddress(term)).first;

         List<Placemark> placemarks = [];
         var latlong = LatLng(locations.latitude, locations.longitude);
         setState(() {
           currentLocation = Marker(
               markerId: MarkerId('ishwar${latlong.hashCode}'),
               position: latlong,
               icon: BitmapDescriptor.defaultMarkerWithHue(
                   BitmapDescriptor.hueGreen)
           );
         });
         placemarks.addAll(await placemarkFromCoordinates(latlong.latitude, latlong.longitude));
         postalCode = placemarks.firstOrNull?.postalCode;
         if (postalCode != null) {
           setState(() {
             currentLocation = Marker(
               markerId: MarkerId('ishwar${latlong.hashCode}'),
               position: latlong,
               icon: BitmapDescriptor.defaultMarkerWithHue(
                   BitmapDescriptor.hueGreen),
               infoWindow: InfoWindow(
                 title: placemarks.firstOrNull?.locality ?? 'Unknown',
                 snippet: placemarks.firstOrNull?.administrativeArea ??
                     'Unknown',
               ),
             );
           });
           mapController?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
               target: LatLng(locations.latitude, locations.longitude),
               zoom: 15
           )));
           Future.delayed(const Duration(seconds: 1), () {
             if (currentLocation != null) {
               mapController?.showMarkerInfoWindow(currentLocation!.markerId);
             }
           });
         }
         CommonWidgets.removeProgress();
       } catch (error) {
         CommonWidgets.removeProgress();
         AjugnuFlushbar.showError(getAjungnuGlobalContext(), error.toString());
       }
     }
  }

   Future<void> configureMap() async {
     if (await Geolocator.isLocationServiceEnabled()) {
       CommonWidgets.showProgress();
       LocationPermission permission = await Geolocator.checkPermission();
       if (permission == LocationPermission.denied) {
         permission = await Geolocator.requestPermission();
         if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
           showDialog<void>(
             context: getAjungnuGlobalContext(),
             barrierDismissible: false, // user must tap button to dismiss
             builder: (BuildContext context) {
               return AlertDialog(
                 title: const Text('Location Permissions'),
                 content: Text('Location permissions are${permission == LocationPermission.deniedForever ? ' permanently' : ''} denied, we can not locate you in map. If you do not want to share your location you can manually select your location from map.'),
                 actions: <Widget>[
                   TextButton(
                     child: const Text('Dismiss'),
                     onPressed: () {
                       Navigator.of(context).pop();
                     },
                   )
                 ],
               );
             },
           );
           CommonWidgets.removeProgress();
           return;
         }
       }

       var location = await Geolocator.getCurrentPosition();
       setState(() {
         myLocation = Marker(markerId: const MarkerId("myLocation"), position: LatLng(location.latitude, location.longitude), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));
       });

       mapController?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
         target: LatLng(location.latitude, location.longitude),
         zoom: 9
       )));

       List<Placemark> placemarks = [];
       try {
         var latlong = LatLng(location.latitude, location.longitude);
         setState(() {
           currentLocation = Marker(
               markerId: MarkerId('ishwar${latlong.hashCode}'),
               position: latlong,
               icon: BitmapDescriptor.defaultMarkerWithHue(
                   BitmapDescriptor.hueGreen)
           );
         });
         placemarks.addAll(await placemarkFromCoordinates(latlong.latitude, latlong.longitude));
         postalCode = placemarks.firstOrNull?.postalCode;
         if (postalCode != null) {
           setState(() {
             currentLocation = Marker(
               markerId: MarkerId('ishwar${latlong.hashCode}'),
               position: latlong,
               icon: BitmapDescriptor.defaultMarkerWithHue(
                   BitmapDescriptor.hueGreen),
               infoWindow: InfoWindow(
                 title: placemarks.firstOrNull?.locality ?? 'Unknown',
                 snippet: placemarks.firstOrNull?.administrativeArea ??
                     'Unknown',
               ),
             );
           });
           Future.delayed(const Duration(seconds: 1), () {
             if (currentLocation != null) {
               mapController?.showMarkerInfoWindow(currentLocation!.markerId);
             }
           });
         }
       } catch (e) {
          // error
       }
       CommonWidgets.removeProgress();
     } else {
       showDialog<void>(
         context: getAjungnuGlobalContext(),
         barrierDismissible: false, // user must tap button to dismiss
         builder: (BuildContext context) {
           return AlertDialog(
             title: const Text('Enable Location Services'),
             content: const Text('We can not locate you in map, please enable your device location and reopen this page. If you do not want to share your location you can manually select your location from map.'),
             actions: <Widget>[
               TextButton(
                 child: const Text('Dismiss'),
                 onPressed: () {
                   Navigator.of(context).pop();
                 },
               )
             ],
           );
         },
       );
     }
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
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontFamily: 'Poly',
        ),
        onChanged: widget.onChanged,
        onEditingComplete: widget.onSearchRequest,
        keyboardType: TextInputType.text,
        maxLines: 1,
        maxLength: FormValidators.maxNameChunkLength,
        textInputAction: TextInputAction.search,
        textAlign: TextAlign.start,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          hintText: 'Search your location',
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
