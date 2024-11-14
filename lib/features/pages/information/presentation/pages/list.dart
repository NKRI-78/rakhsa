import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/assets_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/pages/information/presentation/widgets/list_card.dart';

class InformationListPage extends StatelessWidget {
  const InformationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        leading: const Icon(
          Icons.arrow_back_ios_new,
          size: 30,
        ),
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
            onTap: () {},
            image: AssetSource.iconInfo, 
            title: "Informasi KBRI"
          ),
          ListCardInformation(
            onTap: () {},
            image: AssetSource.iconCard, 
            title: "Passport & VISA"
          ),
          ListCardInformation(
            onTap: () {},
            image: AssetSource.iconHukum, 
            title: "Panduan Hukum"
          ),
        ],
      ),
    );
  }
}