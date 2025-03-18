import 'package:flutter/material.dart';
import 'package:internal_app/features/updates/history_page.dart';
import 'package:internal_app/features/updates/home.dart';
import 'package:internal_app/features/settings/settings_view.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';

import '../features/main/main_scaffold.dart';



// void navigateToPage(BuildContext context, int index, UserDataLoaded state) {
//   switch (index) {
//     case 0:
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BlocProvider.value(
//             value: context.read<UserBloc>(),
//             child: Home()
//           )
//         ),
//       );
//       break;
//     case 1:
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BlocProvider.value(
//             value: context.read<UserBloc>(),
//             child: HistoryPage(apiClient: state.apiClient)
//           ),
//         ),
//       );
//       break;
//     case 3:
//       // Add logic if needed
//       break;
//     case 4:
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BlocProvider.value(
//             value: context.read<UserBloc>(),
//             child: SettingsView()
//           )
//         ),
//       );
//       break;
//   }
// }

void navigateToMainScaffold(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: context.read<UserBloc>(),
        child: const MainScaffold(),
      ),
    ),
  );
}