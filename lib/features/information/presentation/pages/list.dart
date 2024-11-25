import 'package:flutter/material.dart';

import 'package:rakhsa/common/utils/asset_source.dart';

import 'package:rakhsa/features/information/presentation/widgets/list_card.dart';

class InformationListPage extends StatelessWidget {
  const InformationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 32, bottom: 10),
            child: Text(
              'Informasi apa, yang ingin anda ketahui ?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          )
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListCardInformation(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Container();
              }));
            },
            image: AssetSource.iconInfo, 
            title: "Informasi KBRI"
          ),
          ListCardInformation(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Container();
              }));
            },
            image: AssetSource.iconCard, 
            title: "Passport & VISA"
          ),
          ListCardInformation(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Container();
              }));
            },
            image: AssetSource.iconHukum, 
            title: "Panduan Hukum"
          ),
        ],
      ),
    );
  }
}