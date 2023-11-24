import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/utils/strings.dart';

import 'package:rewild/presentation/auto_stats_words_screen/auto_stats_words_view_model.dart';

class AutoStatsWordsScreen extends StatelessWidget {
  const AutoStatsWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatsWordsViewModel>();
    final name = model.name;

    final keywords = model.keywords;
    final excluded = model.excluded;
    final searchInputOpen = model.searchInputOpen;
    final searchInputToggle = model.toggleSearchInput;
    final setSearchQuery = model.setSearchQuery;
    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(name!.capitalize()),
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
                          // keyboardType: keyboardType,
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
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await model.save();
              },
              child: const Icon(Icons.add),
            ),
            body: model.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(children: [
                    _TabBody(
                      content: keywords
                          .map((e) =>
                              _CardContent(word: e.keyword, qty: e.count))
                          .toList(),
                    ),
                    _TabBody(
                      isExcluded: true,
                      content: excluded
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
  const _TabBody({required this.content, this.isExcluded = false});

  final List<_CardContent> content;
  final bool isExcluded;
  @override
  Widget build(BuildContext context) {
    return _CardsList(
      isExcluded: isExcluded,
      content: content,
    );
  }
}

class _CardContent {
  final String word;
  final int? qty;

  _CardContent({required this.word, this.qty});
}

class _CardsList extends StatefulWidget {
  const _CardsList({required this.content, required this.isExcluded});

  final List<_CardContent> content;
  final bool isExcluded;

  @override
  _CardsListState createState() => _CardsListState();
}

class _CardsListState extends State<_CardsList> {
  final ScrollController _scrollController = ScrollController();
  List<_CardContent> _displayedContent = [];
  int _loadedItems = 0;
  final int _itemsPerLoad = 20;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadItems();
    }
  }

  void _loadItems([int? qty]) {
    if (searchQuery != "") {
      setState(() {
        _displayedContent = widget.content
            .where((item) =>
                item.word.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
        _loadedItems = _displayedContent.length;
      });
      return;
    }
    final perLoad = qty ?? _itemsPerLoad;
    final int endIndex = _loadedItems + perLoad;

    if (endIndex < widget.content.length) {
      setState(() {
        _displayedContent = widget.content.sublist(0, endIndex);
        _loadedItems = endIndex;
      });
    } else {
      setState(() {
        _displayedContent = widget.content;
        _loadedItems = widget.content.length;
      });
    }
  }

  // void _loadItems([int? qty]) {
  //   final perLoad = qty ?? _itemsPerLoad;

  //   // // Apply search filter
  //   // final filteredContent = searchQuery == ""
  //   //     ? widget.content
  //   //     : widget.content
  //   //         .where((item) =>
  //   //             item.word.toLowerCase().contains(searchQuery.toLowerCase()))
  //   //         .toList();

  //   final int endIndex = _loadedItems + perLoad;

  //   if (endIndex < filteredContent.length) {
  //     setState(() {
  //       _displayedContent = filteredContent.sublist(0, endIndex);
  //       _loadedItems = endIndex;
  //     });
  //   } else {
  //     setState(() {
  //       _displayedContent = filteredContent.toList();
  //       _loadedItems = filteredContent.length;
  //     });
  //   }
  // }

  void dropItem(String text, Function callback) {
    setState(() {
      widget.content.removeWhere((element) => element.word == text);
      _loadItems(1);
    });
    callback(text);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutoStatsWordsViewModel>();
    final moveToExcluded = model.moveToExcluded;
    final moveToKeywords = model.moveToKeywords;
    final newSearchQuery = model.searchQuery;
    if (newSearchQuery != searchQuery) {
      searchQuery = newSearchQuery;
      _loadItems();
    }
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _displayedContent.length,
            itemBuilder: (context, index) {
              return Slidable(
                // enabled: false,
                startActionPane: widget.isExcluded
                    ? null
                    : ActionPane(
                        dragDismissible: false,
                        // A motion is a widget used to control how the pane animates.
                        motion: const ScrollMotion(),

                        // A pane can dismiss the Slidable.
                        dismissible: DismissiblePane(onDismissed: () {}),

                        // All actions are defined in the children parameter.
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (BuildContext context) => dropItem(
                                _displayedContent[index].word, moveToExcluded),
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.group_remove,
                            label: 'Исключить',
                          ),
                        ],
                      ),
                endActionPane: !widget.isExcluded
                    ? null
                    : ActionPane(
                        dragDismissible: false,
                        // A motion is a widget used to control how the pane animates.
                        motion: const ScrollMotion(),

                        // A pane can dismiss the Slidable.
                        dismissible: DismissiblePane(onDismissed: () {}),

                        // All actions are defined in the children parameter.
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (BuildContext context) => dropItem(
                                _displayedContent[index].word, moveToKeywords),
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.group_remove,
                            label: 'Исключить',
                          ),
                        ],
                      ),
                child: _SlidableContainer(
                    displayedContent: _displayedContent[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SlidableContainer extends StatelessWidget {
  const _SlidableContainer({
    required this.displayedContent,
  });

  final _CardContent displayedContent;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight * 0.1,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ))),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.01),
        child: Row(
          children: [
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
                child: AutoSizeText('${displayedContent.qty}000'),
              ),
          ],
        ),
      ),
    );
  }
}
