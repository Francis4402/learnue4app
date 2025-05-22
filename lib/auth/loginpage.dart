


import 'package:flutter/material.dart';
import 'package:learnue4app/services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  void loginUser() {
    if (_formKey.currentState!.validate()) {
      authService.signInUser(
          context: context,
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                        const Icon(Icons.email, color: Colors.white70)),
                    style: const TextStyle(color: Colors.white),
                  ),
        
                  const SizedBox(height: 20),
        
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.white70,
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                  ),
        
                  const SizedBox(height: 30),
        
                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ),
        
                  const SizedBox(height: 20),
        
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         child: Divider(
                  //           color: Colors.white.withOpacity(0.3),
                  //           thickness: 1,
                  //         )),
                  //     const Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 10),
                  //       child: Text(
                  //         'OR',
                  //         style: TextStyle(color: Colors.white70),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.white.withOpacity(0.3),
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //   ],
                  // ),

        
                  // OutlinedButton(
                  //   onPressed: () {},
                  //   style: OutlinedButton.styleFrom(
                  //       backgroundColor: Colors.white.withOpacity(0.1),
                  //       padding: const EdgeInsets.symmetric(
                  //           horizontal: 40, vertical: 15),
                  //       side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10))),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Image.asset(
                  //         'assets/googleicon.png',
                  //         height: 22,
                  //         width: 22,
                  //       ),
                  //       const SizedBox(
                  //         width: 10,
                  //       ),
                  //       const Text(
                  //         'Sign in with Google',
                  //         style: TextStyle(color: Colors.white, fontSize: 16),
                  //       )
                  //     ],
                  //   ),
                  // ),
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

