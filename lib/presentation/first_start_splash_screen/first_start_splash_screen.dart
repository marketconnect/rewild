import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/constants/image_constant.dart';

import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/custom_image_view.dart';

class FirstStartSplashScreen extends StatefulWidget {
  const FirstStartSplashScreen({super.key});

  @override
  State<FirstStartSplashScreen> createState() => _FirstStartSplashScreenState();
}

class _FirstStartSplashScreenState extends State<FirstStartSplashScreen> {
  bool _textDone = false;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const duration = Duration(milliseconds: 70);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context)
              .colorScheme
              .primaryContainer, // Status bar color
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(children: [
          Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            CustomImageView(
              imagePath: ImageConstant.rw,
              width: screenSize.width * 0.3,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'popin',
                ),
                child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    onFinished: () => setState(() {
                          _textDone = true;
                        }),
                    animatedTexts: [
                      TyperAnimatedText(
                          "Привет! Меня зовут RW, я буду твоим личным помощником на Wildberries. ",
                          textAlign: TextAlign.start,
                          speed: duration),
                      TyperAnimatedText(
                          "Я здесь, чтобы быть в курсе всех событий и напоминать тебе обо всем, что важно и, конечно, быть внимательным к нашим 'врагам'😉.",
                          textAlign: TextAlign.start,
                          speed: duration),
                      TyperAnimatedText(
                          "Добро пожаловать в увлекательный мир Wildberries, где ты всегда под защитой RW! 🤖✨",
                          textAlign: TextAlign.start,
                          speed: duration),
                    ]),
              ),
            ),
          ]),
          if (_textDone)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.1,
              bottom: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushReplacementNamed(
                    MainNavigationRouteNames.mainNavigationScreen),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).colorScheme.primary),
                  margin: EdgeInsets.only(
                    top: screenSize.height * 0.1,
                  ),
                  child: Text(
                    "Продолжить".toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
        ]));
  }
}
