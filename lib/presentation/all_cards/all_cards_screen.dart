import 'package:rewild/core/utils/strings.dart';
import 'package:rewild/domain/entities/card_of_product_model.dart';
import 'package:flutter/material.dart';

import 'package:rewild/presentation/all_cards/all_cards_screen_view_model.dart';
import 'package:rewild/presentation/all_cards/widgets/my_sliver_persistent_header_delegate.dart';
import 'package:rewild/presentation/all_cards/widgets/product_card_widget.dart';

import 'package:provider/provider.dart';

import 'package:rewild/routes/main_navigation_route_names.dart';

import 'package:rewild/widgets/custom_elevated_button.dart';

class AllCardsScreen extends StatefulWidget {
  const AllCardsScreen({super.key});

  @override
  State<AllCardsScreen> createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen>
    with WidgetsBindingObserver {
  void Function(bool)? mountedCallback;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mountedCallback == null) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("app in resumed");
        mountedCallback!(true);
        break;
      case AppLifecycleState.inactive:
        debugPrint("app in inactive");
        mountedCallback!(false);
        break;
      case AppLifecycleState.paused:
        debugPrint("app in paused");
        mountedCallback!(false);
        break;
      case AppLifecycleState.detached:
        debugPrint("app in detached");
        mountedCallback!(false);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    mountedCallback = model.setMounted;
    List<CardOfProductModel> productCards = model.productCards;
    final selectedGroup = model.selectedGroup;
    int selectedGroupIndex = 0;
    final groups = model.groups;

    if (selectedGroup != null) {
      productCards = productCards.where((card) {
        final groupsIds = card.groups.map((group) => group.id);
        return groupsIds.contains(selectedGroup.id);
      }).toList();
      final grName = selectedGroup.name;

      selectedGroupIndex = groups.indexWhere((group) => group.name == grName);
    }

    final selectionInProcess = model.selectionInProcess;

    final headerSliverBuilderItems = selectionInProcess
        ? [_HorizontalScrollMenu(selectedGroupIndex)]
        : [
            const _AppBar(),
            _HorizontalScrollMenu(selectedGroupIndex),
          ];

    return SafeArea(
      child: Scaffold(
        body: DefaultTabController(
          length: selectionInProcess ? 1 : groups.length,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return headerSliverBuilderItems;
            },
            body: productCards
                    .isEmpty // Body ============================================================== Body
                ? const _EmptyProductsCards()
                : Stack(children: [
                    ListView.builder(
                      itemCount: productCards.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index > (productCards.length - 1)) {
                          return Container();
                        }
                        if (selectionInProcess &&
                            index == productCards.length - 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 50.0),
                            child: _GestureDetectorCard(
                                productCard: productCards[index]),
                          );
                        }
                        return _GestureDetectorCard(
                          productCard: productCards[index],
                        );
                      },
                    ),
                    if (selectionInProcess) const _BottomMergeBtn()
                  ]),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // AppBar ========================================================== AppBar
      pinned: false,
      expandedHeight: 60.0,
      collapsedHeight: 60.0,
      actions: [
        PopupMenuButton(
          // Menu ============================================ Menu
          onSelected: (value) => Navigator.popAndPushNamed(context, value),
          icon: const Icon(
            Icons.keyboard_control,
            size: 20,
          ),
          itemBuilder: (BuildContext context) {
            return const [
              PopupMenuItem(
                value: MainNavigationRouteNames.myWebViewScreen,
                child: _PopumMenuItemChild(
                  iconData: Icons.add_circle_outline_rounded,
                  text: "Добавить",
                ),
              ),
              PopupMenuItem(
                // value: MainNavigationRouteNames.addGroupsScreen,
                value: '',
                child: _PopumMenuItemChild(
                  iconData: Icons.group_outlined,
                  text: "Группы",
                ),
              ),
              PopupMenuItem(
                value: MainNavigationRouteNames.splashScreen,
                child: _PopumMenuItemChild(
                  iconData: Icons.search,
                  text: "Поиск",
                ),
              )
            ];
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(0, 15, 35, 15),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              height: 60.0,
              child: const Text('Карточки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1f1f1f),
                  ),
                  textScaleFactor: 1),
            ),
          ],
        ),
        stretchModes: const [StretchMode.zoomBackground],
      ),
    );
  }
}

class _BottomMergeBtn extends StatelessWidget {
  const _BottomMergeBtn();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final combine = model.combine;
    return Align(
      // Bottom merge btn ============================================================== Bottom merge btn
      alignment: Alignment.bottomRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: 55,
        margin: const EdgeInsets.only(bottom: 25, right: 25),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => combine(),
              child: Row(
                children: [
                  Icon(
                    Icons.group_add_outlined,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02,
                        ),
                        child: Text(
                          'В группу',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GestureDetectorCard extends StatelessWidget {
  const _GestureDetectorCard({
    required this.productCard,
  });

  final CardOfProductModel productCard;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final onCardLongPress = model.onCardLongPress;
    final onCardTap = model.onCardTap;
    final id = productCard.nmId;
    final isSelected = model.selectedNmIds.contains(id);
    final selectedGroup = model.selectedGroup;
    return GestureDetector(
      onTap: () => onCardTap(id),
      onLongPress: () => onCardLongPress(id),
      child: ProductCardWidget(
        productCard: productCard,
        inAnyGroup: selectedGroup != null,
        isSelected: isSelected,
      ),
    );
  }
}

class _EmptyProductsCards extends StatelessWidget {
  const _EmptyProductsCards();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCardsScreenViewModel>();
    final loading = model.loading;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: loading
            ? [const CircularProgressIndicator()]
            : [
                const Text("Вы еще не добавили ни одной карточки"),
                CustomElevatedButton(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      MainNavigationRouteNames.myWebViewScreen,
                    );
                  },
                  text: "Добавить",
                  buttonStyle: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary)),
                  margin: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.3,
                      MediaQuery.of(context).size.height * 0.05,
                      MediaQuery.of(context).size.width * 0.3,
                      MediaQuery.of(context).size.height * 0.05),
                ),
              ],
      ),
    );
  }
}

class _PopumMenuItemChild extends StatelessWidget {
  const _PopumMenuItemChild({
    required this.iconData,
    required this.text,
  });

  final IconData iconData;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          iconData,
        ),
        const SizedBox(
          width: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}

class _HorizontalScrollMenu extends StatefulWidget {
  const _HorizontalScrollMenu(this.selectedGroupIndex);
  final int selectedGroupIndex;
  @override
  State<_HorizontalScrollMenu> createState() => _HorizontalScrollMenuState();
}

class _HorizontalScrollMenuState extends State<_HorizontalScrollMenu>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    final model = context.read<AllCardsScreenViewModel>();
    final onClear = model.onClearSelected;
    final onDelete = model.deleteCards;
    final combine = model.combine;
    final len = model.selectedLength;
    final selectionInProcess = model.selectionInProcess;
    final groups = model.groups;

    final isLoading = model.loading;
    final selectGroup = model.selectGroup;
    final productsCardsIsEmpty = model.productCards.isEmpty;
    _tabController = TabController(
      length: selectionInProcess ? 1 : groups.length,
      vsync: this,
      initialIndex: selectionInProcess ? 0 : widget.selectedGroupIndex,
    );

    return SliverPersistentHeader(
      delegate: MySliverPersistentHeaderDelegate(
        TabBar(
            controller: _tabController,
            isScrollable: true,
            labelPadding: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 7),
            labelColor: selectionInProcess
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            // indicatorSize: TabBarIndicatorSize.tab,
            onTap: (index) {
              if (selectionInProcess) {
                return;
              }

              selectGroup(index);
            },
            indicator: selectionInProcess || productsCardsIsEmpty
                ? const BoxDecoration(border: null)
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).colorScheme.primary,
                  ),
            dividerColor: Colors.transparent,
            tabs: selectionInProcess
                ? [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Tab(
                              child: IconButton(
                                icon: Icon(Icons.close,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: MediaQuery.of(context).size.width *
                                        0.08),
                                onPressed: () => onClear(),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$len',
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () => combine(),
                                icon: Icon(Icons.group_remove_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: MediaQuery.of(context).size.width *
                                        0.08)),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            IconButton(
                                onPressed: () =>
                                    _openAnimatedDialog(context, len, onDelete),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size:
                                      MediaQuery.of(context).size.width * 0.08,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ]
                : groups
                    .map(
                      (e) => Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isLoading || productsCardsIsEmpty
                                      ? Colors.transparent
                                      : Theme.of(context).colorScheme.secondary,
                                )),
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                e.name.capitalize().take(5),
                                maxLines: 1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList()),
      ),
      pinned: true,
    );
  }

  void _openAnimatedDialog(
      BuildContext context, int cardsLength, Future<void> Function() onDelete) {
    final cardsName =
        cardsLength == 1 || (cardsLength != 11 && cardsLength % 10 == 1)
            ? "карточку"
            : cardsLength > 4 && cardsLength < 21
                ? "карточек"
                : "карточки";

    final text = "Удалить $cardsLength $cardsName?";
    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Container();
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return AlertDialog(
              insetPadding: const EdgeInsets.all(10),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              buttonPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              title:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.warning_amber,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: Theme.of(context).colorScheme.error),
              ]),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          )),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      )),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onDelete();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.errorContainer,
                          )),
                      child: Text(
                        'Удалить',
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                      )),
                ),
              ]);
        });
  }
}
