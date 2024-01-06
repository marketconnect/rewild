import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:rewild/widgets/bottom_navigation_screen_link_btn.dart';

class MainNavigationScreenCardsWidget extends StatelessWidget {
  const MainNavigationScreenCardsWidget({super.key, required this.cardsNumber});

  final int cardsNumber;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.1,
              ),
              Text(
                'Товары',
                style: TextStyle(
                    fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _InfoRow(
          cardsNum: cardsNumber,
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              LinkBtn(
                text: 'Карточки товаров',
                color: Color(0xFF34d058),
                route: MainNavigationRouteNames.allCardsScreen,
                iconData: Icons.card_giftcard_outlined,
              ),
              LinkBtn(
                text: 'Группы',
                color: Color(0xFF2188ff),
                route: MainNavigationRouteNames.allGroupsScreen,
                // route: '',
                iconData: Icons.account_tree_outlined,
              ),
              LinkBtn(
                text: 'Гео запросы',
                color: Color(0xFFfb8532),
                route: MainNavigationRouteNames.geoSearchScreen,
                // route: '',
                iconData: Icons.map_outlined,
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.cardsNum});

  final int cardsNum;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('$cardsNum шт',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: screenWidth * 0.1,
                fontWeight: FontWeight.bold)),
      ),
      TextButton(
          onPressed: () => Navigator.of(context)
              .pushNamed(MainNavigationRouteNames.myWebViewScreen),
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              width: screenWidth * 0.4,
              height: screenHeight * 0.08,
              child: Text(
                'Добавить',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ))),
    ]);
  }
}
