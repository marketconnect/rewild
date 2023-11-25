import 'package:flutter/material.dart';

class MyDialogSaveWidget extends StatelessWidget {
  const MyDialogSaveWidget({
    super.key,
    required this.onYesPressed,
    required this.onNoPressed,
  });

  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      buttonPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(0),
      contentPadding: EdgeInsets.zero,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Icon(
                    Icons.close,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Соранить изменения?",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.065),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              foregroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.onPrimary,
              )),
          onPressed: onYesPressed,
          child: const Text("Да"),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              foregroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.onPrimary,
              )),
          onPressed: onNoPressed,
          child: const Text("Нет"),
        ),
      ],
    );
  }
}
