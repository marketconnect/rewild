import 'package:flutter/material.dart';

class UnmutableNotificationCard extends StatelessWidget {
  const UnmutableNotificationCard({
    super.key,
    required this.condition,
    required this.text,
    this.currentValue,
    this.suffix,
    required this.saveState,
    required this.dropNotification,
    required this.addNotification,
  });

  final int condition;
  final int saveState;
  final String? currentValue;
  final String? suffix;
  final String text;
  final Function(int condition) dropNotification;
  final Function(int condition, int? value, [bool? reusable]) addNotification;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight * 0.11,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
          ),
          top: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
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
                if (saveState == 0) {
                  currentValue == null
                      ? addNotification(condition, null)
                      : addNotification(condition, int.tryParse(currentValue!));
                  return;
                } else if (saveState == 1) {
                  currentValue == null
                      ? addNotification(condition, null, true)
                      : addNotification(
                          condition, int.tryParse(currentValue!), true);
                } else if (saveState == 2) {
                  dropNotification(condition);
                  return;
                }
              },
              icon: Icon(
                Icons.notifications,
                color: saveState == 0
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
                text,
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
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "$currentValue${suffix ?? ""}",
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
