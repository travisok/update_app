import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internal_app/components/custom_bottom_navbar.dart';
import 'package:internal_app/features/settings/settings_view.dart';
import 'package:internal_app/features/updates/post_an_update.dart';
import 'package:internal_app/features/updates/history_page.dart';
import 'package:internal_app/infrastructure/network/api/api_client.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';
import 'package:internal_app/features/requests/request_form_view.dart';
import 'package:internal_app/utils/navigation_helper.dart';

class Home extends StatefulWidget {
  final int totalItems;

  const Home({super.key, this.totalItems = 0});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool showUpdates = false;

  Future<List<Map<String, dynamic>>>? updatesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  void _onItemTapped(int index, UserDataLoaded state) {
    setState(() => _selectedIndex = index);
    //navigateToPage(context, index, state);
  }

  @override
Widget build(BuildContext context) {
  return BlocBuilder<UserBloc, UserState>(
    builder: (context, state) {
      if (state is UserDataLoaded) {
        print('User data LOADED');
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              toolbarHeight: 49,
            ),
            backgroundColor: Color(0xFFFFFFFF),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 31),
                    _buildHeader(state),
                    SizedBox(height: 24),
                    Text(
                      'Hi, ${state.firstName}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'How\'s your day going?',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF667A81),
                      ),
                    ),
                    SizedBox(height: 32),
                    _buildUpdateSummary(state),
                    SizedBox(height: 32),
                    _buildPostAnUpdateButton(context),
                  ],
                ),
              ),
            ),
            // bottomNavigationBar: CustomBottomNavBar(
            //   selectedIndex: _selectedIndex,
            //   onItemTapped: (index) => _onItemTapped(index, state),
            //   state: state,
            // ),
          ),
        );
      } else if (state is UserLoading) {
        print('User data LOADING');
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
          ),
        );
      } else {
        print('User data DID NOT LOAD');
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29CFD6)),
          ),
        );
      }
    },
  );
}

// Header widget
Widget _buildHeader(UserDataLoaded state) {
  return Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(38.4),
          border: Border.all(width: 1, color: Color(0xFF29CFD6)),
        ),
        child: Center(
          child: Text(
            '${state.firstName[0]}${state.lastName[0]}',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
        ),
      ),
      Spacer(),
      Text(
        'Home',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF001A24),
        ),
      ),
      Spacer(),
      SvgPicture.asset(
        'assets/icons/notification.svg',
        width: 24,
        height: 24,
        fit: BoxFit.cover,
      ),
    ],
  );
}

// Update Summary widget
Widget _buildUpdateSummary(UserDataLoaded state) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(width: 1, color: Color(0x14000000)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Summary',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF024355),
          ),
        ),
        SizedBox(height: 17.6),
        Text(
          'Posted Updates',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF667A81),
          ),
        ),
        SizedBox(height: 6),
        Text(
          widget.totalItems.toString(),
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000709),
          ),
        ),
        SizedBox(height: 19),
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(apiClient: state.apiClient),
                  ),
                );
              },
              child: Text(
                'VIEW UPDATES',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000709),
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestFormView(),
                  ),
                );
              },
              child: Text(
                'MAKE A REQUEST',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000709),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Post an Update button
Widget _buildPostAnUpdateButton(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostAnUpdate(
            apiClient: RepositoryProvider.of<ApiClient>(context),
          ),
        ),
      );
    },
    child: Container(
      height: 51,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFF00141B),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Post An Update',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    ),
  );
}

}
