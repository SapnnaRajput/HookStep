import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import '../history_screen/history_screen.dart';
import '../home_screen/home_screen.dart';
import '../pofile_screen/pofile_screen.dart';
import '../utils/theam_manager.dart';
import 'master_page_bloc/master_page_bloc.dart';
import 'master_page_bloc/master_page_event.dart';
import 'master_page_bloc/master_page_state.dart';

class MasterPage extends StatelessWidget {
  final int? wantIndex;

  const MasterPage({Key? key, this.wantIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MasterPageBloc()..add(UpdateIndex(wantIndex ?? 1)),
      child: MasterPageView(
        wantIndex: wantIndex ?? 1,
      ),
    );
  }
}

class MasterPageView extends StatelessWidget {
  final int wantIndex;

  MasterPageView({super.key, required this.wantIndex});

  final List<Widget> widgetList = [
    // CameraPage(),
    ProfileScreen(),
    ShowCaseWidget(
      builder: (context) => HomeScreen(),
    ),
    HistoryScreen(),
    // DownloadScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: colorLight,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: wantIndex != 0
              ? LinearGradient(
                  colors: [
                    Color.fromRGBO(225, 192, 230, 100), // Start color
                    Color.fromRGBO(248, 237, 227, 100), // End color
                  ],
                  begin: Alignment.topLeft, // Gradient starting point
                  end: Alignment.bottomRight, // Gradient ending point
                )
              : LinearGradient(
                  colors: [
                    Color.fromRGBO(225, 192, 230, 0.0), // Start color
                    Color.fromRGBO(225, 192, 230, 0.0), // End color
                  ],
                  begin: Alignment.topLeft, // Gradient starting point
                  end: Alignment.bottomRight, // Gradient ending point
                ),
        ),
        // child: ClipRRect(
        //   borderRadius: BorderRadius.only(
        //     topRight: Radius.circular(width * 0.075),
        //     topLeft: Radius.circular(width * 0.075),
        //   ),
        child: BlocBuilder<MasterPageBloc, MasterPageState>(
          builder: (context, state) {
            return BottomNavigationBar(
              backgroundColor: colorBlack,
              currentIndex: state.selectedIndex,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: colorWhite,
              unselectedItemColor: colorLight,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              onTap: (index) {
                context.read<MasterPageBloc>().add(UpdateIndex(index));
              },
              selectedIconTheme: const IconThemeData(
                size: 24,
              ),
              unselectedIconTheme: IconThemeData(size: 20),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_camera_back_outlined),
                  label: "History",
                ),
              ],
            );
          },
        ),
        // ),
      ),
      body: BlocBuilder<MasterPageBloc, MasterPageState>(
        builder: (context, state) {
          return widgetList[state.selectedIndex];
        },
      ),
    );
  }
}
