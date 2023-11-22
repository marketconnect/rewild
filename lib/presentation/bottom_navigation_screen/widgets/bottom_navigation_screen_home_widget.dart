import 'package:flutter/material.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

class BottomNavigationScreenHomeWidget extends StatefulWidget {
  const BottomNavigationScreenHomeWidget({super.key});

  @override
  State<BottomNavigationScreenHomeWidget> createState() =>
      _BottomNavigationScreenHomeWidgetState();
}

class _BottomNavigationScreenHomeWidgetState
    extends State<BottomNavigationScreenHomeWidget> {
  late bool feedBackExpanded;

  @override
  void initState() {
    super.initState();
    feedBackExpanded = false;
  }

  void feedBackExpandedToggle() {
    setState(() {
      feedBackExpanded = !feedBackExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
                'Главная',
                style: TextStyle(
                    fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          child: Column(
            children: [
              const _Link(
                text: 'Уведомления',
                color: Color(0xFFfb8532),
                route: MainNavigationRouteNames.backgroundNotificationsScreen,
                iconData: Icons.share_arrival_time_outlined,
              ),
              const _Link(
                text: 'Добавить API токен',
                color: Color(0xFF41434e),
                route: MainNavigationRouteNames.apiKeysScreen,
                iconData: Icons.key,
              ),
              const _Link(
                text: 'Наш сайт',
                color: Color(0xFFf9c513),
                // route: MainNavigationRouteNames.userInfoScreen,
                route: '',
                iconData: Icons.emoji_emotions_outlined,
              ),
              _Feedback(
                click: feedBackExpandedToggle,
              ),
              !feedBackExpanded
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Напишите нам",
                                style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Пожелание в свободной форме:",
                                style: TextStyle(fontSize: screenWidth * 0.045),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Container(
                            width: screenWidth * 0.96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: TextField(
                              // controller: _controller,
                              maxLines: null, // Allows unlimited lines
                              minLines: 3,
                              decoration: InputDecoration(
                                // hintText: 'Enter your text here',
                                border: OutlineInputBorder(
                                    // borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Button action goes here
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                surfaceTintColor:
                                    Theme.of(context).colorScheme.background,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                elevation:
                                    3, // Adjust the shadow elevation as needed
                                shadowColor:
                                    Colors.grey, // Set the shadow color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(
                                  width: 1.0,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.send_sharp,
                                        size: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Отправить сообщение',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.07,
                          ),
                        ],
                      ),
                    )
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

class _Feedback extends StatelessWidget {
  const _Feedback({required this.click});
  final Function click;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => click(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context).colorScheme.background),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Color(0xFF2188ff),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.feedback_outlined,
                  color: Theme.of(context).colorScheme.background,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              "Обратная связь",
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
