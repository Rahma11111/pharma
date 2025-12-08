import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'main.dart';
import 'search_page.dart';
import 'history_page.dart';
import 'cart_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? profileData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse("https://pharmalink.runasp.net/api/profile/Karma"),
        headers: {
          "Authorization": "Bearer ${ApiService.token}",
          "Content-Type": "application/json",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          profileData = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
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
              icon: Icons.person,
              title: "Profile",
              isSelected: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        backgroundColor: Color(0xff008682),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : profileData == null
          ? Center(child: Text("Failed to load profile"))
          : buildProfileUI(),
    );
  }

  Widget buildProfileUI() {
    final data = profileData!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/images/img-pharmacy.png"),

          ),

          SizedBox(height: 15),

          Text(
            data["drName"] ?? "",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(
            data["pharmacyEmail"] ?? "",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          SizedBox(height: 25),

          buildInfoCard("Pharmacy Name", data["pharmacyName"]),
          buildInfoCard("Phone Number", data["pharmacyPhoneNumber"]),
          buildInfoCard("License Number", data["pharmacyLicenseNumber"]),
          buildInfoCard("Address", "${data["street"]}, ${data["city"]}"),
          buildInfoCard("About Us", data["aboutUs"])
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, String? value) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          _getIconForTitle(title),
          color: Color(0xff008682),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          value ?? "Not available",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case "Pharmacy Name":
        return Icons.local_pharmacy;
      case "Phone Number":
        return Icons.phone;
      case "License Number":
        return Icons.badge;
      case "Address":
        return Icons.location_on;
      case "About Us":
        return Icons.info;
      default:
        return Icons.info;
    }
  }
}