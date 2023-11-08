import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/utils/image_constant.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          ImageConstant.imgNotFound,
          height: screenHeight * 0.2,
          width: screenWidth * 0.5,
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        SizedBox(
          width: screenWidth * 0.8,
          child: AutoSizeText(
            text,
            maxLines: 4,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ));
  }
}
