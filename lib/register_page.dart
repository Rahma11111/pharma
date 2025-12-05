import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final drnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final streetController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final licenseController = TextEditingController();
  final pdfUrlController = TextEditingController();

  bool obscurePass = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================
            // الصورة فوق
            // ===========================
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Image.asset(
                "assets/images/pharmacy.jpg",
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // ===========================
            // محتوى الفورم
            // ===========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Signup",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  inputField("Pharmacy Name", nameController),
                  inputField("Doctor Name", drnameController),
                  inputField("Email", emailController),
                  inputField("Phone Number", phoneController),

                  Row(
                    children: [
                      Expanded(child: inputField("City", cityController)),
                      const SizedBox(width: 10),
                      Expanded(child: inputField("State", stateController)),
                    ],
                  ),

                  inputField("Street", streetController),
                  inputField("User Name", usernameController),

                  passwordField("Password", passwordController, true),
                  passwordField("Confirm Password", confirmPasswordController, false),

                  Row(
                    children: [
                      Expanded(child: inputField("License Number", licenseController)),
                      const SizedBox(width: 10),
                      Expanded(child: inputField("PDF URL", pdfUrlController)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ===========================
                  // زرار التسجيل
                  // ===========================
                  GestureDetector(
                    onTap: () async {
                      bool success = await ApiService().register(
                        name: nameController.text.trim(),
                        street: streetController.text.trim(),
                        state: stateController.text.trim(),
                        city: cityController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        licenseNumber: licenseController.text.trim(),
                        userName: usernameController.text.trim(),
                        drName: drnameController.text.trim(),
                        pdfURL: pdfUrlController.text.trim(),
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registration Successful")),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registration Failed")),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===========================
                  // الانتقال للّوجين
                  // ===========================
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("If you already have an account, "),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          ),
                          child: const Text(
                            "Login here!",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // INPUT FIELD
  // ===========================
  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ===========================
  // PASSWORD FIELD
  // ===========================
  Widget passwordField(
      String label, TextEditingController controller, bool isMainPass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isMainPass ? obscurePass : obscureConfirm,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              (isMainPass ? obscurePass : obscureConfirm)
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                if (isMainPass) {
                  obscurePass = !obscurePass;
                } else {
                  obscureConfirm = !obscureConfirm;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
