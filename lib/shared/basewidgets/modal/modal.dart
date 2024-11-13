import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/auth/presentation/pages/login.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class GeneralModal {


  static Future<void> logout() {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                SizedBox(
                  width: 300.0,
                  height: 380.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      Positioned(
                        left: 20.0,
                        right: 20.0,
                        bottom: 20.0,
                        child: Container(
                          height: 200.0,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          
                              Text("Apakah kamu yakin ingin keluar ?", 
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black
                                ),
                              )
                          
                            ],
                          ),
                        )
                      ),

                      Positioned(
                        bottom: 0.0,
                        left: 80.0,
                        right: 80.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [

                            Expanded(
                              child: CustomButton(
                                isBorder: false,
                                btnColor: ColorResources.white,
                                btnTextColor: ColorResources.black,
                                sizeBorderRadius: 20.0,
                                fontSize: Dimensions.fontSizeSmall,
                                isBorderRadius: true,
                                height: 40.0,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                btnTxt: "Batal",
                              ),
                            ),

                            const SizedBox(width: 10.0),

                            Expanded(
                              child: CustomButton(
                                isBorder: false,
                                btnColor: ColorResources.error,
                                btnTextColor: ColorResources.white,
                                sizeBorderRadius: 20.0,
                                fontSize: Dimensions.fontSizeSmall,
                                isBorderRadius: true,
                                height: 40.0,
                                onTap: () async {
                                  StorageHelper.removeToken();

                                  Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (BuildContext context) {
                                      return const LoginPage();
                                    })
                                  );
                                },
                                btnTxt: "Ya",
                              ),
                            )
                          ],
                        )
                      ),
                      
                    ],  
                  )
                  
                ) 
              ] 
            ),
          ),
        );
      },
    ); 
  } 

}