import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';

class BottomNavigationScreenCardsWidget extends StatelessWidget {
  const BottomNavigationScreenCardsWidget(
      {super.key, required this.cardsNumberStream});

  final Stream<int> cardsNumberStream;
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
        StreamBuilder<int>(
            stream: cardsNumberStream,
            builder: (context, snapshot) {
              int cardsum = 0;
              if (snapshot.hasData) {
                cardsum = snapshot.data!;
              }
              return _InfoRow(
                cardsNum: cardsum,
              );
            }),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              _Link(
                text: 'Карточки товаров',
                color: Color(0xFF34d058),
                route: MainNavigationRouteNames.allCardsScreen,
                iconData: Icons.card_giftcard_outlined,
              ),
              _Link(
                text: 'Группы',
                color: Color(0xFF2188ff),
                route: MainNavigationRouteNames.allGroupsScreen,
                // route: '',
                iconData: Icons.account_tree_outlined,
              ),
              // _Link(
              //     text: 'Продавцы',
              //     color: Color(0xFF6f42c1),
              //     route: MainNavigationRouteNames.allSellersScreen,
              //     // route: '',
              //     iconData: Icons.man),
              // _Link(
              //   text: 'Поставки',
              //   color: Color(0xFF9194a1),
              //   // route: MainNavigationRouteNames.addApiTokenScreen,
              //   route: '',
              //   iconData: Icons.local_shipping_outlined,
              // ),
              // _Link(
              //   text: 'Ваши пожелания',
              //   color: Color(0xFF41434e),
              //   // route: MainNavigationRouteNames.addApiTokenScreen,
              //   route: '',
              //   iconData: Icons.message_outlined,
              // ),
            ],
          ),
        )
      ]),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.text,
    required this.route,
    required this.iconData,
    required this.color,
  });

  final String text;

  final String route;
  final IconData iconData;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  iconData,
                  color: Theme.of(context).colorScheme.background,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
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
