import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internal_app/components/custom_bottom_navbar.dart';
import 'package:internal_app/features/settings/change_password_view.dart';
import 'package:internal_app/features/settings/personal_information_view.dart';
import 'package:internal_app/features/settings/support_view.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';
import 'package:internal_app/utils/navigation_helper.dart';

class SettingsView extends StatefulWidget{
  const SettingsView({super.key});
  
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>{
  int _selectedIndex = 4;

  void _onItemTapped(int index, UserDataLoaded state) {
    setState(() => _selectedIndex = index);
   // navigateToPage(context, index, state);
  }


  @override
  Widget build(BuildContext context){
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        print("Current state: $state");
        if (state is UserDataLoaded) {
          return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Color(0xFFFCFCFD),
            appBar: AppBar(
              toolbarHeight: 44,
              backgroundColor: Color(0xFFFCFCFD),
            ),
            body: Column(
              children: [
                Container(
                  color: Color(0xFFFFFFFF),
                  height: 64,
                  child: Row(
                      children: [
                        SizedBox(width: 64),
                        Expanded(child: SizedBox()),
                        Text(
                          'Settings',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF001A24)
                          )
                        ),
                        Expanded(child: SizedBox()),
                        SvgPicture.asset(
                          'assets/icons/notification.svg',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 24),
                      ],
                    ),
                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    SizedBox(height: 35),
                    Text(
                      'Personal Information',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000709)
                      )
                    ),
                    SizedBox(height: 16,),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFFEAECF0),
                          width: 1
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PersonalInformationView())
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(250),
                                  border: Border.all(
                                    width: 0.63,
                                    color: Color(0x4D000000)
                                  )
                                ),
                                child: Center(
                                  child: Text(
                                    '${state.firstName[0]}${state.lastName[0]}',
                                    style: GoogleFonts.inter(
                                      fontSize: 17.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000000)
                                    )
                                  ),
                                )
                              ),
                              SizedBox(width: 12,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.firstName} ${state.lastName}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color(0xFF344054)
                                    )
                                  ),
                                  Text(
                                    state.role,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFF667085)
                                    )
                                  ),
                                ],
                              ),
                              Expanded(child: SizedBox()),
                              SvgPicture.asset(
                                'assets/icons/back.svg'
                              )
                            ],
                          ),
                        ),
                      )
                    ),
                    SizedBox(height: 51),
                    Text(
                      'Account',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000709)
                      )
                    ),
                    SizedBox(height: 16,),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordView())
                        );
                      },
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            Text(
                              'Password and Security',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000)
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            SvgPicture.asset(
                              'assets/icons/back.svg'
                            )
                          ],
                        )
                      ),
                    ),
                    SizedBox(height: 10),   
                    Container(
                      color: Color(0xFFD0DADE),
                      height: 1
                    ), 
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SupportView())
                        );
                      },
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            Text(
                              'Send Feedback',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000)
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            SvgPicture.asset(
                              'assets/icons/back.svg'
                            )
                          ],
                        )
                      ),
                    )
                    ]
                  ),
                )
              ],
            ),
            // bottomNavigationBar: CustomBottomNavBar(
            //   selectedIndex: _selectedIndex,
            //   onItemTapped: (index) => _onItemTapped(index, state),
            //   state: state,
            // )
          ),
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