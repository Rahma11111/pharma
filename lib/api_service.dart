import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://pharmalink.runasp.net/api";

  // ===============================================
  //                  REGISTER
  // ===============================================
  Future<bool> register({
    required String name,
    required String drName,
    required String email,
    required String phoneNumber,
    required String city,
    required String state,
    required String street,
    required String userName,
    required String password,
    required String licenseNumber,
    required String pdfURL,
  }) async {
    final url = Uri.parse("$baseUrl/requests/Register");

    final body = {
      "name": name,
      "drName": drName,
      "email": email,
      "phoneNumber": phoneNumber,
      "city": city,
      "state": state,
      "street": street,
      "userName": userName,
      "password": password,
      "licenseNumber": licenseNumber,
      "pdfURL": pdfURL,
    };

    print("📤 Sending data to API:");
    print(body);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📥 Response Status: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return false;
  }

  // ===============================================
  //                  LOGIN
  // ===============================================
  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/account/login");

    final body = {
      "userName": userName,
      "password": password,
      "rememberMe": true,
    };

    print("📤 Login Request: $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📥 Login Status: ${response.statusCode}");
    print("📥 Login Body: ${response.body}");

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      return {
        "success": false,
        "message": response.body,
      };
    }
  }
}
