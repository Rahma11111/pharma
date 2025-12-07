// lib/summary_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'main.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'cart_page.dart';
import 'login_page.dart';

class SummaryPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final double totalPrice;

  const SummaryPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isPlacingOrder = false;

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
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: "About",
              onTap: () {
                Navigator.pop(context);
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

  Widget _buildOrderItem(dynamic item) {
    final medicineName = item['medicineName'] ?? '-';
    final medicinePrice = item['medicinePrice'];
    double priceValue = 0.0;

    if (medicinePrice is String) {
      priceValue = double.tryParse(medicinePrice) ?? 0.0;
    } else if (medicinePrice is num) {
      priceValue = medicinePrice.toDouble();
    }

    final count = item['count'] ?? 1;
    final totalItemPrice = priceValue * count;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(

        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              medicineName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'x$count',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatPrice(priceValue),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              formatPrice(totalItemPrice),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff008682),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> placeOrder() async {
    setState(() {
      isPlacingOrder = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isPlacingOrder = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text("Order Placed!"),
            ],
          ),
          content: Text("Your order has been placed successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
              child: Text("View Orders"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: Text("Continue Shopping"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to place order: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Order Summary"),
        backgroundColor: Color(0xff008682),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16), // PAD RIGHT & LEFT
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),

                      child: Center(
                        child: Text(
                          "Review Your Order",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007F7F), // لون الخط اللي عندك
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      color: Color(0xff008682),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Medicine",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Qty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Price",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Total",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ...widget.cartItems.map((item) => _buildOrderItem(item)).toList(),

                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subtotal:",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatPrice(widget.totalPrice),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Delivery Fee:",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "EGP 0.00",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(height: 24, thickness: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TOTAL:",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatPrice(widget.totalPrice),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff008682),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isPlacingOrder ? null : placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff008682),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isPlacingOrder
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Placing Order...",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 28, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                "PLACE ORDER",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
