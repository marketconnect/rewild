import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/auto_stats_words_screen/auto_stats_words_view_model.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class AutoStatsWordsScreen extends StatelessWidget {
  const AutoStatsWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatsWordsViewModel>();
    final keywords = model.autoStatWord?.keywords;
    // final excluded = model.autoStatWord?.excludedWord;
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Stats Words')),
      body: keywords == null
          ? const MyProgressIndicator()
          : ListView.builder(
              itemBuilder: (model, index) => Text(keywords[index].keyword),
              itemCount: keywords.length),
    );
  }
}
