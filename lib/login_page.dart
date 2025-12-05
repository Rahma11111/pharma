import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ---------------- LEFT SIDE (FORM) ----------------
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LOGO + TITLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset(
                            "assets/images/logo.png", // حطي صورة اللوجو هنا
                            height: 90,
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),

                      // USERNAME
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "Enter your username or email",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // PASSWORD
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                obscureText: !showPassword,
                                decoration: const InputDecoration(
                                  hintText: "Enter your Password",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => showPassword = !showPassword);
                              },
                              child: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // REMEMBER ME
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (v) =>
                                setState(() => rememberMe = v!),
                          ),
                          const Text("Remember Me"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A896),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // REGISTER LINK
                      Center(
                        child: Column(
                          children: [
                            const Text("If you don't have an account register"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("You can "),

                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: const Text(
                                    "Register here!",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),

          // ---------------- RIGHT SIDE (IMAGE) ----------------
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/pharmacy.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
