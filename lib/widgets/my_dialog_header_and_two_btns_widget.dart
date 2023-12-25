import 'package:flutter/material.dart';

class MyDialogHeaderAndTwoBtnsWidget extends StatelessWidget {
  const MyDialogHeaderAndTwoBtnsWidget({
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
          const _Close(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          _Title(title: title),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          _Btns(onYesPressed: onYesPressed, onNoPressed: onNoPressed)
        ],
      ),
    );
  }
}

class _Btns extends StatelessWidget {
  const _Btns({
    required this.onYesPressed,
    required this.onNoPressed,
  });

  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () => onYesPressed(),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
                width: 0.5,
              )),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text(
              "ДА",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary, fontSize: 16),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onNoPressed(),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
                width: 0.5,
              )),
            ),
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text(
              "НЕТ",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary, fontSize: 16),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.065),
        ),
      ],
    );
  }
}

class _Close extends StatelessWidget {
  const _Close();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
