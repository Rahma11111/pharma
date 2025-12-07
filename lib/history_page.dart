// lib/history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'profile_page.dart';
import 'main.dart';
import 'search_page.dart';
import 'login_page.dart';
import 'cart_page.dart';
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> allOrders = [];
  List<dynamic> filteredOrders = [];
  String selectedStatus = 'all'; // all, pending, shipped, delivered

  bool isLoading = true;
  bool isError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = "";
    });

    try {
      print("Loading pharmacy orders..."); // Debug
      final data = await ApiService.getPharmacyOrders();
      print("Data received: $data"); // Debug

      if (data is List) {
        setState(() {
          allOrders = data;
          filteredOrders = List.from(allOrders);
          isLoading = false;
        });
        print("Orders loaded successfully: ${allOrders.length} orders");
      } else {
        setState(() {
          isError = true;
          errorMessage = "Unexpected response format from API";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading orders: $e"); // Debug
      setState(() {
        isError = true;
        errorMessage = "Failed to load orders: $e";
        isLoading = false;
      });

      // إذا كان الخطأ بسبب Token، اعرض رسالة واضحة
      if (e.toString().contains("Unauthorized") || e.toString().contains("token")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please login again."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void filterByStatus(String status) {
    setState(() {
      selectedStatus = status;
      if (status == 'all') {
        filteredOrders = List.from(allOrders);
      } else {
        filteredOrders = allOrders
            .where((order) =>
        (order['statusOrder'] ?? '').toString().toLowerCase() == status.toLowerCase())
            .toList();
      }
    });
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
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
              decoration: const BoxDecoration(
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
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 50,
                      color: Color(0xff008682),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
                  MaterialPageRoute(builder: (context) => const HomePage()),
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
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: "History",
              isSelected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart,
              title: "Cart",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
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

            const Divider(),
            _buildDrawerItem(
              icon: Icons.logout,
              title: "Logout",
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff008682).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xff008682) : (textColor ?? Colors.grey[700]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xff008682) : (textColor ?? Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton('All', 'all', Colors.grey),
          _buildFilterButton('Pending', 'pending', Colors.orange),
          _buildFilterButton('Shipped', 'shipped', Colors.blue),
          _buildFilterButton('Delivered', 'delivered', Colors.green),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String status, Color color) {
    final isSelected = selectedStatus == status;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => filterByStatus(status),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : color.withOpacity(0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: isSelected ? 4 : 1,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xff008682),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text("Company", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 2, child: Center(child: Text("Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 2, child: Center(child: Text("Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 2, child: Center(child: Text("State", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildOrderRow(dynamic order) {
    final companyName = order['companyName'] ?? '-';
    final city = order['city'] ?? '-';
    final orderDate = formatDate(order['orderDate']);
    final status = order['statusOrder'] ?? '-';
    final orderId = order['orderID'];

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                // Navigate to company profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("View profile: $companyName")),
                );
              },
              child: Center(
                child: Text(
                  companyName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff008682),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Center(child: Text(city, textAlign: TextAlign.center))),
          Expanded(flex: 2, child: Center(child: Text(orderDate, textAlign: TextAlign.center))),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to invoice details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("View invoice: $orderId")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff008682),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Icon(Icons.receipt, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (isError) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: loadOrders, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("No orders found", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredOrders.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return _buildTableHeader();
          }
          final order = filteredOrders[i - 1];
          return _buildOrderRow(order);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: const Color(0xff008682),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildFilterButtons(),
          _buildBodyContent(),
        ],
      ),
    );
  }
}