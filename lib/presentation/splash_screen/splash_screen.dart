import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/image_constant.dart';

import 'package:rewild/presentation/splash_screen/splash_screen_view_model.dart';

import 'package:flutter/material.dart';
import 'package:rewild/widgets/custom_image_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.black);
    final model = context.watch<SplashScreenViewModel>();
    final reload = model.reload;

    final screenSize = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF18191d),
      statusBarBrightness: Brightness.dark,
    ));

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: GestureDetector(
          onTap: () async => await reload(),
          child: Scaffold(
              backgroundColor: const Color(0xFF18191d),
              body: Center(
                  child: CustomImageView(
                imagePath: ImageConstant.imgLogo,
                width: screenSize.width * 0.5,
                alignment: Alignment.center,
              ))),
        ),
      ),
    );
  }
}
