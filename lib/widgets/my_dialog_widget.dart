import 'package:flutter/material.dart';

class MyDialog extends StatelessWidget {
  const MyDialog(
      {super.key,
      required this.addGroup,
      required this.header,
      required this.description,
      this.keyboardType,
      required this.hint,
      required this.btnText});

  final void Function(String value) addGroup;
  final String header;
  final String description;
  final String hint;
  final String btnText;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    String newGroupName = "";
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
                header,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.065),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.5),
                      fontSize: MediaQuery.of(context).size.width * 0.05),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
              child: TextField(
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.02,
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey, width: 0.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey, width: 0.0),
                  ),
                ),
                cursorColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.3),
                onChanged: (value) {
                  newGroupName = value;
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                addGroup(newGroupName);
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.of(context).pop();
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.08,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                child: Text(btnText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
