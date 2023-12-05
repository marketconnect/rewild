import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/questions_screen/question_view_model.dart';
import 'package:rewild/widgets/empty_widget.dart';

import 'package:rewild/widgets/review_card.dart';

class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final model = context.watch<QuestionViewModel>();
    final questions = model.questions;
    final apiKeyexists = model.apiKeyExists;

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
                  children: questions
                      .map((e) => ReviewCard(
                            reviewText: e.text,
                            createdAt: e.createdDate,
                          ))
                      .toList(),
                )
              ]),
            ),
    );
  }
}
