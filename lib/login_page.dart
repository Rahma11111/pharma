import 'package:flutter/material.dart';
import 'main.dart';
import 'api_service.dart';
import 'search_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // 🔵 🔵  اللوجو + اسم المشروع في الأعلى 🔵 🔵
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // اللوجو
                      Image.asset(
                        "assets/images/logo.png", // ← غيّري المسار لو عايزة
                        height: 45,
                      ),
                      const SizedBox(width: 180),
                      // اسم البروجكت
                      const Text(
                        "PharmaLink",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🟦 Image Banner (نفس الصورة اللي عندك)
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.asset(
                    "assets/images/pharmacy.jpg",
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 40),

                _field("Username", usernameController),
                const SizedBox(height: 20),

                _passwordField("Password", passwordController),
                const SizedBox(height: 30),

                // Login Button
                GestureDetector(
                  onTap: () async {
                    var result = await ApiService().login(
                      userName: usernameController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    if (result["success"] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login Successful")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Login Failed: ${result["message"]}"),
                        ),
                      );
                    }
                  },

                  child: Container(
                    width: isMobile ? double.infinity : 260,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- Fields -----------------------

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
