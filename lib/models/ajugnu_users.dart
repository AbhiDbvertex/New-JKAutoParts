// import '../users/common/backend/api_handler.dart';
//
// class AjugnuUser {
//   final int otpVerified;
//   final String? firebaseToken;
//   final List<String?>? pinCode;
//   final String? id;
//   final String? fullName;
//   final String? email;
//   final int? mobile;
//   String? role;
//   String? oRole;
//   final String? otp;
//   final String? profilePic;
//   final String? datetime;
//   // final String? address;
//   final Map<String, dynamic>? addressMap;  // ya String? addressJson;
//   final String? token;
//
//   AjugnuUser({
//     required this.otpVerified,
//     this.firebaseToken,
//     this.pinCode,
//     this.id,
//     this.fullName,
//     this.email,
//     this.mobile,
//     this.role,
//     this.oRole,
//     this.otp,
//     this.profilePic,
//     this.datetime,
//     // this.address,
//     this.addressMap,
//     this.token,
//   });
//
//   factory AjugnuUser.fromJson(Map<String, dynamic> json, {String? token}) {
//     var profilePicture = json['profile_pic'] as String?;
//     return AjugnuUser(
//       otpVerified: json['otp_verified'] ?? 0,
//       firebaseToken: json['firebase_token'] as String?,
//       pinCode: json['pin_code'] != null ? List<String?>.from(json['pin_code']) : null,
//       id: json['_id'] as String?,
//       fullName: json['full_name'] as String?,
//       email: json['email'] as String?,
//       mobile: int.tryParse("${json['mobile']??"0"}")??0,
//       role: json['role'] as String?,
//       oRole: (json['oRole'] as String?) ?? json['role'] as String?,
//       otp: json['otp'] as String?,
//       profilePic: profilePicture?.startsWith('http') == true ? profilePicture : "$ajugnuBaseUrl/$profilePicture",
//       datetime: json['datetime'] as String?,
//       // address: json['address'] as String?,
//       addressMap: json['address'] as Map<String, dynamic>?,
//       token: token,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'otp_verified': otpVerified,
//       'firebase_token': firebaseToken,
//       'pin_code': pinCode,
//       '_id': id,
//       'full_name': fullName,
//       'email': email,
//       'mobile': mobile,
//       'role': role,
//       'oRole': oRole,
//       'otp': otp,
//       'profile_pic': profilePic,
//       'datetime': datetime,
//       'address': address,
//       'token': token
//     };
//   }
// }

import '../users/common/backend/api_handler.dart';

class AjugnuUser {
  final int otpVerified;
  final String? firebaseToken;
  final List<String?>? pinCode;
  final String? id;
  final String? fullName;
  final String? email;
  final int? mobile;
  String? role;
  String? oRole;
  final String? otp;
  final String? profilePic;
  final String? datetime;
  final Map<String, dynamic>? addressMap;  // Naya field
  final String? token;

  AjugnuUser({
    required this.otpVerified,
    this.firebaseToken,
    this.pinCode,
    this.id,
    this.fullName,
    this.email,
    this.mobile,
    this.role,
    this.oRole,
    this.otp,
    this.profilePic,
    this.datetime,
    this.addressMap,
    this.token,
  });

  factory AjugnuUser.fromJson(Map<String, dynamic> json, {String? token}) {
    var profilePicture = json['profile_pic'] as String?;
    return AjugnuUser(
      otpVerified: json['otp_verified'] ?? 0,
      firebaseToken: json['firebase_token'] as String?,
      pinCode: json['pin_code'] != null
          ? List<String?>.from(json['pin_code'])
          : null,
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      mobile: int.tryParse("${json['mobile'] ?? "0"}") ?? 0,
      role: json['role'] as String?,
      oRole: (json['oRole'] as String?) ?? json['role'] as String?,
      otp: json['otp'] as String?,
      profilePic: profilePicture?.startsWith('http') == true
          ? profilePicture
          : profilePicture != null ? "$ajugnuBaseUrl/$profilePicture" : null,
      datetime: json['datetime'] as String?,
      addressMap: json['address'] as Map<String, dynamic>?,
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp_verified': otpVerified,
      'firebase_token': firebaseToken,
      'pin_code': pinCode,
      '_id': id,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'role': role,
      'oRole': oRole,
      'otp': otp,
      'profile_pic': profilePic,
      'datetime': datetime,
      'address': addressMap,  // ✅ Yahan addressMap daal diya
      'token': token
    };
  }

  // Bonus: Agar tujhe address ko string mein dikhana ho kahin screen pe
  String get fullAddress {
    if (addressMap == null) return 'No address';
    final parts = <String>[];
    if (addressMap!['building_name'] != null) parts.add(addressMap!['building_name']);
    if (addressMap!['address_line'] != null) parts.add(addressMap!['address_line']);
    if (addressMap!['city'] != null) parts.add(addressMap!['city']);
    if (addressMap!['state'] != null) parts.add(addressMap!['state']);
    return parts.isEmpty ? 'No address' : parts.join(', ');
  }
}