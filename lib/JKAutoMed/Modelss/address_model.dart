// // models/address_model.dart
// class StateModel {
//   final String name;
//   final String stateCode;
//
//   StateModel({
//     required this.name,
//     required this.stateCode,
//   });
//
//   factory StateModel.fromJson(Map<String, dynamic> json) {
//     return StateModel(
//       name: json['name'] as String,
//       stateCode: json['state_code'] as String,
//     );
//   }
//
//   @override
//   String toString() => name;
// }
//
// class CityModel {
//   final String name;
//
//   CityModel({required this.name});
//
//   factory CityModel.fromJson(String cityName) {
//     return CityModel(name: cityName);
//   }
//
//   @override
//   String toString() => name;
// }

// models/address_model.dart

class StateModel {
  final String name;
  final String stateCode; // Optional, baad mein use kar sakte ho

  StateModel({
    required this.name,
    required this.stateCode,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      name: json['name'] as String,
      stateCode: json['state_code'] as String,
    );
  }

  @override
  String toString() => name; // Dropdown mein name dikhega
}

class CityModel {
  final String name;

  CityModel({required this.name});

  // Cities API direct string bhejti hai
  factory CityModel.fromJson(String cityName) {
    return CityModel(name: cityName);
  }

  @override
  String toString() => name;
}