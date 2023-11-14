import 'package:flutter/material.dart';

class ModalBottomWidget extends StatelessWidget {
  const ModalBottomWidget({
    super.key,
    required this.isPursued,
    required this.isActive,
  });

  final bool isPursued;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.7,
      margin: EdgeInsets.only(
        top: screenHeight * 0.01,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: const _Btn(),
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: screenWidth * 0.1,
                        height: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenWidth),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: Icon(
                          Icons.close,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  splashFactory: NoSplash.splashFactory,
                  tabs: [
                    Tab(
                      // icon: Icon(Icons.chat_bubble),
                      text: "Общее",
                    ),
                    Tab(
                      // icon: Icon(Icons.video_call),
                      text: "Уведомления",
                    ),
                    Tab(
                      // icon: Icon(Icons.settings),
                      text: "A/B-тест",
                    )
                  ],
                ),
              ),
              body: TabBarView(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    _ModalBottomCard(
                      isSwitched: isActive,
                      text: isActive ? "Приостановить" : "Запустить",
                      callback: () async {
                        print("callback");
                      },
                    ),
                    _ModalBottomCard(
                      isSwitched: isPursued,
                      text:
                          isPursued ? "Отслеживать" : "Завершить отслеживание",
                      callback: () async {
                        print("callback");
                      },
                    ),
                    // const _Btn()
                  ]),
                ),
                Container(),
                Container(),
              ])),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth,
      height: screenHeight * 0.09,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary),
      child: Text(
        "Сохранить",
        style: TextStyle(color: Theme.of(context).colorScheme.background),
      ),
    );
  }
}

class _ModalBottomCard extends StatefulWidget {
  const _ModalBottomCard(
      {required this.isSwitched, required this.callback, required this.text});

  final bool isSwitched;
  final String text;
  final Future<void> Function() callback;

  @override
  State<_ModalBottomCard> createState() => _ModalBottomCardState();
}

class _ModalBottomCardState extends State<_ModalBottomCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          widget.text,
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.8),
              fontSize: MediaQuery.of(context).size.width * 0.04,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.18,
          height: MediaQuery.of(context).size.width * 0.15,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Switch(
                value: widget.isSwitched,
                onChanged: (value) async {
                  print(value);
                  await widget.callback();
                }),
          ),
        )
      ]),
    );
  }
}
