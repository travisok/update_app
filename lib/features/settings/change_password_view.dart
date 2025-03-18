import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internal_app/infrastructure/network/api/api_client.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';

class ChangePasswordView extends StatefulWidget{
  const ChangePasswordView({super.key});

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView>{
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool passwordsMatch = true;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _toggleOldPasswordVisibility () {
    setState(() {
      _obscureOldPassword = !_obscureOldPassword;
    });
  }

  void _toggleNewPasswordVisibility () {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility () {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _validatePasswords() {
    setState(() {
      passwordsMatch = newPasswordController.text == confirmPasswordController.text;
    });
  }

  Future<void> _onSubmit() async {
    _validatePasswords();
    if (!passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords must match'))
      );
      return;
    }
    setState(() => _isLoading = true);

    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if ([oldPassword, newPassword, confirmPassword].any((input) => input.isEmpty)) {
      print("All fields are required");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final userState = context.read<UserBloc>().state;
    if (userState is! UserDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not loaded. Please try again later.")),
      );
      return;
    }

    final apiClient = userState.apiClient;
    try {
      print('Changing password from $oldPassword to $newPassword');
      await apiClient.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword
      );
      setState(() => _isLoading = false);
      print("API call successful");

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password Successfully Changed")),
    );
    } catch (error) {
      setState(() => _isLoading = false);
      print('API call failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password change failed: $error")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder:(context, state) {
        if (state is UserDataLoaded) {
          return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              toolbarHeight: 49,
              backgroundColor: Color(0xFFFFFFFF),
            ),
            backgroundColor: Color(0xFFFFFFFF),
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          SizedBox(width: 24),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SvgPicture.asset(
                              'assets/icons/back_button.svg',
                              width: 16,
                              height: 16,
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Text(
                            'Change Password',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF001A24)
                            )
                          ),
                          Expanded(child: SizedBox()),
                          SizedBox(width: 40),
                        ],
                      ),
                    ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 48),
                            CustomTextField(
                              labelText: "Old Password",
                              hintText: "Enter Password",
                              controller: oldPasswordController,
                              obscureText: _obscureOldPassword,
                              suffixIcon: IconButton(
                                onPressed: _toggleOldPasswordVisibility,
                                icon: Icon(
                                  _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                                )
                              ),
                            ),
                            SizedBox(height: 24,),
                            CustomTextField(
                              labelText: "New Password",
                              hintText: "Enter Password",
                              controller: newPasswordController,
                              obscureText: _obscureNewPassword,
                              suffixIcon: IconButton(
                                onPressed: _toggleNewPasswordVisibility,
                                icon: Icon(
                                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                )
                              ),
                            ),
                            SizedBox(height: 24,),
                            CustomTextField(
                              labelText: "Confirm Password",
                              hintText: "Enter Password",
                              controller: confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              onChanged: (_) => _validatePasswords(),
                              suffixIcon: IconButton(
                                onPressed: _toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                )
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
                            SizedBox(height: (MediaQuery.of(context).size.height) / 3.7),
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
                                    'Change Password',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFFFF)
                                    )
                                  ),
                                )
                              ),
                            ),
                            SizedBox(height: 24,),
                            InkWell(
                              onTap: () {
                                // Navigate to Forgot Password
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Forgot Password instead?',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000D12)
                                  )
                                ),
                              ),
                            ),
                            SizedBox(height: 64,),
                          ],
                        )
                      )
                    ],
                  ),
                  if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
                  ),
                )
                ],
              )
            )
          )
          );
        } else {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
          ));
        }
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            onChanged: onChanged,
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
              suffixIcon: suffixIcon,
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
    );
  }
}