import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

import 'package:provider/provider.dart';
import 'package:rewild/core/utils/icons_constant.dart';

import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/widgets/main_navigation_screen_advert_widget.dart';
import 'package:rewild/presentation/main_navigation_screen/widgets/main_navigation_screen_cards_widget.dart';
import 'package:rewild/presentation/main_navigation_screen/widgets/main_navigation_screen_home_widget.dart';

class MainNavigationScreen extends StatefulWidget with WidgetsBindingObserver {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _widgetIndex = 0;

  Future<void> setIndex(int index) async {
    setState(() {
      _widgetIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);

    final model = context.watch<MainNavigationViewModel>();

    final adverts = model.adverts;
    final apiKeyExists = model.apiKeyExists;
    final cardsNumber = model.cardsNumber;
    final budget = model.budget;
    final callback = model.changeAdvertStatus;
    final balance = model.balance;
    final paused = model.paused;

    List<Widget> widgets = [
      const MainNavigationScreenHomeWidget(),
      MainNavigationScreenCardsWidget(
        cardsNumber: cardsNumber,
      ),
      Container(),
      MainNavigationScreenAdvertWidget(
        adverts: adverts,
        balance: balance,
        apiKeyExists: apiKeyExists,
        callback: callback,
        paused: paused,
        budget: budget,
      )
    ];
    return WillPopScope(
      onWillPop: () async {
        // Do something here
        SystemNavigator.pop();
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _widgetIndex,
            backgroundColor: Theme.of(context).colorScheme.surface,
            type: BottomNavigationBarType.fixed,
            onTap: (value) async {
              setIndex(value);
              if (value == 3) {
                await model.updateAdverts();
              }
            },
            selectedLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold),
            items: [
              buildBottomNavigationBarItem(
                  IconConstant.iconHome, 'Главная', _widgetIndex == 0),
              buildBottomNavigationBarItem(
                  IconConstant.iconProduct, 'Товары', _widgetIndex == 1),
              buildBottomNavigationBarItem(
                  IconConstant.iconTestimonial, 'Вопросы', _widgetIndex == 2),
              buildBottomNavigationBarItem(
                  IconConstant.iconRocket, 'Реклама', _widgetIndex == 3),
            ],
          ),
        ),
        body: widgets[_widgetIndex],
      )),
    );
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
      String imageSrc, String label, bool isActive) {
    return BottomNavigationBarItem(
        icon: SizedBox(
          width: MediaQuery.of(context).size.width * 0.07,
          height: MediaQuery.of(context).size.width * 0.07,
          child: Image.asset(
            imageSrc,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        label: label);
  }
}
