// lib/cart_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'main.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'summary_page.dart';
import 'profile_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> cartItems = [];
  double totalPrice = 0.0;

  bool isLoading = true;
  bool isError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = "";
    });

    try {
      final dynamic data = await ApiService.getCart();
      print("📦 Cart data received: $data");
      print("📦 Data type: ${data.runtimeType}");

      // Handle the data structure
      if (data is Map<String, dynamic>) {
        final items = data['cartItems'];
        setState(() {
          if (items is List) {
            cartItems = List<dynamic>.from(items);
          } else {
            cartItems = [];
          }
          totalPrice = (data['totalPrice'] ?? 0).toDouble();
          isLoading = false;
        });
      } else if (data is List) {
        setState(() {
          cartItems = List<dynamic>.from(data);
          // Calculate total from items
          totalPrice = cartItems.fold<double>(0.0, (sum, item) {
            final priceRaw = item['medicinePrice'];
            double price = 0.0;
            if (priceRaw is String) {
              price = double.tryParse(priceRaw) ?? 0.0;
            } else if (priceRaw is num) {
              price = priceRaw.toDouble();
            }

            final count = (item['count'] ?? 1).toInt();
            return sum + (price * count);
          });
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorMessage = "Unexpected data format: ${data.runtimeType}";
          isLoading = false;
        });
      }

      print("✅ Cart loaded: ${cartItems.length} items, Total: $totalPrice");
    } catch (e) {
      print("❌ Error loading cart: $e");
      setState(() {
        isError = true;
        errorMessage = "Failed to load cart: $e";
        isLoading = false;
      });
    }
  }

  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    // Update UI immediately (optimistic update)
    setState(() {
      final index = cartItems.indexWhere((item) => item['cartItemId'] == cartItemId);
      if (index != -1) {
        cartItems[index]['count'] = newQuantity;
        // Recalculate total
        totalPrice = cartItems.fold<double>(0.0, (sum, item) {
          final priceRaw = item['medicinePrice'];
          double price = 0.0;
          if (priceRaw is String) {
            price = double.tryParse(priceRaw) ?? 0.0;
          } else if (priceRaw is num) {
            price = priceRaw.toDouble();
          }
          final count = (item['count'] ?? 1).toInt();
          return sum + (price * count);
        });
      }
    });

    try {
      final success = await ApiService.updateCartItem(cartItemId, newQuantity);
      if (!success) {
        // Revert if failed
        await loadCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sorry, the required quantity is not available"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Revert if error
      await loadCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> deleteItem(int cartItemId) async {
    try {
      await ApiService.deleteCartItem(cartItemId);
      await loadCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Item removed from cart"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String fixImageUrl(dynamic urlRaw) {
    if (urlRaw == null || urlRaw.toString().isEmpty) return "";
    String url = urlRaw.toString().trim();

    if (url.isEmpty) return "";

    // If already a complete URL, return as is
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }

    // Find the index of "uploads" in the string
    final index = url.indexOf("uploads");
    if (index != -1) {
      // Extract from "uploads" onwards
      url = url.substring(index);
    }

    // Replace backslashes with forward slashes
    url = url.replaceAll(r"\", "/");

    // Remove multiple slashes
    while (url.contains("//")) {
      url = url.replaceAll("//", "/");
    }

    // Ensure it starts with a slash
    if (!url.startsWith("/")) {
      url = "/$url";
    }

    // Build final URL - use http like in search page
    final finalUrl = "http://pharmalink.runasp.net$url";
    print("🖼️ Fixed Image URL: $finalUrl");

    return finalUrl;
  }

  String formatPrice(dynamic price) {
    try {
      double priceValue;

      if (price is String) {
        priceValue = double.tryParse(price) ?? 0.0;
      } else if (price is num) {
        priceValue = price.toDouble();
      } else {
        priceValue = 0.0;
      }

      final formatter = NumberFormat.currency(locale: 'en_US', symbol: 'EGP ', decimalDigits: 2);
      return formatter.format(priceValue);
    } catch (e) {
      print("❌ Error formatting price: $e, price: $price");
      return "EGP 0.00";
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff008682),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.local_pharmacy,
                      size: 50,
                      color: Color(0xff008682),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "PharmaLink",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: "Home",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.search,
              title: "Search",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: "History",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart,
              title: "Cart",
              isSelected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: "Profile",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),

            Divider(),
            _buildDrawerItem(
              icon: Icons.logout,
              title: "Logout",
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xff008682).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xff008682) : (textColor ?? Colors.grey[700]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Color(0xff008682) : (textColor ?? Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCartItem(dynamic item) {
    final cartItemId = item['cartItemId'];
    final medicineName = item['medicineName'] ?? '-';

    // Convert price to double safely
    final medicinePrice = item['medicinePrice'];
    double priceValue = 0.0;
    if (medicinePrice is String) {
      priceValue = double.tryParse(medicinePrice) ?? 0.0;
    } else if (medicinePrice is num) {
      priceValue = medicinePrice.toDouble();
    }

    final count = item['count'] ?? 1;
    final medicineImage = item['medicineImage'];

    final imgUrl = fixImageUrl(medicineImage);

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: imgUrl.isEmpty
                  ? Icon(Icons.medication, size: 40, color: Colors.grey)
                  : Image.network(
                imgUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print("❌ Image load error: $error");
                  print("🔗 Failed URL: $imgUrl");
                  return Icon(Icons.medication, size: 40, color: Colors.grey);
                },
              ),
            ),
          ),
          SizedBox(width: 12),

          // Medicine Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formatPrice(priceValue),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff008682),
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => updateQuantity(cartItemId, count - 1),
                  icon: Icon(Icons.remove),
                  color: Color(0xff008682),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff045657),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => updateQuantity(cartItemId, count + 1),
                  icon: Icon(Icons.add),
                  color: Color(0xff008682),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          SizedBox(width: 8),

          // Delete Button
          IconButton(
            onPressed: () => _showDeleteDialog(cartItemId),
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int cartItemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Item"),
        content: Text("Are you sure you want to remove this item from cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteItem(cartItemId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (isError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadCart,
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff008682),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text("CONTINUE SHOPPING", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) => _buildCartItem(cartItems[index]),
          ),
        ),

        // Total Price Section
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300, width: 2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOTAL:",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    formatPrice(totalPrice),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff008682),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () {
                    // Navigate to Summary page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SummaryPage(
                          cartItems: cartItems,
                          totalPrice: totalPrice,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff008682),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "SUMMERY",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Shopping Cart"),
        backgroundColor: Color(0xff008682),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          if (cartItems.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  "${cartItems.length} items",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBodyContent(),
    );
  }
}