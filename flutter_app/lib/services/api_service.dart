import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/loan_data.dart';

class ApiService {
  static Future<Map<String, dynamic>> demoGet(String path) async =>
      _decode(await http.get(Uri.parse('$baseUrl/$path'), headers: _headers));

  static Future<Map<String, dynamic>> applyDemo(int assessmentId, String lenderId) async =>
      _decode(await http.post(Uri.parse('$baseUrl/demo-applications'), headers: _headers,
        body: jsonEncode({'assessment_id': assessmentId, 'lender_id': lenderId, 'consent': true})));
  static const String baseUrl = 'http://127.0.0.1:5000';

  static String? _token;

  static String? get token => _token;

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',

      if (_token != null)
        'Authorization': 'Bearer $_token',
    };
  }

  static Future<Map<String, dynamic>> _decode(
    http.Response response,
  ) async {
    final Map<String, dynamic> data =
        jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Request failed',
    );
  }

  // ---------------------------------------------------
  // REGISTER
  // ---------------------------------------------------

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    return _decode(response);
  }

  // ---------------------------------------------------
  // LOGIN
  // ---------------------------------------------------

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = await _decode(response);

    _token = data['token'] as String?;

    return data;
  }

  // ---------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------

  static Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: _headers,
        );
      } catch (_) {}
    }

    _token = null;
  }

  // ---------------------------------------------------
  // PREDICTION
  // ---------------------------------------------------

  static Future<Map<String, dynamic>> predictLoan(
    LoanData loanData,
  ) async {
    if (_token == null) {
      throw Exception(
        'Please login first.',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: _headers,
      body: jsonEncode(
        loanData.toJson(),
      ),
    );

    return _decode(response);
  }
}
