import 'package:flutter/material.dart';
import 'package:rewild/core/constants/image_constant.dart';

import 'package:rewild/widgets/empty_widget.dart';

enum ErrorType {
  network,
}

class AlertWidget extends StatelessWidget {
  const AlertWidget({
    super.key,
    required this.errorType,
  });
  final ErrorType errorType;

  @override
  Widget build(BuildContext context) {
    String? text;
    String? img;
    switch (errorType) {
      case ErrorType.network:
        text = 'Нет соединения с интернетом';
        img = ImageConstant.noConnection;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: EmptyWidget(text: text, img: img),
      ),
    );
  }
}
