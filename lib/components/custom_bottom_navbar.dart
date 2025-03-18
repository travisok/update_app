import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:internal_app/features/updates/history_page.dart';
// import 'package:internal_app/features/updates/home.dart';
// import 'package:internal_app/features/settings/settings_view.dart';
import 'package:internal_app/features/updates/post_an_update.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final UserDataLoaded state;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: kBottomNavigationBarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          )
        )
      ),
      child: Stack(
       // alignment: Alignment.center,
       clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              currentIndex: selectedIndex,
              onTap: onItemTapped,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedItemColor: const Color(0xFF84909A),
              unselectedItemColor: const Color(0xFF84909A),
              selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      SvgPicture.asset('assets/icons/home.svg'),
                      SizedBox(height: 6),
                    ],
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      SvgPicture.asset('assets/icons/history.svg'),
                      SizedBox(height: 6),
                    ],
                  ),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: const SizedBox.shrink(), // Empty space for FAB
                  label: 'Post',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      SvgPicture.asset('assets/icons/message.svg'),
                      SizedBox(height: 6),
                    ],
                  ),
                  label: 'Message',
                ),
                BottomNavigationBarItem(
                  icon: Column(
                    children: [
                      SvgPicture.asset('assets/icons/settings.svg'),
                      SizedBox(height: 6),
                    ],
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          ),
          Positioned(
            top: -22,
            child: FloatingActionButton(
              elevation: 2,
              backgroundColor: const Color(0xFF29CFD6),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostAnUpdate(apiClient: state.apiClient),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Color(0xFF011936),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
