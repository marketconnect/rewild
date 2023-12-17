import 'package:flutter/material.dart';
import 'package:rewild/core/constants/icons_constant.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/empty_widget.dart';

class MainNavigationScreenFeedBackWidget extends StatelessWidget {
  const MainNavigationScreenFeedBackWidget(
      {super.key, required this.apiKeyExists});
  final bool apiKeyExists;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: !apiKeyExists
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EmptyWidget(
                    text:
                        'Для работы с отзывами и вопросами WB вам необходимо добавить токен "Вопросы и отзывы"'),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(MainNavigationRouteNames.apiKeysScreen),
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.08,
                        child: Text(
                          'Добавить токен',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        )))
              ],
            ))
          : SingleChildScrollView(
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
                        'Обратная связь',
                        style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                  ),
                  child: Column(
                    children: [
                      _Link(
                        text: 'Вопросы и отзывы',
                        color: const Color(0xFF8c56ce),
                        imageSrc: IconConstant.iconQuestions,
                        route: MainNavigationRouteNames.productsFeedbackScreen,
                      ),
                      _Link(
                        text: 'Настройка уведомлений',
                        color: const Color(0xFFd2a941),
                        route:
                            MainNavigationRouteNames.feedbackNotificationScreen,
                        imageSrc: IconConstant.iconNotificationSettings,
                      ),
                    ],
                  ),
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
    required this.imageSrc,
    required this.color,
  });

  final String text;

  final String route;
  final String imageSrc;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context).colorScheme.background),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: SizedBox(
                  width: screenWidth * 0.08,
                  child: Image.asset(
                    imageSrc,
                    color: Theme.of(context).colorScheme.background,
                  ),
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
