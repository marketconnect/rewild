import 'package:flutter/material.dart';
import 'package:rewild/widgets/numeric_step.dart';

class MutableNotificationCard extends StatefulWidget {
  const MutableNotificationCard({
    super.key,
    required this.condition,
    required this.text,
    this.currentValue,
    this.suffix,
    this.topBorder = false,
    required this.isActive,
    required this.dropNotification,
    required this.addNotification,
  });

  final int condition;
  final bool isActive;
  final bool topBorder;
  final int? currentValue;
  final String? suffix;
  final String text;
  final Function(int condition) dropNotification;
  final Function(int condition, int? value) addNotification;

  @override
  State<MutableNotificationCard> createState() =>
      _MutableNotificationCardState();
}

class _MutableNotificationCardState extends State<MutableNotificationCard> {
  int? value;

  @override
  void initState() {
    super.initState();
    value = widget.currentValue ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight * 0.11,
      decoration: BoxDecoration(
        border: widget.topBorder
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.1),
                ),
                top: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.1),
                ))
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.1),
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.15,
            child: IconButton(
              onPressed: () {
                if (!widget.isActive) {
                  widget.addNotification(widget.condition, value);
                  return;
                }
                widget.dropNotification(widget.condition);
                return;
              },
              icon: Icon(
                Icons.notifications,
                color: !widget.isActive
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary,
                size: screenWidth * 0.07,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.8),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumericStepButton(
                onChanged: (value) => setState(() {
                  this.value = value;
                  widget.addNotification(widget.condition, value);
                }),
                currentValue: value!,
              )
            ],
          ),
        ],
      ),
    );
  }
}
