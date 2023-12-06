import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/image_constant.dart';
import 'package:rewild/presentation/questions_screen/questions_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final model = context.watch<QuestionsViewModel>();
    final apiKeyexists = model.apiKeyExists;
    final questions = model.questions;
    final getImages = model.getImage;
    final getNewQuestionsQty = model.newQuestionsQty;
    final getallQuestionsQty = model.allQuestionsQty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вопросы'),
      ),
      body: !apiKeyexists
          ? const EmptyWidget(
              text: 'Создайте API ключ, чтобы видеть вопросы',
            )
          : SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Column(
                  children: questions.entries
                      .map((e) => _ProductCard(
                            image: getImages(e.key),
                            newQuetions: getallQuestionsQty(e.key),
                            oldQuetions: getNewQuestionsQty(e.key),
                          ))
                      .toList(),
                )
              ]),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
      {super.key,
      required this.image,
      required this.newQuetions,
      required this.oldQuetions});
  final String image;
  final int newQuetions;
  final int oldQuetions;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AspectRatio(
      aspectRatio: 10 / 3,
      child: SizedBox(
        width: screenWidth,
        child: Row(
          children: [
            SizedBox(
              height: screenWidth * 0.30,
              width: screenWidth * 0.30,
              child: CachedNetworkImage(
                imageUrl: image,
                placeholder: (context, url) => const MyProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  ImageConstant.taken,
                  fit: BoxFit.fill,
                ),
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Column(
              children: [
                Text('$newQuetions'),
                Text('$oldQuetions'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
