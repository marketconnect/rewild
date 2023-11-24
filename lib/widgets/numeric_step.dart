import 'dart:async';

import 'package:flutter/material.dart';

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
    counter = widget.currentValue;
    print("Numeric rebuilt $counter");
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              // minus ==================================
              onTap: () {
                longPressEnd = false;
                setState(() {
                  if (widget.minValue != null && counter <= widget.minValue!) {
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
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.remove,
                      size: screenWidth * 0.05,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              '$counter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w500,
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
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.add,
                      size: screenWidth * 0.05,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
