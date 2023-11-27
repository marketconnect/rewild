import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:rewild/core/constants.dart';
import 'package:rewild/domain/entities/advert_base.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/bottom_navigation_screen_link_btn.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class MainNavigationScreenAdvertWidget extends StatelessWidget {
  const MainNavigationScreenAdvertWidget(
      {super.key,
      required this.adverts,
      required this.apiKeyExists,
      required this.callback,
      required this.balance,
      required this.budget});

  final Future<void> Function(int) callback;
  final int? balance;

  final List<Advert> adverts;
  final bool apiKeyExists;
  final Map<int, int> budget;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                        'Кампании',
                        style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.95),
                ),
                if (balance != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Баланс: $balance руб.",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                if (adverts.isNotEmpty)
                  _AllAdvertsWidget(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      // paused: paused,
                      callback: callback,
                      budget: budget,
                      adverts: adverts),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      const LinkBtn(
                        text: 'Настройки',
                        color: Color(0xFF4aa6db),
                        route: MainNavigationRouteNames.allAdvertsToolsScreen,
                        // route: '',
                        iconData: Icons.handyman,
                      ),
                      const LinkBtn(
                        text: 'Статистика',
                        color: Color(0xFFdfb446),
                        route: MainNavigationRouteNames.allAdvertsScreen,
                        iconData: Icons.auto_graph_outlined,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
    );
  }
}

class _AllAdvertsWidget extends StatelessWidget {
  const _AllAdvertsWidget({
    required this.screenWidth,
    required this.screenHeight,
    required this.callback,
    required this.adverts,
    // required this.paused,
    required this.budget,
  });

  final double screenWidth;
  final double screenHeight;
  final List<Advert> adverts;
  final Map<int, int> budget;
  // final Map<int, bool> paused;
  final Future<void> Function(int) callback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Активные',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        SizedBox(
            height: screenHeight * 0.25,
            child: ListView.builder(
                // ListView ====================================================
                itemCount: adverts.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final budget = this.budget[adverts[index].advertId];
                  final isPaused = adverts[index].status == 11;

                  final icon =
                      isPaused ? Icons.toggle_off_outlined : Icons.toggle_on;

                  return Container(
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.2,
                    padding: const EdgeInsets.all(10),
                    margin: index == 0
                        ? EdgeInsets.only(
                            right: screenWidth * 0.03, left: screenWidth * 0.05)
                        : EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.95)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  icon,
                                  size: screenWidth * 0.06,
                                  color: Theme.of(context).colorScheme.primary,
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
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: screenWidth * 0.5,
                                    child: AutoSizeText(
                                      adverts[index].name,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.05,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (budget != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Бюджет: ${budget.toString()} руб.',
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _ElevatedBtn(
                              screenWidth: screenWidth,
                              callback: callback,
                              active: !isPaused,
                              advertId: adverts[index].advertId,
                            )
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                        )
                      ],
                    ),
                  );
                })),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.95),
        ),
      ],
    );
  }
}

class _ElevatedBtn extends StatefulWidget {
  const _ElevatedBtn({
    required this.advertId,
    required this.screenWidth,
    required this.callback,
    required this.active,
  });

  final double screenWidth;
  final Future<void> Function(int) callback;
  final bool active;

  final int advertId;

  @override
  State<_ElevatedBtn> createState() => _ElevatedBtnState();
}

class _ElevatedBtnState extends State<_ElevatedBtn> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          if (isLoading) {
            return;
          }
          setState(() {
            isLoading = true;
          });

          await widget.callback(widget.advertId);

          setState(() {
            isLoading = false;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: widget.screenWidth * 0.02,
              horizontal: widget.screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(widget.screenWidth * 0.08),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                spreadRadius: 1,
                blurRadius: 1,
                offset:
                    const Offset(0, 1.5), // changes the position of the shadow
              ),
            ],
          ),
          child: Row(
            children: [
              isLoading
                  ? MyProgressIndicator(size: widget.screenWidth * 0.06)
                  : Icon(
                      widget.active ? Icons.pause_circle : Icons.play_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              SizedBox(
                width: widget.screenWidth * 0.015,
              ),
              Text(
                widget.active ? "Пауза" : "Старт",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ));
  }
}
