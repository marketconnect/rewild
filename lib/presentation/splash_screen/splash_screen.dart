import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/utils/image_constant.dart';
import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

import 'package:flutter/material.dart';
import 'package:rewild/widgets/custom_image_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.black);
    final _ = context.watch<SplashScreenViewModel>();

    final screenSize = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF18191d),
      statusBarBrightness: Brightness.dark,
    ));

    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color(0xFF18191d),
          body: Center(
              child: CustomImageView(
            imagePath: ImageConstant.imgLogo,
            width: screenSize.width * 0.5,
            alignment: Alignment.center,
          ))
          // SizedBox(
          //   width: double.maxFinite,
          //   child: Column(
          //     children: [
          //       SizedBox(height: screenSize.height * 0.1),
          //       CustomImageView(
          //         imagePath: ImageConstant.imgLogo,
          //         width: screenSize.width * 0.5,
          //         alignment: Alignment.center,
          //       ),
          //       SizedBox(height: screenSize.height * 0.1),
          //       CustomImageView(
          //         svgPath: ImageConstant.imgsplash,
          //         height: screenSize.height * 0.25,
          //         width: screenSize.width * 0.7,
          //       ),
          //       SizedBox(
          //         height: model.screenHeight * 0.1,
          //       ),
          //       Container(
          //         width: screenSize.width * 0.8,
          //         margin: EdgeInsets.only(
          //           left: screenSize.width * 0.1,
          //           top: screenSize.height * 0.05,
          //           right: screenSize.width * 0.1,
          //         ),
          //         child: Text(
          //           "Продавать на Wildberries  легко с ReWild",
          //           maxLines: 2,
          //           overflow: TextOverflow.ellipsis,
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //               color: Theme.of(context).colorScheme.background),
          //         ),
          //       ),
          //       SizedBox(
          //         height: model.screenHeight * 0.05,
          //       ),
          //       // Container(
          //       //   width: screenSize.width * 0.8,
          //       //   margin: EdgeInsets.only(
          //       //     left: screenSize.width * 0.1,
          //       //     top: screenSize.height * 0.05,
          //       //     right: screenSize.width * 0.1,
          //       //   ),
          //       //   child: Text(
          //       //     "Эффективная автоматизация продаж на маркетплейсах. Продавайте больше, тратьте меньше времени с нашим приложением!",
          //       //     maxLines: 4,
          //       //     overflow: TextOverflow.ellipsis,
          //       //     textAlign: TextAlign.center,
          //       //     style: TextStyle(
          //       //         fontSize: model.screenWidth * 0.04),
          //       //     // style: theme.textTheme.bodySmall!.copyWith(
          //       //     //   height: 2.12,
          //       //     // ),
          //       //   ),
          //       // ),
          //       if (!isLoading)
          //         CustomElevatedButton(
          //           onTap: () {
          //             auth();
          //           },
          //           height: screenSize.height * 0.08,
          //           text: "Connect",
          //           buttonStyle: ButtonStyle(
          //               backgroundColor: MaterialStateProperty.all(
          //                   // Theme.of(context).colorScheme.primary,
          //                   const Color(0xFF776a58)),
          //               foregroundColor: MaterialStateProperty.all(
          //                   Theme.of(context).colorScheme.onPrimary)),
          //           margin: EdgeInsets.fromLTRB(
          //               screenSize.width * 0.08,
          //               screenSize.height * 0.05,
          //               screenSize.width * 0.08,
          //               screenSize.height * 0.03),
          //         ),
          //     ],
          //   ),
          // ),
          ),
    );
  }
}
