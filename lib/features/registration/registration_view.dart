import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internal_app/features/login/login_view.dart';
import 'package:internal_app/features/registration/email_verification_view.dart';

import 'package:internal_app/infrastructure/network/api/api_client.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView>{
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool passwordsMatch = true;
  final Map<String, String> _formData = {};
  late Timer _debounce;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController workEmailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    workEmailController.dispose();
    roleController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

   void _debounceInput(String key, String value) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _formData[key] = value;
      });
    });
  } 

  void _togglePasswordVisibility () {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility () {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _validatePasswords() {
  setState(() {
    passwordsMatch = passwordController.text == confirmPasswordController.text;
  });
}

  Future<void> _onSubmit()  async {
    _validatePasswords(); 
    if (!passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords must match")),
      );
      return;
    }

    print("Starting _onSubmit");
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String workEmail = workEmailController.text;
    String role = roleController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if ([firstName, lastName, workEmail, password, role, confirmPassword].any((input) => input.isEmpty)) {
      print("All fields are required");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
    setState(() => _isLoading = true);
    final apiClient = RepositoryProvider.of<ApiClient>(context);
    try {
      print("Attempting API call with values: $firstName, $lastName, $workEmail");
      await apiClient.registerUser(
        firstName: firstName,
        lastName: lastName,
        workEmail: workEmail,
        role: role,
        password: password,
        confirmPassword: confirmPassword,
      );

      setState(() => _isLoading = false);

      print("API call successful, navigating to EmailVerificationView");
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailVerificationView(workEmail: workEmail)
      )
    );

    } catch (error) {
      setState(() => _isLoading = false);
      print("API call failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $error")),
      );
    } 
  }


  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          toolbarHeight: 49,
        ),
        body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 31),
                      Text(
                        'Create Your Account',
                        style: GoogleFonts.inter(
                          color: Color(0xFF101828),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        )
                      ),
                      Text(
                        'Discover top talent',
                        style: GoogleFonts.inter(
                          color: Color(0xFF667A81),
                          fontSize: 18,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          CustomTextField(
                            labelText: 'First name',
                            hintText: 'First name',
                            controller: firstNameController
                          ),
                          SizedBox(width: 16),
                          CustomTextField(
                            labelText: 'Last name',
                            hintText: 'Last name',
                            controller: lastNameController
                          )
                        ],
                      ),
                      SizedBox(height: 24),
                      CustomTextField(
                        labelText: 'Work email',
                        hintText: 'you@email.com',
                        controller: workEmailController
                      ),
                      SizedBox(height: 24),
                      CustomTextField(
                        labelText: 'Role',
                        hintText: 'Type in your role',
                        controller: roleController
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF344054)
                        )
                      ),
                      SizedBox(height: 6),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            hintStyle: GoogleFonts.inter(
                              color: Color(0xFF667085),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFFD0D5DD),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFF29CFD6),
                                width: 1,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF000000)
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          cursorColor: Color(0xFF29CFD6),
                          style: GoogleFonts.inter(
                            color: Color(0xFF000D12),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // eight character warning
                      SizedBox(height: 6),
                      Text(
                        'Use 8 or more characters with uppercase and numbers.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF667085)
                        )
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Confirm Password',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF344054)
                        )
                      ),
                      SizedBox(height: 6),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          onChanged: (_) => _validatePasswords(),
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            hintStyle: GoogleFonts.inter(
                              color: Color(0xFF667085),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: passwordsMatch ? Color(0xFFD0D5DD) : Color(0xFFE5302c),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: passwordsMatch ? Color(0xFFD0D5DD) : Color(0xFFE5302c),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFF29CFD6),
                                width: 1,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF000000)
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
                            ),
                          ),
                          cursorColor: passwordsMatch ? Color(0xFF29CFD6) : Color(0xFFE5302C),
                          style: GoogleFonts.inter(
                            color: Color(0xFF000D12),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!passwordsMatch) ...[
                        SizedBox(height: 8),
                        Text(
                          'Passwords must match',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFE5302C)
                          )
                        ),
                      ],
                      SizedBox(height: 24),
                      Text(
                        'By signing up you agree to our Privacy Policy and Terms of Service',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF667085)
                        )
                      ),
                      SizedBox(height: 72),
                      InkWell(
                        onTap: _onSubmit,
                        child: Container(
                          height: 51,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFF00141B)
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Get Started',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF)
                              )
                            ),
                          )
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF000D12)
                            ),
                          ),
                          Text(
                            ' ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000D12)
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginView())
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF42B8BD)
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 45)
                    ],
                  ),
                ),
              ),
            ],
          
        )
      )
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF667085),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFD0D5DD),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFD0D5DD),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF29CFD6),
                    width: 1,
                  ),
                ),
              ),
              cursorColor: const Color(0xFF29CFD6),
              style: GoogleFonts.inter(
                color: const Color(0xFF000D12),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}