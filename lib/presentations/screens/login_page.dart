import 'package:flutter/material.dart';
import '../../core/services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ১. কন্ট্রোলার তৈরি করা (ইমেল এবং পাসওয়ার্ডের জন্য)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // মেমরি লিক রোধ করতে কন্ট্রোলারগুলো ডিসপোজ করা ভালো
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Center(
              child: Icon(Icons.school_rounded, size: 80, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 32),
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text("Login to continue your learning journey", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // ইমেইল ইনপুট
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Email Address",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // পাসওয়ার্ড ইনপুট
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {}, child: const Text("Forgot Password?")),
            ),
            const SizedBox(height: 24),

            // লগইন বাটন
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email and Password required!")));
                    return;
                  }

                  // লোডার দেখানো
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()));

                  // গুরুত্বপূর্ণ পরিবর্তন: এখানে signIn ফাংশন কল করা হয়েছে
                  String? result = await AuthService().signIn(email, password);

                  if (!mounted) return; // কনটেক্সট ঠিক আছে কি না চেক করা
                  Navigator.pop(context); // লোডার বন্ধ করা

                  if (result == "success") {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result ?? "An error occurred")),
                    );
                  }
                },
                child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            // সাইন আপে যাওয়ার বাটন
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // এটি আপনাকে সাইন আপ পেজে নিয়ে যাবে
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}