import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/empty_widget.dart';

class BottomNavigationScreenAdvertWidget extends StatelessWidget {
  const BottomNavigationScreenAdvertWidget(
      {super.key,
      required this.advertsStream,
      required this.apiKeyExistsStream});

  final Stream<List<Advert>> advertsStream;
  final Stream<bool> apiKeyExistsStream;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<bool>(
        stream: apiKeyExistsStream,
        builder: (context, snapshot) {
          bool apiKeyExists = false;
          if (snapshot.hasData) {
            apiKeyExists = snapshot.data!;
          }
          return SafeArea(
            child: !apiKeyExists
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EmptyWidget(
                          text:
                              'Для работы с рекламным кабинетом WB вам необходимо добавить токен "Продвижение"'),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                              MainNavigationRouteNames.apiKeysScreen),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
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
                              'Кампании',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Активные',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      SizedBox(
                        height: screenHeight * 0.2,
                        child: StreamBuilder<List<Advert>>(
                            stream: advertsStream,
                            builder: (context, snapshot) {
                              List<Advert> adverts = [];
                              if (snapshot.hasData) {
                                adverts = snapshot.data!;
                              }
                              return ListView.builder(
                                  itemCount: adverts.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final advType = adverts[index].type;
                                    final icon = advType == 4 // catalog
                                        ? Icons.list_alt
                                        : advType == 5 // card
                                            ? Icons.card_giftcard_outlined
                                            : advType == 6 // search
                                                ? Icons.search
                                                : advType == 7
                                                    ? Icons
                                                        .rocket_launch_outlined
                                                    : advType == 8
                                                        ? Icons.auto_awesome
                                                        : Icons.two_k_outlined;
                                    return Container(
                                      width: screenWidth * 0.7,
                                      height: screenHeight * 0.2,
                                      padding: const EdgeInsets.all(10),
                                      margin: index == 0
                                          ? EdgeInsets.only(
                                              right: screenWidth * 0.03,
                                              left: screenWidth * 0.05)
                                          : EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.95)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                icon,
                                                size: screenWidth * 0.06,
                                                color: const Color(0xFF8c56ce),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.01,
                                              ),
                                              Text(
                                                  '${NumericConstants.advTypes[adverts[index].type]}',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ))
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: screenWidth * 0.5,
                                                  child: AutoSizeText(
                                                    adverts[index].name,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.05,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            }),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.95),
                      ),
                      const _Link(
                        text: 'Группы',
                        color: Color(0xFF2188ff),
                        route: MainNavigationRouteNames.allAdvertsScreen,
                        // route: '',
                        iconData: Icons.group_outlined,
                      ),
                    ]),
                  ),
          );
        });
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
