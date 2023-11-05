import 'package:flutter/material.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

class BottomNavigationScreenAdvertWidget extends StatelessWidget {
  const BottomNavigationScreenAdvertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        child: Column(children: [
          Text('Adverts'),
          _Link(
            text: 'Группы',
            color: Color(0xFF2188ff),
            route: MainNavigationRouteNames.allAdvertsScreen,
            // route: '',
            iconData: Icons.group_outlined,
          ),
        ]),
      ),
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
