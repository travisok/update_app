import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internal_app/infrastructure/network/api/feedback_api_client.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';

class SupportView extends StatefulWidget{
  const SupportView({super.key}); 

  @override
  _SupportViewState createState() => _SupportViewState();
}


class _SupportViewState extends State<SupportView>{
  bool _isLoading = false;
  final List<String> topicOptions = ['Registration', 'Login', 'Updates', 'Settings'];
  final TextEditingController messageController = TextEditingController();
  String deviceType = 'INTERNAL_APP';
  String? topic;
  bool _isSuccessful = false;

  void _showSuccessPopup() {
    setState(() => _isSuccessful = true);
  }

  void _hideSuccessPopup() {
    setState(() => _isSuccessful = false);
  }

  Future<void> _onSubmit(String workEmail) async {
    print("Starting _onSubmit");
    String message = messageController.text;

    if (topic == null || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final apiClient = FeedbackApiClient();
    try {
      print("Attempting API call with values: $deviceType, $topic, $message");
      await apiClient.submitFeedback(
        deviceType: deviceType,
        workEmail: workEmail,
        topic: topic!,
        message: message
      );
      setState(() => _isLoading = false);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e')),
      );
    }
  }

  Widget _buildSuccessfulPopup() {
    return GestureDetector(
      onTap: _hideSuccessPopup, // Dismiss on tapping outside
      child: Container(
        color: Colors.black.withOpacity(0.5), // Background overlay
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap event propagation
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Success!',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your feedback has been submitted successfully.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _hideSuccessPopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29CFD6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
              toolbarHeight: 44,
              backgroundColor: Color(0xFFFCFCFD),
            ),
            backgroundColor: Color(0xFFFCFCFD),
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                    Container(
                      height: 56,
                      color: Colors.white,
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
                          Spacer(),
                          Text(
                            'Support',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF001A24)
                            )
                          ),
                          Spacer(),
                          SizedBox(width: 40),
                        ],
                      ),
                    ),   
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 37,),
                          Text(
                            'Need Help?',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000709)
                            )
                          ),
                          Text(
                            'Have a question or need assistance? Please fill out the form below and we\'ll get back to you as soon as possible.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF344054)
                            )
                          ),
                          SizedBox(height: 40),
                          CustomDropdownField(
                            options: topicOptions,
                            labelText: "Topic",
                            onChanged: (value) {
                              setState(() {
                                topic = value;
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          CustomTextField(
                            labelText: "Message",
                            hintText: "Write us a message",
                            controller: messageController
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height / 4.9),
                          InkWell(
                              onTap: () => _onSubmit(state.workEmail),
                              child: Container(
                                height: 51,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xFF00141B)
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Send Feedback',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFFFF)
                                    )
                                  ),
                                )
                              ),
                            ),
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
              ),
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

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
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
        TextFormField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
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
      ],
    );
  }
}

class CustomDropdownField extends StatefulWidget {
  final List<String> options;
  final String labelText;
  final Function(String)? onChanged;

  const CustomDropdownField({
    super.key,
    required this.options,
    required this.labelText,
    this.onChanged,
  });

  @override
  _CustomDropdownFieldState createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  String? selectedOption;
  bool isDropdownVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownVisible = !isDropdownVisible;
            });
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD0D5DD),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFFFFFF),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedOption ?? "-Select-",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: selectedOption == null
                      ? const Color(0xFF667085) // Hint text color
                      : const Color(0xFF000D12), // Selected text color
                ),
              ),
            ),
          ),
        ),
        if (isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD0D5DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 100,
              ),
              child: ListView(
                children: widget.options.map((option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      setState(() {
                        selectedOption = option;
                        isDropdownVisible = false;
                        if (widget.onChanged != null) {
                          widget.onChanged!(option);
                        }
                      });
                    }
                  );
                }).toList(),
              ),
            ),
          )
      ],
    );
  }
}
