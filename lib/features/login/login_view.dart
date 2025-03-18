import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internal_app/features/registration/registration_view.dart';
import 'package:internal_app/features/updates/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internal_app/infrastructure/network/api/api_client.dart';
import 'package:internal_app/infrastructure/network/services/cache_helper.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_event.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';

import '../../utils/navigation_helper.dart';

class LoginView extends StatefulWidget{
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}


class _LoginViewState extends State<LoginView>{
  bool _obscureText = true;
  bool _isLoading = false;
  final _workEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _apiClient = ApiClient();
  late String firstName;
  late String lastName;
  late String userId;
  late String role;

  @override
  void initState() {
    super.initState();
    CacheHelper.init();
  }

  void _togglePasswordVisibility () {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showNotification(String message, Color color) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}  

//   Future<void> _onSubmit() async {
//   if (_workEmailController.text.isEmpty || _passwordController.text.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please fill all fields")),
//     );
//     return;
//   }

//   String getErrorMessage(Exception e) {
//   if (e.toString().contains('401')) {
//     return 'Incorrect email or password.';
//   } else if (e.toString().contains('Network')) {
//     return 'Network error. Please try again.';
//   }
//   return 'Something went wrong. Please try later.';
// }

//   context.read<UserBloc>().add(
//         LoadUserDataEvent(
//           workEmail: _workEmailController.text,
//           password: _passwordController.text,
//         ),
//       );

//   if (mounted) {
//     _showNotification('Login successful!', Colors.green);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => BlocProvider.value(
//           value: context.read<UserBloc>(),
//           child: Home(),
//         )
//       )
//     );
//   } else {
//     _showNotification(getErrorMessage(e as Exception), Colors.red);
//     setState(() => _isLoading = false);
//     print("API call failed");

//   }

  
// }

Future<void> _onSubmit() async {
  if (_workEmailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  String getErrorMessage(Exception e) {
    if (e.toString().contains('400')) {
      return 'Incorrect email or password.';
    } else if (e.toString().contains('connection')) {
      return 'Network error. Please try again.';
    }
    return 'Something went wrong. Please try later.';
  }

  setState(() => _isLoading = true); // Show loading indicator

  try {
    final userBloc = context.read<UserBloc>();
    userBloc.add(
      LoadUserDataEvent(
        workEmail: _workEmailController.text,
        password: _passwordController.text,
      ),
    );

    final loginResult = await userBloc.stream.firstWhere((state) => 
      state is UserDataLoaded || state is UserError);

    setState(() => _isLoading = false); // Hide loading indicator

    if (loginResult is UserDataLoaded) {
      _showNotification('Login successful!', Colors.green);
      if (mounted) {
        navigateToMainScaffold(
          context,
          // MaterialPageRoute(
          //   builder: (_) => BlocProvider.value(
          //     value: userBloc,
          //     child: Home(),
          //   ),
          // ),
        );
      }
    } else if (loginResult is UserError) {
      _showNotification(getErrorMessage(Exception(loginResult.message)), Colors.red);
    }
  } catch (e) {
    setState(() => _isLoading = false); // Hide loading indicator
    _showNotification(getErrorMessage(e as Exception), Colors.red);
    print("API call failed");
  }
}


  @override
  Widget build(BuildContext context){
    final theme = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500
    );
    
     return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          toolbarHeight: 49,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    SizedBox(height: 40),
                    SvgPicture.asset(
                      'assets/icons/synergyy_icon.svg',
                      width: 31.66,
                      height: 32
                    ),
                    Text('Welcome Back', style: theme.copyWith(fontSize: 24)),
                    Text('Log into your account', style: theme.copyWith(fontSize: 18)),
                    SizedBox(height: 40),
                    _buildTextField(
                      label: 'Work email',
                      controller: _workEmailController,
                      hintText: 'Work email'
                    ),
                        SizedBox(height: 24),
                    _buildTextField(
                      label: 'Password', 
                      controller: _passwordController, 
                      hintText: 'Password',
                      obscureText: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      )
                    ),
                        SizedBox(height: (MediaQuery.of(context).size.width) / 3.16),
                    _buildSubmitButton(),
                      SizedBox(height: 18),
                    _buildFooter()
                  ],
                ),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
                  ),
                )
            ],
          ),
        )
      ),
      
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF667085),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF29CFD6)),
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSubmitButton() {
    return InkWell(
      onTap: _onSubmit,
      child: Container(
        height: 51,
        decoration: BoxDecoration(
          color: const Color(0xFF00141B),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          'Log In',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.inter(fontSize: 16),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegistrationView()),
            );
          },
          child: Text(
            'Create an Account',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF42B8BD),
            ),
          ),
        ),
      ],
    );
  }
}