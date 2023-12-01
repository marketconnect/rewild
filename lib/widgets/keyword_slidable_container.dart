import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/utils/icons_constant.dart';

class CardContent {
  final String word;
  final int dif;
  final bool isNew;
  final int? qty;

  CardContent(
      {required this.dif, required this.isNew, required this.word, this.qty});
}

class SlidableContainer extends StatelessWidget {
  const SlidableContainer({
    super.key,
    required this.displayedContent,
  });

  final CardContent displayedContent;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: [
      Container(
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ))),
        child: Row(
          children: [
            if (displayedContent.qty != null)
              Container(
                width: MediaQuery.of(context).size.width * 0.02,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Expanded(
              flex: displayedContent.qty != null ? 7 : 9,
              child: AutoSizeText(
                displayedContent.word,
                maxLines: 4,
              ),
            ),
            Expanded(flex: 1, child: Container()),
            if (displayedContent.qty != null)
              Expanded(
                flex: 2,
                child: AutoSizeText('${displayedContent.qty}'),
              ),
            if (displayedContent.qty == null)
              Container(
                width: MediaQuery.of(context).size.width * 0.02,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
          ],
        ),
      ),
      Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            height: MediaQuery.of(context).size.width * 0.05,
            child: displayedContent.isNew
                ? Image.asset(
                    IconConstant.iconNew,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : AutoSizeText(
                    displayedContent.dif > 0 ? '+${displayedContent.dif}' : ''),
          ))
    ]);
  }
}
