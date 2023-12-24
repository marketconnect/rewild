import 'package:flutter/material.dart';

class MyDialogSaveWidget extends StatelessWidget {
  const MyDialogSaveWidget({
    super.key,
    required this.onYesPressed,
    required this.onNoPressed,
    required this.title,
  });

  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;
  final String title;

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
                title,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.065),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => onYesPressed(),
                    child: Container(
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.all(11),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: const Text(
                        "ДА",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onNoPressed(),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      color: Theme.of(context).colorScheme.primary,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: const Text(
                        "НЕТ",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ]),
          )
        ],
      ),
      // actions: [
      //   TextButton(
      //     style: ButtonStyle(
      //         backgroundColor: MaterialStateProperty.all<Color>(
      //           Theme.of(context).colorScheme.primary,
      //         ),
      //         foregroundColor: MaterialStateProperty.all<Color>(
      //           Theme.of(context).colorScheme.onPrimary,
      //         )),
      //     onPressed: onYesPressed,
      //     child: const Text("Да"),
      //   ),
      //   SizedBox(
      //     width: MediaQuery.of(context).size.width * 0.1,
      //   ),
      //   TextButton(
      //     style: ButtonStyle(
      //         backgroundColor: MaterialStateProperty.all<Color>(
      //           Theme.of(context).colorScheme.primary,
      //         ),
      //         foregroundColor: MaterialStateProperty.all<Color>(
      //           Theme.of(context).colorScheme.onPrimary,
      //         )),
      //     onPressed: onNoPressed,
      //     child: const Text("Нет"),
      //   ),
      // ],
    );
  }
}
