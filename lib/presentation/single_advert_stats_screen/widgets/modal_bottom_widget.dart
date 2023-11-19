import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class ModalBottomWidgetState {
  final bool isPursued;
  final bool isActive;

  final bool trackMinBudget;
  final bool trackMinCtr;

  final int minBudget;
  final int minCtr;

  final int cpm;

  ModalBottomWidgetState(
      {required this.isPursued,
      required this.isActive,
      required this.trackMinBudget,
      required this.trackMinCtr,
      required this.minBudget,
      required this.minCtr,
      required this.cpm});

  ModalBottomWidgetState copyWith({
    bool? isPursued,
    bool? isActive,
    bool? trackMinBudget,
    bool? trackMinCtr,
    int? minBudget,
    int? minCtr,
    int? cpm,
  }) {
    return ModalBottomWidgetState(
      isPursued: isPursued ?? this.isPursued,
      isActive: isActive ?? this.isActive,
      trackMinBudget: trackMinBudget ?? this.trackMinBudget,
      trackMinCtr: trackMinCtr ?? this.trackMinCtr,
      minBudget: minBudget ?? this.minBudget,
      minCtr: minCtr ?? this.minCtr,
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

class _ModalBottomWidgetState extends State<ModalBottomWidget>
    with TickerProviderStateMixin {
  ModalBottomWidgetState? state;
  TabController? tabController;
  int index = 0;
  @override
  void initState() {
    state = widget.state;
    tabController = TabController(length: 3, vsync: this);
    tabController!.addListener(() {
      setState(() {
        index = tabController!.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
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
    final trackMinBudget = state!.trackMinBudget;
    final trackMinCtr = state!.trackMinCtr;
    final minBudget = state!.minBudget;
    final minCtr = state!.minCtr;

    final cpm = state!.cpm;

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
                title: index == 1
                    ? const Text(
                        "Уведомить, если",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
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
                bottom: TabBar(
                  isScrollable: true,
                  controller: tabController,
                  splashFactory: NoSplash.splashFactory,
                  tabs: const [
                    Tab(
                      text: "Общее",
                    ),
                    Tab(
                      text: "Уведомления",
                    ),
                    Tab(
                      text: "A/B-тест",
                    )
                  ],
                ),
              ),
              body: TabBarView(controller: tabController, children: [
                _General(
                    isActive: isActive,
                    isPursued: isPursued,
                    isActiveChangeCallback: () => setState(() {
                          state = state!.copyWith(
                            isActive: !isActive,
                          );
                        }),
                    isPursuedChangeCallback: () => setState(() {
                          state = state!.copyWith(
                            isPursued: !isPursued,
                          );
                        }),
                    cpmChangeCallback: (value) =>
                        setState(() => state = state!.copyWith(cpm: value)),
                    cpm: cpm),
                _Notifications(
                  budgetTrack: trackMinBudget,
                  ctrTrack: trackMinCtr,
                  minBudget: minBudget,
                  minCtr: minCtr,
                  budgetTrackCallback: () => setState(() {
                    state = state!.copyWith(
                      trackMinBudget: !state!.trackMinBudget,
                    );
                  }),
                  ctrTrackCallback: () => setState(() {
                    state = state!.copyWith(
                      trackMinCtr: !state!.trackMinCtr,
                    );
                  }),
                  minBudgetChangeCallback: (value) {
                    setState(() => state = state!.copyWith(minBudget: value));
                  },
                  minCtrChangeCallback: (value) {
                    setState(() => state = state!.copyWith(minCtr: value));
                  },
                ),
                Container(),
              ])),
        ),
      ),
    );
  }
}

class _General extends StatelessWidget {
  const _General(
      {required this.isActive,
      required this.isPursued,
      required this.isActiveChangeCallback,
      required this.isPursuedChangeCallback,
      required this.cpmChangeCallback,
      required this.cpm});
  final bool isActive;
  final bool isPursued;
  final VoidCallback isActiveChangeCallback;
  final VoidCallback isPursuedChangeCallback;
  final Function(int) cpmChangeCallback;
  final int cpm;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        _ModalBottomCard(
          isSwitched: isActive,
          text: isActive ? "Приостановить" : "Запустить",
          callback: () async {
            isActiveChangeCallback();
          },
        ),
        _ModalBottomCard(
          isSwitched: isPursued,
          text: isPursued ? "Завершить отслеживание" : "Отслеживать",
          callback: () async {
            isPursuedChangeCallback();
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
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            NumericStepButton(
                currentValue: cpm,
                onChanged: (value) => cpmChangeCallback(value)),
          ]),
        )
        // const _Btn()
      ]),
    );
  }
}

class _Notifications extends StatelessWidget {
  const _Notifications(
      {required this.budgetTrack,
      required this.ctrTrack,
      required this.minCtr,
      required this.minBudget,
      required this.minCtrChangeCallback,
      required this.minBudgetChangeCallback,
      required this.budgetTrackCallback,
      required this.ctrTrackCallback});
  final bool budgetTrack;

  final bool ctrTrack;
  final int minCtr;
  final int minBudget;
  final VoidCallback budgetTrackCallback;
  final VoidCallback ctrTrackCallback;
  final Function(int) minCtrChangeCallback;
  final Function(int) minBudgetChangeCallback;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          // const Row(
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.all(8.0),
          //       child: Text(
          //         "Уведомить, если:",
          //         style: TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //     )
          //   ],
          // ),
          if (budgetTrack)
            Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.015),
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Text(
                      'Бюджет кампании менее',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withOpacity(0.5),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                NumericStepButton(
                    currentValue: minBudget.toInt(),
                    onChanged: (value) => minBudgetChangeCallback(value)),
              ]),
            ),
          _ModalBottomCard(
            isSwitched: budgetTrack,
            text: budgetTrack ? "Отключить уведомление" : "Бюджет кампании",
            callback: () => budgetTrackCallback(),
          ),
          if (ctrTrack)
            Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.015),
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Text(
                      'CTR кампании менее',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withOpacity(0.5),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                NumericStepButton(
                    currentValue: minCtr.toInt(),
                    onChanged: (value) => minCtrChangeCallback(value)),
              ]),
            ),
          _ModalBottomCard(
            isSwitched: ctrTrack,
            text: ctrTrack ? "Отключить уведомление" : "CTR кампании",
            callback: () => ctrTrackCallback(),
          ),
          SizedBox(
            height: screenHeight * 0.1,
          ),
        ]),
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
  final void Function() callback;

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
                onChanged: (value) {
                  widget.callback();
                }),
          ),
        )
      ]),
    );
  }
}

class NumericStepButton extends StatefulWidget {
  final int currentValue;
  final ValueChanged<int> onChanged;
  const NumericStepButton(
      {super.key,
      this.minValue,
      this.maxValue,
      required this.onChanged,
      required this.currentValue});

  final int? minValue;
  final int? maxValue;
  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;
  bool longPressEnd = false;
  @override
  void initState() {
    super.initState();
    counter = widget.currentValue;
  }

  void _increase() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (longPressEnd) {
        timer.cancel();
        longPressEnd = false;
        return;
      }
      setState(() {
        counter += 5;
        if (widget.maxValue != null && counter >= widget.maxValue!) {
          counter = widget.maxValue!;
          return;
        }

        widget.onChanged(counter);
      });
    });
  }

  void _decrease() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (counter <= 0 || longPressEnd) {
        timer.cancel();
        longPressEnd = false;
        return;
      }
      setState(() {
        counter -= 5;
        if (widget.minValue != null && counter <= widget.minValue!) {
          counter = widget.minValue!;
          return;
        }
        if (counter <= 0) {
          counter = 0;
          return;
        }

        widget.onChanged(counter);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceVariant,
          )),
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
                // minus ==================================
                onTap: () {
                  longPressEnd = false;
                  setState(() {
                    if (widget.minValue != null &&
                        counter <= widget.minValue!) {
                      counter = widget.minValue!;
                      return;
                    }
                    if (counter <= 0) {
                      counter = 0;
                      return;
                    }

                    counter--;
                    widget.onChanged(counter);
                  });
                },
                onLongPress: () {
                  _decrease();
                },
                onLongPressEnd: (details) {
                  longPressEnd = true;
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.transparent,
                  )),
                  child: Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.05),
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      alignment: Alignment.center,
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
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  longPressEnd = false;
                  _increase();
                },
                onLongPressEnd: (details) {
                  longPressEnd = true;
                },
                onTap: () {
                  setState(() {
                    counter++;
                    widget.onChanged(counter);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.transparent,
                  )),
                  child: Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.05),
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
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
