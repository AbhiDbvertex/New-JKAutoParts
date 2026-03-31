import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Modelss/address_model.dart';
import '../Services/Api_Service.dart';

final addressApiProvider = Provider<ApiService>((ref) => ApiService());

// States Provider
final statesProvider = FutureProvider<List<StateModel>>((ref) async {
  return ref.read(addressApiProvider).getStates();
});

// Selected State Provider
final selectedStateProvider = StateProvider<String?>((ref) => null);

// Cities Provider - depends on selected state
final citiesProvider = FutureProvider<List<CityModel>>((ref) async {
  final selectedState = ref.watch(selectedStateProvider);
  if (selectedState == null) return [];
  return ref.read(addressApiProvider).getCities(selectedState);
});