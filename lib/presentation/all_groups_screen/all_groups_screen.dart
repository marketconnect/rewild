import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/core/utils/extensions/strings.dart';
import 'package:rewild/domain/entities/group_model.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/widgets/empty_widget.dart';
import 'package:shimmer/shimmer.dart';

class AllGroupsScreen extends StatelessWidget {
  const AllGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllGroupsScreenViewModel>();
    List<GroupModel> groups = model.groups;

    final isLoading = model.isLoading;
    if (isLoading) {
      groups = generateFakeGroups(model.groupsCount);
    }

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: const Text(
                  'Группы',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1f1f1f),
                  ),
                  // textScaler: TextScaler()
                ),
                scrolledUnderElevation: 2,
                shadowColor: Colors.black,
                surfaceTintColor: Colors.transparent),
            body: !isLoading && groups.isEmpty
                ? const EmptyWidget(
                    text: 'У вас пока нет групп',
                  )
                : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            if (isLoading) return;
                            Navigator.of(context).pushNamed(
                              MainNavigationRouteNames.singleGroupScreen,
                              arguments: groups[index].name,
                            );
                          },
                          child: isLoading
                              ? Shimmer(
                                  gradient: shimmerGradient,
                                  child: _GroupCard(
                                    isShimmer: true,
                                    group: groups[index],
                                  ),
                                )
                              : _GroupCard(
                                  group: groups[index],
                                ));
                    })));
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, this.isShimmer = false});
  final GroupModel group;
  final bool isShimmer;

  void _openAnimatedDialog(BuildContext context, String groupName,
      Future<void> Function() onDelete) {
    final text = "Удалить группу $groupName?";
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: AutoSizeText(
                        text,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 20),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllGroupsScreenViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final rename = model.rename;
    final delete = model.delete;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Slidable(
        startActionPane: ActionPane(
          dragDismissible: false,
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          dismissible: DismissiblePane(onDismissed: () {}),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (BuildContext context) async => _openAnimatedDialog(
                  context, group.name, () => delete(group.name)),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.group_remove,
              label: 'Удалить',
            ),
          ],
        ),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          dragDismissible: false,
          // dismissible: ,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (BuildContext context) => showDialog(
                context: context,
                builder: (BuildContext context) {
                  String newGroupName = "";
                  return AlertDialog(
                    insetPadding: const EdgeInsets.all(10),
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    buttonPadding: EdgeInsets.zero,
                    title: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Название группы",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    content: TextField(
                      controller: TextEditingController()..text = group.name,
                      onChanged: (value) {
                        newGroupName = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                            child: Text(
                              'Отмена',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            )),
                      ),
                      TextButton(
                        onPressed: () async {
                          await rename(group.name, newGroupName);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                )),
                            child: Text(
                              'Сохранить',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            )),
                      ),
                    ],
                  );
                },
              ),
              backgroundColor: const Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Переименовать',
            ),
          ],
        ),
        child: Container(
          width: model.screenWidth,
          height: model.screenHeight * 0.12,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.2),
              ),
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.12,
                      decoration: BoxDecoration(
                          color: Color(group.bgColor).withOpacity(1.0),
                          borderRadius: BorderRadius.circular(2)),
                      child: Icon(
                        Icons.pie_chart,
                        color: Color(group.fontColor),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: model.screenWidth * 0.5,
                            child: isShimmer
                                ? Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.02,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  )
                                : AutoSizeText(
                                    group.name.capitalize(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          isShimmer
                              ? Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width: screenWidth * 0.1,
                                  height: screenHeight * 0.015,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                )
                              : Text(
                                  '${group.cardsNmIds.length} карточек',
                                  style: TextStyle(
                                      fontSize: model.screenWidth * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5)),
                                ),
                        ]),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                    String.fromCharCode(Icons.arrow_forward_ios.codePoint),
                    style: TextStyle(
                      inherit: false,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: model.screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      fontFamily: Icons.arrow_forward_ios.fontFamily,
                      package: Icons.arrow_forward_ios.fontPackage,
                    ),
                  )
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<GroupModel> generateFakeGroups(int count) {
  List<GroupModel> groups = [];

  for (int i = 0; i <= count; i++) {
    groups.add(GroupModel(
      id: i,
      name: "Group $i",
      bgColor: 0xFFE0E0E0,
      fontColor: 0xFF000000,
      cardsNmIds: [1, 2, 3],
      cards: [],
    ));
  }

  return groups;
}
