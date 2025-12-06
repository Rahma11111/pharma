import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://pharmalink.runasp.net/api";

  static const String base = "https://pharmalink.runasp.net/api";

  static const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNyIsImp0aSI6ImE1NTQ0Yjk0LTY1OGUtNDg1Yi05ODA4LWNkZWI2MTY5ZTE2YiIsImVtYWlsIjoicGhhcm1hZWFzeTU2NUBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjE3IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6Imthcm1hIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiUGhhcm1hY3kiLCJleHAiOjE3NjU2MzY1MDgsImlzcyI6Imh0dHBzOi8vcGhhcm1hbGluay5ydW5hc3AubmV0IiwiYXVkIjoiaHR0cHM6Ly9waGFybWFsaW5rLnJ1bmFzcC5uZXQifQ.gLqPLshisQSSO58os6FCUE9hBd_tXxjnle40GtVKsiA" ;
  // ============================================================
  // GET ALL MEDICINES
  // ============================================================

  static Future<List<dynamic>> getMedicines() async {
    final response = await http.get(Uri.parse("$base/Medicine"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error loading medicines: ${response.body}");
      return [];
    }
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  static Future<void> addToCart(int id) async {
    try {
      final response = await http.post(
        Uri.parse("$base/Cart"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"medicineId": id, "quantity": 1}),
      );

      print("🛒 Add to cart status: ${response.statusCode}");
      print("🛒 Add to cart body: ${response.body}");
    } catch (e) {
      print("❌ Cart Error: $e");
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

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

  // ============================================================
  // LOGIN
  // ============================================================

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
