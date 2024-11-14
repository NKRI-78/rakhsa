import 'package:flutter/material.dart';

import 'package:rakhsa/features/dashboard/presentation/pages/home.dart';
import 'package:rakhsa/features/pages/event/persentation/pages/list.dart';
import 'package:rakhsa/features/pages/information/presentation/pages/list.dart';
import 'package:rakhsa/features/pages/news/persentation/pages/list.dart';

import 'package:rakhsa/shared/basewidgets/dashboard/bottom_navybar.dart';
import 'package:rakhsa/shared/basewidgets/drawer/drawer.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  static GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> pages = [
    {
      'page': HomePage(globalKey: globalKey),
      'title': 'Home',
    },
    {
      'page': const InformationListPage(),
      'title': 'Informasi',
    },
    {
      'page': const NewsListPage(),
      'title': 'Berita',
    },
    {
      'page': const EventListPage(),
      'title': 'Event',
    },
  ];

  int selectedPageIndex = 0;

  @override 
  void initState() {
    super.initState();
  }

  void selectPage(int index) {
    setState(() => selectedPageIndex = index);
  }
  
  @override
  Widget build(BuildContext context) {
    debugPrint("Select $selectedPageIndex");
    return Scaffold(
      key: globalKey,
      drawer: const SafeArea(
        child: DrawerWidget()
      ),
      body: pages[selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavyBar( 
        selectedIndex: selectedPageIndex,
        showElevation: false, 
        onItemSelected: (int index) => setState(() {
          selectedPageIndex = index;
        }),
        items: [
          BottomNavyBarItem(
            icon: const Icon(
              Icons.home,
              size: 20.0,
            ),
            title: Text('Home',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717),
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.note_outlined,
              size: 20.0,
            ),
            title: Text('Informasi',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717)
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.newspaper,
              size: 20.0,
            ),
            title: Text('Berita',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717),
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.event,
              size: 20.0,
            ),
            title: Text('Event',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717),
          ),
        ],
      ),
    ); 
  }

}