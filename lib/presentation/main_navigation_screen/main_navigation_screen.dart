import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

import 'package:provider/provider.dart';
import 'package:rewild/core/utils/icons_constant.dart';

import 'package:rewild/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild/presentation/main_navigation_screen/widgets/main_navigation_screen_advert_widget.dart';
import 'package:rewild/presentation/main_navigation_screen/widgets/main_navigation_screen_cards_widget.dart';
import 'package:rewild/presentation/main_navigation_screen/widgets/main_navigation_screen_home_widget.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

class MainNavigationScreen extends StatefulWidget with WidgetsBindingObserver {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _widgetIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationsAllowed();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        Navigator.of(context)
            .pushNamed(MainNavigationRouteNames.backgroundNotificationsScreen);
      },
      onDismissActionReceivedMethod: (receivedAction) async {},
      onNotificationCreatedMethod: (receivedNotification) async {},
      onNotificationDisplayedMethod: (receivedNotification) async {},
    );

    super.initState();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkNotificationsAllowed() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (isAllowed) {
      return;
    }

    if (context.mounted) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Включить уведомления?"),
                content: const Text(
                    "Пожалуйста, включите уведомления, чтобы приложение уведомляло Вас о событиях, которые Вы захотите отслеживать."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Нет")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        AwesomeNotifications()
                            .requestPermissionToSendNotifications();
                      },
                      child: const Text("Да")),
                ],
              ));
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // if (mountedCallback == null) {
    //   return;
    // }
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("app in resumed");
        await _checkNotificationsAllowed();
        break;
      case AppLifecycleState.inactive:
        debugPrint("app in inactive");
        // mountedCallback!(false);
        break;
      case AppLifecycleState.paused:
        debugPrint("app in paused");
        // mountedCallback!(false);
        break;
      case AppLifecycleState.detached:
        debugPrint("app in detached");
        // mountedCallback!(false);
        break;
      default:
        break;
    }
  }

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
