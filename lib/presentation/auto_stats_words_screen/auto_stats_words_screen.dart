import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/utils/strings.dart';

import 'package:rewild/presentation/auto_stats_words_screen/auto_stats_words_view_model.dart';

class AutoStatsWordsScreen extends StatelessWidget {
  const AutoStatsWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatsWordsViewModel>();

    final name = model.name;
    final stats = model.autoStatWord;

    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(name!.capitalize()),
              bottom: TabBar(splashFactory: NoSplash.splashFactory, tabs: [
                SizedBox(
                  width: model.screenWidth * 0.5,
                  child: const Tab(
                    child: Text('Ключевые фразы'),
                  ),
                ),
                SizedBox(
                  width: model.screenWidth * 0.5,
                  child: const Tab(
                    child: Text('Исключения'),
                  ),
                ),
              ]),
            ),
            body: stats == null
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(children: [
                    _TabBody(
                      content: stats.keywords
                          .map((e) =>
                              _CardContent(word: e.keyword, qty: e.count))
                          .toList(),
                    ),
                    _TabBody(
                      content: stats.excluded
                          .map((e) => _CardContent(
                                word: e,
                              ))
                          .toList(),
                    ),
                  ]),
          )),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.content});

  final List<_CardContent> content;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _CardsList(
            content: content,
          )
        ],
      ),
    );
  }
}

class _CardContent {
  final String word;
  final int? qty;

  _CardContent({required this.word, this.qty});
}

class _CardsList extends StatelessWidget {
  const _CardsList({required this.content});
  final List<_CardContent> content;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatsWordsViewModel>();
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: content.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.all(model.screenWidth * 0.01),
          child: Row(
            children: [
              Expanded(
                flex: content[index].qty != null ? 8 : 10,
                child: AutoSizeText(
                  content[index].word,
                  maxLines: 4,
                ),
              ),
              if (content[index].qty != null)
                Expanded(
                  flex: 2,
                  child: AutoSizeText(content[index].qty.toString() + '000'),
                ),
            ],
          ),
        );
      },
    );
  }
}
