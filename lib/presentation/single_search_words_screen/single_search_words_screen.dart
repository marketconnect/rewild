import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/utils/extensions/strings.dart';
import 'package:rewild/domain/entities/search_campaign_stat.dart';
import 'package:rewild/presentation/single_search_words_screen/single_search_words_view_model.dart';
import 'package:rewild/widgets/keyword_slidable_container.dart';
import 'package:rewild/widgets/keyword_tab_body.dart';
import 'package:rewild/widgets/my_dialog_header_and_two_btns_widget.dart';

class SingleSearchWordsScreen extends StatelessWidget {
  const SingleSearchWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleSearchWordsViewModel>();
    final name = model.name;
    final keywords = model.keywords;
    final stat = model.stat;
    final excluded = model.excluded;
    // final phrase = model.phrase;
    // final pluse = model.pluse;
    // final strong = model.strong;
    final searchInputOpen = model.searchInputOpen;
    final searchInputToggle = model.toggleSearchInput;
    final setSearchQuery = model.setSearchQuery;
    final hasChanges = model.hasChanges;

    final moveToExcluded = model.moveToExcluded;
    final moveToKeywords = model.moveToKeywords;
    final newSearchQuery = model.searchQuery;
    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(name!.capitalize()),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (!hasChanges) {
                      Navigator.of(context).pop();
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return MyDialogHeaderAndTwoBtnsWidget(
                          onNoPressed: () {
                            if (buildContext.mounted) {
                              Navigator.of(buildContext).pop();
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          onYesPressed: () async {
                            await model.save();
                            if (buildContext.mounted) {
                              Navigator.of(buildContext).pop();
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          title: 'Сохранить изменения?',
                        );
                      },
                    );
                  }),
              actions: [
                IconButton(
                    onPressed: () {
                      searchInputToggle();
                    },
                    icon: Icon(
                      searchInputOpen ? Icons.close : Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ))
              ],
              bottom: searchInputOpen
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TextField(
                          autofocus: true,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                              color: Theme.of(context).colorScheme.primary),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.width * 0.03,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          cursorColor: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.3),
                          onChanged: (value) {
                            setSearchQuery(value);
                          },
                        ),
                      ))
                  : TabBar(splashFactory: NoSplash.splashFactory, tabs: [
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
            body: model.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(children: [
                    TabBody(
                      moveToExcluded: moveToExcluded,
                      moveToKeywords: moveToKeywords,
                      searchQuery: newSearchQuery,
                      content: keywords.map((e) {
                        Stat? s;
                        final ss = stat
                            .where((element) => element.keyword == e.keyword);
                        if (ss.isNotEmpty) {
                          s = ss.first;
                        }
                        return CardContent(
                            word: e.keyword,
                            qty: e.count,
                            orderNum: keywords.indexOf(e),
                            dif: e.diff,
                            stat: s,
                            isNew: e.isNew);
                      }).toList(),
                    ),
                    TabBody(
                      moveToExcluded: moveToExcluded,
                      moveToKeywords: moveToKeywords,
                      searchQuery: newSearchQuery,
                      isExcluded: true,
                      content: excluded
                          .map((e) => CardContent(
                                word: e,
                                dif: 0,
                                orderNum: excluded.indexOf(e),
                                isNew: false,
                              ))
                          .toList(),
                    ),
                  ]),
          )),
    );
  }
}
