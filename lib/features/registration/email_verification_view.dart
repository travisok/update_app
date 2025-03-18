import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internal_app/features/login/login_view.dart';
import 'package:internal_app/infrastructure/network/api/api_client.dart';


class EmailVerificationView extends StatefulWidget{
  final String workEmail;

  const EmailVerificationView({super.key, required this.workEmail});

  @override
  _EmailVerificationViewState createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final ValueNotifier<int> _countdownNotifier = ValueNotifier(60);
  final ValueNotifier<bool> _isOtpResendClickable = ValueNotifier(false);
  final ValueNotifier<bool> _otpComplete = ValueNotifier(false);
  String _otpCode = '';
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownNotifier.dispose();
    _isOtpResendClickable.dispose();
    _otpComplete.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownNotifier.value = 60;
    _isOtpResendClickable.value = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNotifier.value > 0) {
        _countdownNotifier.value--;
      } else {
        timer.cancel();
        _isOtpResendClickable.value = true;
      }
    });
  }
  

  void _resendOtp() {
    if (_isOtpResendClickable.value) {
      print("OTP resent");
      _startCountdown();
    }
  }

  Future<void> _onSubmit() async {
    print("Starting _onSubmit with OTP: $_otpCode");

    if ([widget.workEmail, _otpCode].any((input) => input.isEmpty)) {
      print("All fields are required");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final apiClient = RepositoryProvider.of<ApiClient>(context);

    try {
      print("Attempting API call with values:, $_otpCode");
       await apiClient.verifyEmail(
      workEmail: widget.workEmail, 
      otpCode: _otpCode
    );
    print("API call successful, navigating to Login");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email Successfully Verified")),
    );

    await Future.delayed(Duration(seconds: 1
    ));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView())
    );
    } catch (error) {
      print("API call failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          toolbarHeight: 49,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 23),
                _buildIcon(),
                SizedBox(height: 12),
                _buildTitle(),
                SizedBox(height: 6,),
                _buildSubtitle(),
                SizedBox(height: (MediaQuery.of(context).size.height) / 8.04),
                _buildOtpPrompt(),
                SizedBox(height: 32),
                //OTP Box
                OTPInput(
                  onOtpCompleteChanged: (isComplete) => _otpComplete.value = isComplete,
                  onOtpCodeChanged: (code) => _otpCode = code,
                ),
                SizedBox(height: 29),
                _buildResendOtp(),
                SizedBox(height: (MediaQuery.of(context).size.height) / 3.62),
                _buildVerifyButton(),
                SizedBox(height: (MediaQuery.of(context).size.height) / 12.06),
              ],
            ),
          ),
        )
      )
    );
  }

  Widget _buildIcon() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0x12A8F9FF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: SvgPicture.asset(
          'assets/icons/mail_line.svg',
          width: 24,
          height: 24,
          fit: BoxFit.scaleDown,
        ),
      );

  Widget _buildTitle() => Text(
        'Email Verification',
        style: GoogleFonts.inter(
          color: const Color(0xFF101828),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _buildSubtitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We sent a verification code to ',
            style: GoogleFonts.inter(
              color: const Color(0xFF334D57),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4,),
          Text(
            widget.workEmail,
            style: GoogleFonts.inter(
              color: const Color(0xFF334D57),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  Widget _buildOtpPrompt() => Align(
        alignment: Alignment.center,
        child: Text(
          'Enter verification code.',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF334D57),
          ),
        ),
      );


  Widget _buildResendOtp() => GestureDetector(
        onTap: _resendOtp,
        child: Align(
          alignment: Alignment.center,
          child: ValueListenableBuilder<int>(
            valueListenable: _countdownNotifier,
            builder: (context, countdown, child) {
              return RichText(
                text: TextSpan(
                  text: 'Resend OTP',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: countdown > 0
                        ? const Color(0xFF99A6AB)
                        : const Color(0xFF42B8BD),
                  ),
                  children: countdown > 0
                      ? [
                          TextSpan(
                            text: ' ($countdown s)',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF667A81),
                            ),
                          ),
                        ]
                      : [],
                ),
              );
            },
          ),
        ),
      );

  Widget _buildVerifyButton() => GestureDetector(
        onTap: _onSubmit,
        child: ValueListenableBuilder<bool>(
          valueListenable: _otpComplete,
          builder: (context, otpComplete, child) {
            return Container(
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: otpComplete ? const Color(0xFF00141B) : const Color(0x8000141B),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Verify',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            );
          },
        ),
      );

}

class OTPInput extends StatefulWidget {
  final int length;
  final double boxWidth;
  final double boxHeight;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final Color fillColor;
  final TextStyle textStyle;
  final Function(bool) onOtpCompleteChanged;
  final Function(String) onOtpCodeChanged;

  const OTPInput({super.key, 
    this.length = 6,
    this.boxWidth = 44.8,
    this.boxHeight = 44.8,
    this.borderColor = const Color(0xFFD0D5DD),
    this.borderRadius = 6.4,
    this.borderWidth = 0.8,
    this.fillColor = Colors.white,
    this.textStyle = const TextStyle(
      fontSize: 19.2,
      fontWeight: FontWeight.w700,
      color: Color(0xFF000709),
    ),
    required this.onOtpCompleteChanged,
    required this.onOtpCodeChanged
  });

  @override
  _OTPInputState createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  List<TextEditingController> controllers = [];
  ValueNotifier<bool> isOtpComplete = ValueNotifier(false);
  String otpCode = "";
  List<FocusNode> focusNodes = [];

  // String getOtpCode() {
  //   return controllers.map((controller) => controller.text).join();
  // }


  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    isOtpComplete.dispose();
    super.dispose();
  }

  void _checkOtpComplete() {
    otpCode = controllers.map((controller) => controller.text).join();
    bool allFilled = otpCode.length == widget.length;
    isOtpComplete.value = allFilled;
    widget.onOtpCompleteChanged(allFilled);
    widget.onOtpCodeChanged(otpCode);
  }

  @override
  Widget build(BuildContext context) {
    if (controllers.isEmpty || focusNodes.isEmpty) return SizedBox();

    return ValueListenableBuilder<bool>(
      valueListenable: isOtpComplete,
      builder: (context, otpComplete, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Container(
              width: widget.boxWidth,
              height: widget.boxHeight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Color(0xFF29CFD6),
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: widget.textStyle,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: widget.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: widget.borderWidth,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: widget.borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    borderSide: BorderSide(
                      color: Color(0xFF29CFD6), // Customize focus color if needed
                      width: widget.borderWidth,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < widget.length - 1) {
                    FocusScope.of(context).nextFocus(); // Move to the next box
                  }
                 _checkOtpComplete();
                },
                onFieldSubmitted: (_) {
                  _checkOtpComplete();
                },
                onEditingComplete: () {
                  _checkOtpComplete();
                },
              ),
            );
          }),
        );
      }
    );
  }
}