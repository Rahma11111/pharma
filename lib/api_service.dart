import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://pharmalink.runasp.net/api";

  static const String base = "https://pharmalink.runasp.net/api";

  // ============================================================
  // FIXED TOKEN
  // ============================================================

  static const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNyIsImp0aSI6ImE1NTQ0Yjk0LTY1OGUtNDg1Yi05ODA4LWNkZWI2MTY5ZTE2YiIsImVtYWlsIjoicGhhcm1hZWFzeTU2NUBnbWFpbC5jb20iLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjE3IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6Imthcm1hIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiUGhhcm1hY3kiLCJleHAiOjE3NjU2MzY1MDgsImlzcyI6Imh0dHBzOi8vcGhhcm1hbGluay5ydW5hc3AubmV0IiwiYXVkIjoiaHR0cHM6Ly9waGFybWFsaW5rLnJ1bmFzcC5uZXQifQ.gLqPLshisQSSO58os6FCUE9hBd_tXxjnle40GtVKsiA";

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
  static Future<bool> addToCart(int id) async {
    try {
      print("🛒 Adding medicine $id to cart...");
      print("🔑 Using token: ${token.substring(0, 40)}...");

      final requestBody = {
        "Id": id,
        "Count": 1,
      };
      print("📦 Request body: $requestBody");

      final response = await http.post(
        Uri.parse("$base/Cart/AddToCart"),   // ← الصحيح
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      print("📥 Add to cart status: ${response.statusCode}");
      print("📥 Add to cart response: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Added to cart successfully");
        return true;
      }

      print("❌ Failed to add to cart: ${response.statusCode}");
      return false;

    } catch (e) {
      print("❌ Cart Error: $e");
      return false;
    }
  }


  // ============================================================
  // GET CART
  // ============================================================

  static Future<dynamic> getCart() async {
    try {
      print("🛒 Loading cart...");

      final response = await http.get(
        Uri.parse("$base/Cart"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📥 Cart Response Status: ${response.statusCode}");
      print("📥 Cart Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Cart loaded successfully");
        print("📦 Data structure: $data");
        return data;
      } else if (response.statusCode == 401) {
        throw Exception("Session expired. Please login again");
      } else {
        throw Exception("Failed to load cart: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in getCart: $e");
      rethrow;
    }
  }

  // ============================================================
  // UPDATE CART ITEM
  // ============================================================

  static Future<bool> updateCartItem(int cartItemId, int newQuantity) async {
    try {
      print("🔄 Updating cart item $cartItemId to quantity $newQuantity");

      final response = await http.put(
        Uri.parse("$base/Cart/UpdateCartItem"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "id": cartItemId,
          "count": newQuantity,
        }),
      );

      print("📥 Update Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Cart item updated successfully");
        return true;
      } else {
        print("❌ Failed to update cart item: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error in updateCartItem: $e");
      return false;
    }
  }

  // ============================================================
  // DELETE CART ITEM
  // ============================================================

  static Future<void> deleteCartItem(int cartItemId) async {
    try {
      print("🗑️ Deleting cart item $cartItemId");

      final response = await http.delete(
        Uri.parse("$base/Cart/DeleteCartItem/$cartItemId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("📥 Delete Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Cart item deleted successfully");
      } else {
        throw Exception("Failed to delete cart item: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in deleteCartItem: $e");
      rethrow;
    }
  }

  // ============================================================
  // GET PHARMACY ORDERS (HISTORY)
  // ============================================================

  static Future<dynamic> getPharmacyOrders() async {
    try {
      print("🔍 Loading pharmacy orders...");

      final response = await http.get(
        Uri.parse("$base/Order/IndexPharmacyOrder"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("📥 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Orders loaded successfully: ${data.length} orders");
        return data;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - Token may be expired");
        throw Exception("Session expired. Please login again");
      } else {
        print("❌ Failed to load orders: ${response.statusCode}");
        throw Exception("Failed to load orders: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in getPharmacyOrders: $e");
      rethrow;
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