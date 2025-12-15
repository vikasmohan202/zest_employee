import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zest_employee/core/constants/branded_primary_button.dart';
import 'package:zest_employee/core/constants/branded_primary_textfield.dart';
import 'package:zest_employee/logic/bloc/auth/auth_bloc.dart';
import 'package:zest_employee/logic/bloc/auth/auth_event.dart';
import 'package:zest_employee/logic/bloc/auth/auth_state.dart';
import 'package:zest_employee/presentation/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  bool rememberMe = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color.fromRGBO(51, 107, 63, 1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final loading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Let's Sign You In",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Welcome back, you've \nbeen missed!",
                      style: TextStyle(fontSize: 24, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),

                    // Email
                    BrandedTextField(
                      controller: _email,
                      labelText: "Email Address",
                      prefix: const Icon(Icons.email_outlined),
                      backgroundColor: Colors.white.withOpacity(0.16),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter email' : null,
                    ),

                    const SizedBox(height: 20),

                    // Password
                    BrandedTextField(
                      controller: _password,
                      labelText: "Password",
                      isPassword: true,
                      prefix: const Icon(Icons.lock_outline),
                      backgroundColor: Colors.white.withOpacity(0.16),

                      sufix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min 6 chars' : null,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                              checkColor: Colors.white,
                              activeColor: Colors.lightGreenAccent,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        // TextButton(
                        //   onPressed: () {
                        //     // Navigator.push(
                        //     //   context,
                        //     //   MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()),
                        //     // );
                        //   },
                        //   child: const Text(
                        //     "Forgot Password ?",
                        //     style: TextStyle(color: Colors.lightGreenAccent),
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: BrandedPrimaryButton(
                        isEnabled: !loading,
                        isTextBlack: true,
                        name: loading ? "Please wait..." : "Login",
                        onPressed: () {
                          if (_form.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                _email.text.trim(),
                                _password.text,
                              ),
                            );
                          }
                          // Navigator.of(
                          //   context,
                          // ).pushReplacementNamed(AppRoutes.dashboard);
                          // if (_form.currentState!.validate()) {
                          //   context.read<AuthBloc>().add(
                          //     AuthLoginRequested(
                          //       _email.text.trim(),
                          //       _password.text,
                          //     ),
                          //   );
                          // }
                        },
                      ),
                    ),

                    // const SizedBox(height: 20),
                    // const Center(
                    //   child: Text(
                    //     "OR",
                    //     style: TextStyle(color: Colors.white70),
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    // GOOGLE LOGIN
                    // BrandedPrimaryButton(
                    //   name: "Continue with Google",
                    //   isUnfocus: true,
                    //   isTextBlack: true,
                    //   // suffixIcon: const FaIcon(FontAwesomeIcons.google, size: 20),
                    //   onPressed: () {
                    //     // implement Google login or dispatch Bloc event
                    //   },
                    // ),
                    const SizedBox(height: 40),

                    // GestureDetector(
                    //   onTap: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(builder: (c) => const SignUpScreen()),
                    //     // );
                    //   },
                    //   child: Center(
                    //     child: RichText(
                    //       text: const TextSpan(
                    //         text: "Don't have an account ? ",
                    //         style: TextStyle(color: Colors.white70),
                    //         children: [
                    //           TextSpan(
                    //             text: "Sign Up",
                    //             style: TextStyle(
                    //               color: Colors.lightGreenAccent,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 30),
                    // show an inline loading indicator for extra affordance
                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
