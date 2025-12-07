// lib/search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'history_page.dart';
import 'cart_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> allMedicines = [];
  List<dynamic> filteredMedicines = [];

  bool isLoading = true;
  bool isError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  @override
  void dispose() {
    companyController.dispose();
    medicineController.dispose();
    super.dispose();
  }

  Future<void> loadMedicines() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = "";
    });

    try {
      final data = await ApiService.getMedicines();
      if (data is List) {
        setState(() {
          allMedicines = data;
          filteredMedicines = List.from(allMedicines);
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorMessage = "Unexpected response format from API";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = "Failed to load medicines: $e";
        isLoading = false;
      });
    }
  }

  String fixImageUrl(dynamic rawUrl) {
    if (rawUrl == null) return "";

    // 1) Convert backslashes → forward slashes
    String url = rawUrl.toString().replaceAll("\\", "/");

    // 2) لو الرابط جاهز بالكامل
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }

    // 3) لو الرابط جاي فيه uploads
    if (url.contains("uploads")) {
      url = "/uploads" + url.split("uploads").last;
    }

    // 4) Add base URL
    const base = "https://pharmalink.runasp.net";

    return "$base$url";
  }


  void filterList() {
    String med = medicineController.text.trim().toLowerCase();
    String comp = companyController.text.trim().toLowerCase();

    setState(() {
      filteredMedicines = allMedicines.where((item) {
        final name = (item["medicineName"] ?? "").toString().toLowerCase();
        final company = (item["companyName"] ?? "").toString().toLowerCase();
        final matchMed = med.isEmpty ? true : name.contains(med);
        final matchComp = comp.isEmpty ? true : company.contains(comp);
        return matchMed && matchComp;
      }).toList();
    });
  }

  void showMedicineModal(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item["medicineName"] ?? ""),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((item["imageUrl"] ?? "").toString().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    fixImageUrl(item["imageUrl"]),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 12),
              Text(item["description"] ?? ""),
              const SizedBox(height: 12),
              Text("Price: ${item["price"]?.toString() ?? "-"} EGP"),
              Text("In stock: ${item["inStock"]?.toString() ?? "-"}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (item["id"] != null) {
                ApiService.addToCart(item["id"]);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to cart")),
                );
              }
            },
            child: const Text("Add to cart"),
          )
        ],
      ),
    );
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
              isSelected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: "History",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
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

  Widget _searchFields() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: companyController,
              decoration: InputDecoration(
                hintText: "🔍 Company...",
                filled: true,
                fillColor: const Color(0xffd9e8d8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (_) => filterList(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: medicineController,
              decoration: InputDecoration(
                hintText: "🔍 Medicine...",
                filled: true,
                fillColor: const Color(0xffd9e8d8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (_) => filterList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xff008682),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text("Drug", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 2, child: Center(child: Text("Company", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Price", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Qunty", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Photo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _medicineRow(dynamic med) {
    final name = med["medicineName"] ?? "-";
    final company = med["companyName"] ?? "-";
    final price = med["price"]?.toString() ?? "-";
    final qty = med["inStock"]?.toString() ?? "-";

    final rawImage = med["imageUrl"];
    final imgUrl = (rawImage == null) ? "" : fixImageUrl(rawImage);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text(name, textAlign: TextAlign.center))),
          Expanded(flex: 2, child: Center(child: Text(company, textAlign: TextAlign.center))),
          Expanded(flex: 1, child: Center(child: Text("$price EGP", textAlign: TextAlign.center))),
          Expanded(flex: 1, child: Center(child: Text(qty, textAlign: TextAlign.center))),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (med["id"] != null) {
                    final success = await ApiService.addToCart(med["id"]);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Added to cart successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to add to cart"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff008682),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("+", style: TextStyle(fontSize: 18,color: Colors.white)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () => showMedicineModal(med),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: imgUrl.isEmpty
                        ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 30)
                        : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("Image error for $imgUrl: $error");
                        return const Icon(Icons.image_not_supported, color: Colors.grey, size: 30);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyContent() {
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
              ElevatedButton(onPressed: loadMedicines, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (filteredMedicines.isEmpty) {
      return const Expanded(child: Center(child: Text("No medicines found")));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredMedicines.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return _tableHeader();
          }
          final med = filteredMedicines[i - 1];
          return _medicineRow(med);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Search Medicines"),
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
          _searchFields(),
          _bodyContent(),
        ],
      ),
    );
  }
}