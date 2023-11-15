// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class ModalBottomWidgetState {
  final bool isPursued;
  final bool isActive;
  final int cpm;
  ModalBottomWidgetState(
      {required this.isPursued, required this.isActive, required this.cpm});

  ModalBottomWidgetState copyWith({
    bool? isPursued,
    bool? isActive,
    int? cpm,
  }) {
    return ModalBottomWidgetState(
      isPursued: isPursued ?? this.isPursued,
      isActive: isActive ?? this.isActive,
      cpm: cpm ?? this.cpm,
    );
  }
}

class ModalBottomWidget extends StatefulWidget {
  const ModalBottomWidget({
    super.key,
    required this.state,
    required this.saveCallback,
  });

  final ModalBottomWidgetState state;
  final void Function(ModalBottomWidgetState) saveCallback;

  @override
  State<ModalBottomWidget> createState() => _ModalBottomWidgetState();
}

class _ModalBottomWidgetState extends State<ModalBottomWidget> {
  ModalBottomWidgetState? state;

  @override
  void initState() {
    state = widget.state;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (state == null) {
      return const MyProgressIndicator();
    }
    final isPursued = state!.isPursued;
    final isActive = state!.isActive;

    callBack() {
      widget.saveCallback(state!);
    }

    return Container(
      height: screenHeight * 0.8,
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
              floatingActionButton: _Btn(callBack),
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
                        setState(() {
                          state = state!.copyWith(
                            isActive: !isActive,
                          );
                        });
                      },
                    ),
                    _ModalBottomCard(
                      isSwitched: isPursued,
                      text:
                          isPursued ? "Завершить отслеживание" : "Отслеживать",
                      callback: () async {
                        setState(() {
                          state = state!.copyWith(
                            isPursued: !isPursued,
                          );
                        });
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.015),
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.05,
                                ),
                                Text(
                                  'Управление ставкой (СРМ, ₽)',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withOpacity(0.8),
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenHeight * 0.01,
                            ),
                            NumericStepButton(
                              currentValue: state!.cpm,
                              onChanged: (value) => setState(
                                  () => state = state!.copyWith(cpm: value)),
                            )
                          ]),
                    )
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
  const _Btn(this.saveCallback);
  final void Function() saveCallback;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        saveCallback();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Container(
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
                  await widget.callback();
                }),
          ),
        )
      ]),
    );
  }
}

class NumericStepButton extends StatefulWidget {
  // final int minValue;
  // final int maxValue;
  final int currentValue;

  final ValueChanged<int> onChanged;

  const NumericStepButton(
      {super.key,
      // required this.minValue,
      // required this.maxValue,
      required this.onChanged,
      required this.currentValue});

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;
  @override
  void initState() {
    super.initState();
    counter = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceVariant,
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$counter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      counter--;
                      widget.onChanged(counter);
                    });
                  },
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Icon(
                      Icons.remove,
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      counter++;

                      widget.onChanged(counter);
                    });
                  },
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Icon(
                      Icons.add,
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
