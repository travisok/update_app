import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_state.dart';

class PersonalInformationView extends StatefulWidget{
  const PersonalInformationView({super.key});

  @override
  _PersonalInformationViewState createState() => _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView>{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder:(context, state) {
        if (state is UserDataLoaded) {
          return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              toolbarHeight: 49,
              backgroundColor: Color(0xFFFFFFFF),
            ),
            backgroundColor: Color(0xFFFFFFFF),
            body: Column(
              children: [
                SizedBox(
                  height: 56,
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
                      Expanded(child: SizedBox()),
                      Text(
                        'Personal Information',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF001A24)
                        )
                      ),
                      Expanded(child: SizedBox()),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 48),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(500),
                          border: Border.all(
                            width: 1.25,
                            color: Color(0x4D000000)
                          )
                        ),
                        child: Center(
                          child: Text(
                            '${state.firstName[0]}${state.lastName[0]}',
                            style: GoogleFonts.inter(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w500,
                              fontSize: 35
                            )
                          ),
                        )
                      ),
                      SizedBox(height: 16,),
                      Text(
                        '${state.firstName} ${state.lastName}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF344054)
                        ),
                      ),
                      Text(
                        state.role,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF667085)
                        ),
                      ),
                      SizedBox(height: 48,),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                            color: Color(0xFFE7EAEE)
                          )
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Name',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF3F4D5A)
                                ),
                              ),
                              Text(
                                '${state.firstName} ${state.lastName}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000)
                                )
                              )
                            ]
                          )
                        )
                      ),
                      SizedBox(height: 16,),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                            color: Color(0xFFE7EAEE)
                          )
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email Address',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF3F4D5A)
                                ),
                              ),
                              Text(
                                state.workEmail,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000)
                                )
                              )
                            ]
                          )
                        )
                      ),
                      SizedBox(height: 16,),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                            color: Color(0xFFE7EAEE)
                          )
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF3F4D5A)
                                ),
                              ),
                              Text(
                                state.role,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000)
                                )
                              )
                            ]
                          )
                        )
                      ),
                    ],
                  ),
                )
              ],
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