import 'package:flutter/material.dart';
import '../../../core/services/auth_services.dart'; // পাথটি চেক করে নিন

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // কন্ট্রোলারগুলো তৈরি করা
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "Full Name", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: "Email Address", prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 32),

            // সাইন আপ বাটন
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String name = _nameController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  // খালি আছে কি না চেক করা
                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("সবগুলো ঘর পূরণ করুন")),
                    );
                    print("বাটনে ক্লিক করা হয়েছে!"); // এই লাইনটি যোগ করুন
                    print("নাম: $name, ইমেইল: $email"); // ডাটা চেক করার জন্য
                    return;
                  }

                  // ১. লোডার দেখানো
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  // ২. AuthService-এর signUp ফাংশন কল করা
                  String? result = await AuthService().signUp(name, email, password);

                  if (!mounted) return;
                  Navigator.pop(context); // লোডার বন্ধ করা

                  // ৩. রেজাল্ট চেক করা
                  if (result == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account Created Successfully!")),
                    );
                    // সফল হলে সরাসরি হোম পেজে নিয়ে যাবে
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    // ভুল হলে এরর মেসেজ দেখাবে (যেমন: ইমেইল ভুল বা পাসওয়ার্ড ছোট)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result!)),
                    );
                  }
                },
                child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}