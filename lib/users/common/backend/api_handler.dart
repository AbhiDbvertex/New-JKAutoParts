import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void adebug(dynamic message, {String? tag}) {
  if (tag == null) {
    print('Abhi:- [$message]');
  } else {
    print('Abhi:- $tag:[$message]');
  }
}

// Errors
String serverDownError = 'Server is not working, please wait and try again after some time.';
String noInternetError = 'Something went wrong, please check your internet connection and retry.';
String responseParseError = 'Error while parsing response.';

// Server parameters
// String ajugnuBaseUrl = 'https://control.ajugnu.com'; //changed
// String ajugnuBaseUrl = 'https://api.jkautomed.graphicsvolume.com'; //changed
String ajugnuBaseUrl = 'https://api.jkautomedglobal.in'; //changed
// String ajugnuBaseUrl = 'http://82.29.167.252:5000';

String googleApiKey = 'AIzaSyDljqDaD7qc2MKOzbu0Q3-1G1J5my2kv3s';

// Razorpay credentials
// String razorpayApiKey = 'rzp_live_WAd4Fh2plS33qq';
// String razorpayServerKey = 'oFImM8EglZY49QBx3sAWLjsb';
//
// Razorpay test credentials
String razorpayApiKey = 'rzp_test_th8QsRDriRnwvZ';
String razorpayServerKey = 'fZMFOEiejoURtlO4mF3G2JaM';

Future<ApiResponse> makeHttpPostRequest({required String endpoint, required String bodyJson, String? authorization}) async {
  if (kDebugMode) {
    adebug('HTTP Request: $bodyJson', tag: endpoint);
  }

  Map<String, String> headers = {'Content-Type': 'application/json'};
  if (authorization != null) {
    headers['Authorization'] = "Bearer $authorization";
  }

  late http.Response response;
  try {
    response = await http.post(Uri.parse("$ajugnuBaseUrl$endpoint"), body: bodyJson, headers: headers, encoding: Encoding.getByName('utf-8'),).timeout(const Duration(minutes: 2));
  } catch (error) {
    throw noInternetError;
  }

  if (kDebugMode) {
    adebug('HTTP response(${response.statusCode}): ${response.body}');
  }

  late dynamic responseInJson;
  try {
    responseInJson = jsonDecode(response.body);
  } catch (error) {
    if (response.statusCode == 502) {
      throw serverDownError;
    } else {
      rethrow;
    }
  }
  return ApiResponse(statusCode: response.statusCode, responseBody: responseInJson);
}

Future<ApiResponse> makeHttpPutRequest({required String endpoint, required String bodyJson, String? authorization}) async {
  if (kDebugMode) {
    adebug('HTTP Request: $bodyJson', tag: endpoint);
  }

  Map<String, String> headers = {'Content-Type': 'application/json'};
  if (authorization != null) {
    headers['Authorization'] = "Bearer $authorization";
  }

  late http.Response response;
  try {
    response = await http.put(Uri.parse("$ajugnuBaseUrl$endpoint"), body: bodyJson, headers: headers, encoding: Encoding.getByName('utf-8'),).timeout(const Duration(minutes: 2));
  } catch (error) {
    throw noInternetError;
  }

  if (kDebugMode) {
    adebug('HTTP response(${response.statusCode}): ${response.body}');
  }

  late dynamic responseInJson;
  try {
    responseInJson = jsonDecode(response.body);
  } catch (error) {
    if (response.statusCode == 502) {
      throw serverDownError;
    } else {
      throw error;
    }
  }
  return ApiResponse(statusCode: response.statusCode, responseBody: responseInJson);
}


Future<ApiResponse> makeHttpGetRequest({required String endpoint, String? authorization}) async {
  if (kDebugMode) {
    adebug('HTTP Request(auth: $authorization)', tag: endpoint.replaceAll('.*/', ''));
  }

  Map<String, String> headers = {'Content-Type': 'application/json'};
  if (authorization != null) {
    headers['Authorization'] = "Bearer $authorization";
  }

  late http.Response response;
  try {
    response = await http.get(Uri.parse("$ajugnuBaseUrl$endpoint"), headers: headers).timeout(const Duration(minutes: 2));
  } catch (error) {
    throw noInternetError;
  }

  if (kDebugMode) {
    adebug('HTTP response(${response.statusCode}): ${response.body}', tag: endpoint.replaceAll('.*/', ''));
  }

  late dynamic responseInJson;
  try {
    responseInJson = jsonDecode(response.body);
  } catch (error) {
    if (response.statusCode == 502) {
      throw serverDownError;
    } else {
      rethrow;
    }
  }
  return ApiResponse(statusCode: response.statusCode, responseBody: responseInJson);
}

class ApiResponse {
  final int statusCode;
  final dynamic responseBody;

  const ApiResponse({required this.statusCode, required this.responseBody});
}