import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internal_app/features/updates/post_an_update.dart';
import '../../infrastructure/state_managemnt/user/user_bloc.dart';
import '../../infrastructure/state_managemnt/user/user_state.dart';
import '../updates/home.dart';
import '../updates/history_page.dart';
import '../settings/settings_view.dart';
import '../../components/custom_bottom_navbar.dart';


class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    print('Item tapped: $index');
    setState(() {
      _selectedIndex = index;
    });
    print('Selected index after setState: $_selectedIndex');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserDataLoaded) {
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                Home(),
                HistoryPage(apiClient: state.apiClient),
                PostAnUpdate(apiClient: state.apiClient), // Placeholder for Post
                const SizedBox(), // Placeholder for Message
                SettingsView(),
              ],
            ),
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              state: state,
            ),
          );
        }
        // Handle other states as needed
        return const CircularProgressIndicator();
      },
    );
  }
}