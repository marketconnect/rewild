import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'package:rewild/presentation/bottom_navigation_screen/bottom_navigation_view_model.dart';
import 'package:rewild/widgets/bottom_navigation_screen_advert_widget.dart';
import 'package:rewild/widgets/bottom_navigation_screen_cards_widget.dart';
import 'package:rewild/widgets/bottom_navigation_screen_home_widget.dart';

class BottomNavigationScreen extends StatefulWidget
    with WidgetsBindingObserver {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _widgetIndex = 0;

  Future<void> setIndex(int index) async {
    setState(() {
      _widgetIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);

    final model = context.watch<BottomNavigationViewModel>();
    final cardsNum = model.cardsNum;
    final updateCardsScreen = model.updateCardsScreen;
    final updateAdvertScreen = model.updateAdvertScreen;
    final adverts = model.adverts;
    final apiKeyExists = model.apiKeyExists;
    List<Widget> widgets = [
      const BottomNavigationScreenHomeWidget(),
      BottomNavigationScreenCardsWidget(cardsum: cardsNum),
      BottomNavigationScreenAdvertWidget(
          adverts: adverts, apiKeyExists: apiKeyExists),
    ];
    return WillPopScope(
      onWillPop: () async {
        // Do something here
        SystemNavigator.pop();
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.transparent,
            color: Theme.of(context).colorScheme.onSurface,
            activeColor: Theme.of(context).colorScheme.onSurface,
            tabBackgroundColor: Theme.of(context).colorScheme.surface,
            // selectedIndex: 0,
            onTabChange: (value) async {
              if (value == 1) {
                await updateCardsScreen();
              } else if (value == 2) {
                await updateAdvertScreen();
              } else {
                await updateCardsScreen();
                await updateAdvertScreen();
              }
              setIndex(value);
            },
            tabs: [
              GButton(
                icon: _widgetIndex == 0 ? Icons.home : Icons.home_outlined,
                padding: EdgeInsets.all(model.screenWidth * 0.02),
                text: 'Главная',
                iconColor: Theme.of(context).colorScheme.primary,
                iconActiveColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.secondary,
                activeBorder: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              GButton(
                icon: _widgetIndex == 1
                    ? Icons.local_offer
                    : Icons.local_offer_outlined,
                padding: EdgeInsets.all(model.screenWidth * 0.02),
                text: 'Товары',
                textColor: Theme.of(context).colorScheme.secondary,
                activeBorder: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                iconColor: Theme.of(context).colorScheme.primary,
                iconActiveColor: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              GButton(
                icon: _widgetIndex == 2
                    ? Icons.rocket_launch
                    : Icons.rocket_launch_outlined,
                padding: EdgeInsets.all(model.screenWidth * 0.02),
                text: 'Реклама',
                textColor: Theme.of(context).colorScheme.secondary,
                activeBorder: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                iconColor: Theme.of(context).colorScheme.primary,
                iconActiveColor: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        body: widgets[_widgetIndex],
      )),
    );
  }
}

// class _BottomNavigationBar extends StatelessWidget {
//   const _BottomNavigationBar();

//   @override
//   Widget build(BuildContext context) {
//     return GNav(
//       gap: 8,
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       color: Theme.of(context).colorScheme.onSurface,
//       activeColor: Theme.of(context).colorScheme.onSurface,
//       tabBackgroundColor: Theme.of(context).colorScheme.surface,
//       // selectedIndex: 0,
//       onTabChange: (value) => print(value),
//       tabs: const [
//         GButton(icon: Icons.home_outlined, text: 'Главная'),
//         GButton(icon: Icons.leaderboard_outlined, text: 'Карточки'),
//         GButton(icon: Icons.rocket_launch_outlined, text: 'Реклама'),
//       ],
//     );
//   }
// }
