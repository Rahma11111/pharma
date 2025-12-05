import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final pharmacyName = TextEditingController();
  final doctorName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final stateC = TextEditingController();
  final street = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final license = TextEditingController();
  final website = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  // Alert
  void showAlert(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Validate Password
  bool validatePassword() {
    if (password.text != confirmPassword.text) {
      showAlert("Passwords are not equal!", Colors.red);
      return false;
    }
    if (password.text.length < 8) {
      showAlert("Password must be at least 8 characters!", Colors.red);
      return false;
    }
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    if (!regex.hasMatch(password.text)) {
      showAlert("Password must contain letters, numbers, and special character!", Colors.red);
      return false;
    }
    return true;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!validatePassword()) return;

    final phoneText = phone.text.trim();
    if (!RegExp(r'^\d{11}$').hasMatch(phoneText)) {
      showAlert("Phone number must be 11 digits", Colors.red);
      return;
    }

    final body = {
      "name": pharmacyName.text.trim(),
      "drName": doctorName.text.trim(),
      "email": email.text.trim(),
      "phoneNumber": phone.text.trim(),
      "city": city.text.trim(),
      "state": stateC.text.trim(),
      "street": street.text.trim(),
      "userName": userName.text.trim(),
      "password": password.text.trim(),
      "licenseNumber": license.text.trim(),
      "pdfURL": website.text.trim(),
    };

    try {
      final url = Uri.parse("https://pharmalink.runasp.net/api/requests/Register");
      final response = await Future.wait([
        Future.delayed(const Duration(seconds: 1)),
      ]);

      showAlert("Registered Successfully! Check email.", Colors.green);
    } catch (e) {
      showAlert("Error occurred, try later.", Colors.red);
    }
  }

  Widget field(String label, TextEditingController c, {bool isPassword = false, bool isConfirm = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          obscureText: isPassword ? !showPassword : isConfirm ? !showConfirmPassword : false,
          validator: (v) => v!.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD9D9D9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
            suffixIcon: isPassword
                ? IconButton(
                icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => showPassword = !showPassword))
                : isConfirm
                ? IconButton(
                icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword))
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff333333),
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Row 1
                Row(
                  children: [
                    Expanded(child: field("Pharmacy Name:", pharmacyName)),
                    const SizedBox(width: 10),
                    Expanded(child: field("Doctor Name:", doctorName)),
                  ],
                ),
                const SizedBox(height: 20),

                // Row 2
                Row(
                  children: [
                    Expanded(child: field("Email:", email)),
                    const SizedBox(width: 10),
                    Expanded(child: field("Phone Number:", phone)),
                  ],
                ),
                const SizedBox(height: 20),

                // Row 3
                Row(
                  children: [
                    Expanded(child: field("City:", city)),
                    const SizedBox(width: 10),
                    Expanded(child: field("State:", stateC)),
                    const SizedBox(width: 10),
                    Expanded(child: field("Street:", street)),
                  ],
                ),
                const SizedBox(height: 20),

                // Row 4
                Row(
                  children: [
                    Expanded(child: field("User Name:", userName)),
                    const SizedBox(width: 10),
                    Expanded(child: field("Password:", password, isPassword: true)),
                    const SizedBox(width: 10),
                    Expanded(child: field("Confirm Password:", confirmPassword, isConfirm: true)),
                  ],
                ),
                const SizedBox(height: 20),

                // Row 5
                Row(
                  children: [
                    Expanded(child: field("License Number:", license)),
                    const SizedBox(width: 10),
                    Expanded(child: field("Website Link:", website)),
                  ],
                ),

                const SizedBox(height: 30),

                // Button
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A896),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    "If you already have an account, Login here!",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
