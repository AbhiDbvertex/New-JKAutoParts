import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jkautomed/users/common/backend/api_handler.dart';

class GoogleApis {

  Future<bool> isPostalCodeValid(String postalCode) async {
    final endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address=$postalCode&key=$googleApiKey';
    if (kDebugMode) {
      adebug('HTTP Request', tag: endpoint.replaceAll('.*/', ''));
    }

    late http.Response response;
    try {
      response = await http.get(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}).timeout(const Duration(minutes: 2));
    } catch (error) {
      throw noInternetError;
    }

    if (kDebugMode) {
      adebug('HTTP response(${response.statusCode}): ${response.body}');
    }

    late dynamic responseInJson;
    try {
      responseInJson = jsonDecode(response.body);
      return responseInJson['status'] == 'OK' && responseInJson['results'].isNotEmpty;
    } catch (error) {
      adebug(error, tag: 'Google Api');
      if (response.statusCode == 502) {
        throw serverDownError;
      } else {
        rethrow;
      }
    }
  }

}