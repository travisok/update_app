import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internal_app/infrastructure/network/api/feedback_api_client.dart';
import 'package:internal_app/infrastructure/network/api/request_api_client.dart';
import 'package:internal_app/infrastructure/network/services/cache_helper.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';
import 'package:table_calendar/table_calendar.dart';

class RequestFormView extends StatefulWidget{
  const RequestFormView({super.key}); 

  @override
  _RequestFormViewState createState() => _RequestFormViewState();
}


class _RequestFormViewState extends State<RequestFormView>{
  bool _isLoading = false;
  final List<String> topicOptions = ['Time Off', 'Employment'];
  final TextEditingController messageController = TextEditingController();
  String deviceType = 'INTERNAL_APP';
  String? topic;
  bool _isSuccessful = false;
  bool topicTimeOff = false;
  bool? startDateIsValid;
  bool? endDateIsValid;

  DateTime? startDate;
  DateTime? endDate;

  void _showSuccessPopup() {
    setState(() => _isSuccessful = true);
  }

  void _hideSuccessPopup() {
    setState(() => _isSuccessful = false);
  }

  void isStartDateValid() {
    DateTime today = DateTime.now();
    if (startDate!.isBefore(today)) {
      //return false;
      setState(() => startDateIsValid = false);
    }
    setState(() => startDateIsValid = true);
  }

  void isEndDateValid() {
    if (endDate!.isBefore(startDate!)) {
      setState(() => endDateIsValid = false);
    }
    setState(() => endDateIsValid = true);
  }
  
  void _handleStartDateSelected(DateTime date) {
    setState(() {
      startDate = date;
      if (startDate != null) {
        isStartDateValid();
      }
    });
  }

  void _handleEndDateSelected(DateTime date) {
    setState(() {
      endDate = date;
      if (endDate != null && startDate != null) {
        isEndDateValid();
      }
    });
  }

  Future<void> _onSubmit(String workEmail) async {
    print("Starting _onSubmit");
    String message = messageController.text;

    if (topic == 'Time Off' && (startDate == null || endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    if(startDateIsValid == false || endDateIsValid == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct date errors before submitting.')),
      );
      return;
    }

    if (topic == null || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final apiClient = RequestApiClient();
    try {
      print("Attempting API call with values: $deviceType, $topic, $message, $startDate to $endDate");
      await apiClient.submitRequest(
        deviceType: deviceType,
        workEmail: workEmail,
        topic: topic!,
        message: message,
        startDate: startDate!,
        endDate: endDate!
      );
      setState(() => _isLoading = false);
      setState(() => _isSuccessful = true);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    }
  }

  Widget _buildSuccessfulPopup() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _hideSuccessPopup, // Dismiss on tapping outside
        child: Center(
          child: Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.5),
                height: MediaQuery.of(context).size.height
              ),
              Center(
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
                          'Your request has been submitted successfully.',
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
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              color: Color(0xFF000709)
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                            'Request',
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
                            'Want to Make a Request?',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000709)
                            )
                          ),
                          Text(
                            'Need to make a request about something? Please fill out the form below and we\'ll get back to you as soon as possible.',
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
                              if (topic == 'Time Off') {
                                setState(() {
                                  topicTimeOff = true;
                                });
                              } else {
                                setState(() {
                                  topicTimeOff = false;
                                });
                              }
                            },
                          ),
                          SizedBox(height: 24),
                          if (topicTimeOff)
                            Column(
                              children: [
                                CustomDatePicker(
                                  labelText:
                                  'Select Time Off Start Date',
                                  initialDate: startDate,
                                  onDateSelected: _handleStartDateSelected,
                                ),
                                if (startDateIsValid == false)
                                Column(
                                  children: [
                                    SizedBox(height: 12),
                                    Text(
                                      'Start Date cannot be before today.',
                                      style: GoogleFonts.inter(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                      )
                                    )
                                  ],
                                ),
                                SizedBox(height: 24),
                                CustomDatePicker(
                                  labelText: 'Select Time Off End Date',
                                  initialDate: endDate,
                                  onDateSelected: _handleEndDateSelected,
                                ),
                                if (endDateIsValid == false)
                                Column(
                                  children: [
                                    SizedBox(height: 12),
                                    Text(
                                      'End Date cannot be earlier than Start Date.',
                                      style: GoogleFonts.inter(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                      )
                                    )
                                  ],
                                ),
                                SizedBox(height: 24)
                              ],
                            ),
                          CustomTextField(
                            labelText: "Description",
                            hintText: "Explain your request",
                            controller: messageController
                          ),
                          SizedBox(height: topicTimeOff ? 24 : MediaQuery.of(context).size.height / 4.9),
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
                                    'Submit Request',
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
                  if(_isSuccessful)
                  _buildSuccessfulPopup(),
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

typedef DateCallback = void Function(DateTime selectedDate);

class CustomDatePicker extends StatefulWidget {
  final String labelText;
  //final Function(DateTime)? onDateSelected;
  final DateCallback onDateSelected;
  final DateTime? initialDate;

  const CustomDatePicker({
    super.key,
    required this.labelText,
    //this.onDateSelected,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime selectedDate;

  bool isCalendarVisible = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();  // Default to today if no initial date is provided
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      selectedDate = date;
      isCalendarVisible = false;
    });
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    }
  }

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
              isCalendarVisible = !isCalendarVisible;
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
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : "-Select-",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: selectedDate == null
                      ? const Color(0xFF667085) // Hint text color
                      : const Color(0xFF000D12), // Selected text color
                ),
              ),
            ),
          ),
        ),
        if (isCalendarVisible)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD0D5DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                _handleDateSelection(selectedDay);
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFFE3FDFF),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0.95, color: Color(0xFF42B8BD)),
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF29CFD6),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0.95, color: Color(0xFF19213D)),
                ),
                todayTextStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                selectedTextStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                defaultTextStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                weekendTextStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                leftChevronIcon: Icon(Icons.chevron_left,
                    color: Color(0xFF29CFD6)),
                rightChevronIcon: Icon(Icons.chevron_right,
                    color: Color(0xFF29CFD6)),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                weekendStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
