import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/utils/strings.dart';
import 'package:rewild/domain/entities/question.dart';
import 'package:rewild/presentation/all_questions_screen/all_questions_view_model.dart';

class AllQuestionsScreen extends StatelessWidget {
  const AllQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllQuestionsViewModel>();
    final questions = model.questions;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
            children: questions
                .map((e) => _QuestionCard(
                      question: e,
                    ))
                .toList()),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    super.key,
    required this.question,
  });

  final Question question;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dif = DateTime.now().difference(question.createdDate);
    final ago = dif.inDays > 1
        ? getNoun(dif.inDays, "${dif.inDays} день назад",
            "${dif.inDays} дня назад", "${dif.inDays} дней назад")
        : dif.inHours > 1
            ? getNoun(dif.inHours, '${dif.inHours} час назад',
                '${dif.inHours} часа назад', '${dif.inHours} часов назад')
            : dif.inMinutes > 1
                ? getNoun(
                    dif.inMinutes,
                    '${dif.inMinutes} минута назад',
                    '${dif.inMinutes} минуты назад',
                    '${dif.inMinutes} минуты назад)')
                : 'только что';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
        )),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.027),
                ),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.027),
                child: Text(question.productDetails.supplierArticle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    )),
              )
            ],
          ),
          Row(
            children: [
              Container(
                  width: screenWidth * 0.86,
                  child: Text(
                    question.text,
                    maxLines: 20,
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(child: Text(ago)),
            ],
          ),
        ],
      ),
    );
  }
}
