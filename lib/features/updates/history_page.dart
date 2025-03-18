import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internal_app/components/custom_bottom_navbar.dart';
import 'package:internal_app/features/settings/settings_view.dart';
import 'package:internal_app/features/updates/home.dart';
import 'package:internal_app/features/updates/post_an_update.dart';
import 'package:internal_app/infrastructure/network/models/user_update.dart';
import 'package:internal_app/infrastructure/network/services/cache_helper.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';
import 'package:internal_app/utils/navigation_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:internal_app/infrastructure/network/api/api_client.dart';

class HistoryPage extends StatefulWidget {
  final ApiClient apiClient;

  const HistoryPage({required this.apiClient, super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingTodayUpdates = true;
  List<UserUpdate> _updates = [];
  List<UserUpdate> _todayUpdates = [];
 // late String userId;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    CacheHelper.init();

    // Defer the state lookup to the widget tree phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBloc = BlocProvider.of<UserBloc>(context);
      final currentState = userBloc.state;

      if (currentState is UserDataLoaded) {
        _loadTodayUpdates(DateTime.now());
      }
    });
  }

  void _onItemTapped(int index, UserDataLoaded state) {
    setState(() => _selectedIndex = index);
    //navigateToPage(context, index, state);
  }

  void _loadTodayUpdates(DateTime date) async {
  final apiClient = RepositoryProvider.of<ApiClient>(context);
  try {
    final updates = await apiClient.getUpdates(dateOfUpdate: date);
    setState(() {
      _todayUpdates = updates;
    });
    //print(updates.map((e) => e.toJson()).toList());

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch today\'s updates. Please try again.')),
    );
  } finally {
    setState(() {
      _isLoadingTodayUpdates = false;
    });
  }
}


  void _handleDateSelection(DateTime date) async {
  print('Date selected: $date');
  final apiClient = RepositoryProvider.of<ApiClient>(context);
  setState(() => _isLoading = true);

  try {
    final userDetails = CacheHelper.getUserDetails();
    print("User details from cache: $userDetails");

    final userId = CacheHelper.getUserID();
    print('Retrieved userId: $userId');
    if (userId == null) {
      throw Exception("User ID not found.");
    }

    print('Fetching updates with date: $date and userId: $userId');

    final updates = await apiClient.getUpdates(
      dateOfUpdate: date,
      userId: userId,
    );
    print('API response: $updates');
    setState(() => _updates = updates);
  } catch (e) {
    print('Error fetching updates: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch updates. Please try again.')),
    );
  } finally {
    setState(() => _isLoading = false);
    print('Loading finished');
  }
}


  Widget _buildUpdateTile(String title, String? content) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$title: ${content ?? "N/A"}',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserDataLoaded) {
            return Scaffold(
            backgroundColor: Color(0xFFFFFFFF),
            appBar: AppBar(
              title: Text(
                'Explore',
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Expandable Container
                    ExpansionTile(
                      title: Text(
                        'View Your Past Updates',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      children: [
                        Text(
                        'Select a Date',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                        SizedBox(height: 8),
                        TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(selectedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              selectedDate = selectedDay;
                              this.focusedDay = focusedDay;
                            });
                            print('Selected Date: $selectedDate, Focused Date: $focusedDay');
                            _handleDateSelection(selectedDate);
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Color(0xFFE3FDFF),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 0.95, color: Color(0xFF42B8BD)),
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Color(0xFF29CFD6),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 0.95, color: Color(0xFF19213D)),
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
                      ],
                    ),
                    SizedBox(height: 16),
                    // Updates Display
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
                      ))
                    else if (_updates.isEmpty)
                      Center(
                        child: Text(
                          'No updates found for the selected date.',
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                      )
                    else
                      ..._updates.map((update) {
                        return Container(
                          width: double.infinity,
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildUpdateTile('Yesterday\'s Update',
                                      (update).yesterdayUpdate),
                                  _buildUpdateTile('Today\'s Update',
                                      (update).todayUpdate),
                                  _buildUpdateTile(
                                      'Blockers', (update).blockers),
                                  _buildUpdateTile(
                                      'Tags',
                                      ((update).tagsChosen as List?)
                                              ?.join(', ') ??
                                          'None'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    SizedBox(height: 16),
                    Text(
                      'Today\'s Updates from the Team',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                    ),
                    SizedBox(height: 16),
                    _isLoadingTodayUpdates
                        ? Center(child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
                        ))
                        : _todayUpdates.isEmpty
                            ? Center(
                                child: Text(
                                  'No updates found for today.',
                                  style: GoogleFonts.inter(fontSize: 16),
                                ),
                              )
                            : Column(
                                children: _todayUpdates.map((update) {
                                  return Container(
                                    width: double.infinity,
                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                    '${(update).staffFirstName ?? 'Unknown'} ${(update).staffLastName ?? ''}\'s Updates!',
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000709)
                                    ),
                                                                    ),
                                                                    SizedBox(height: 6),
                                            _buildUpdateTile(
                                                'Yesterday\'s Update',
                                                (update).yesterdayUpdate),
                                            _buildUpdateTile('Today\'s Update',
                                                (update).todayUpdate),
                                            _buildUpdateTile('Blockers',
                                                (update).blockers),
                                            _buildUpdateTile(
                                                'Tags',
                                                ((update).tagsChosen
                                                            as List?)
                                                        ?.join(', ') ??
                                                    'None'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                  ],
                ),
              ),
            ),
            // bottomNavigationBar: CustomBottomNavBar(
            //   selectedIndex: _selectedIndex,
            //   onItemTapped: (index) => _onItemTapped(index, state),
            //   state: state,
            // )
            );
          }  else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
              ),
            );
          }
        },
      ),
    );
  }
}
