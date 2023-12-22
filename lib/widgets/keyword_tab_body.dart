import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rewild/widgets/keyword_slidable_container.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class TabBody extends StatelessWidget {
  const TabBody(
      {super.key,
      required this.content,
      this.isExcluded = false,
      required this.moveToExcluded,
      required this.moveToKeywords,
      required this.searchQuery});

  final List<CardContent> content;
  final bool isExcluded;

  final void Function(String word) moveToExcluded;
  final void Function(String word) moveToKeywords;
  final String searchQuery;
  @override
  Widget build(BuildContext context) {
    return _CardsList(
      isExcluded: isExcluded,
      content: content,
      moveToExcluded: moveToExcluded,
      moveToKeywords: moveToKeywords,
      searchQuery: searchQuery,
    );
  }
}

class _CardsList extends StatefulWidget {
  const _CardsList(
      {required this.content,
      required this.isExcluded,
      required this.moveToExcluded,
      required this.moveToKeywords,
      required this.searchQuery});

  final List<CardContent> content;
  final bool isExcluded;

  final void Function(String word) moveToExcluded;
  final void Function(String word) moveToKeywords;
  final String searchQuery;

  @override
  _CardsListState createState() => _CardsListState();
}

class _CardsListState extends State<_CardsList> {
  final ScrollController _scrollController = ScrollController();
  List<CardContent> _displayedContent = [];
  int _loadedItems = 0;
  final int _itemsPerLoad = 50;
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
    if (_loadedItems >= widget.content.length) {
      _displayedContent = widget.content;
      return;
    }

    setState(() {});
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

  void dropItem(String text, Function callback) {
    setState(() {
      widget.content.removeWhere((element) => element.word == text);
      _loadItems(1);
    });
    callback(text);
  }

  @override
  Widget build(BuildContext context) {
    final moveToExcluded = widget.moveToExcluded;
    final moveToKeywords = widget.moveToKeywords;
    final newSearchQuery = widget.searchQuery;
    if (newSearchQuery != searchQuery) {
      searchQuery = newSearchQuery;
      _loadItems();
    }

    return Stack(children: [
      SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _displayedContent.length,
              itemBuilder: (context, index) {
                if (index == _displayedContent.length - 1 &&
                    _loadedItems < widget.content.length) {
                  return Container(
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                              ))),
                      child: MyProgressIndicator());
                }
                return Slidable(
                  key: Key(_displayedContent[index].orderNum.toString()),
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
                                  _displayedContent[index].word,
                                  moveToExcluded),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              icon: Icons.remove,
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
                                  _displayedContent[index].word,
                                  moveToKeywords),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              icon: Icons.add,
                              label: 'Добавить',
                            ),
                          ],
                        ),
                  child: SlidableContainer(
                      displayedContent: _displayedContent[index]),
                );
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
