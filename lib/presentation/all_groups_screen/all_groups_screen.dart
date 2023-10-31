import 'package:rewild/core/utils/image_constant.dart';
import 'package:rewild/core/utils/strings.dart';
import 'package:rewild/presentation/all_groups_screen/all_groups_view_model.dart';
import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllGroupsScreen extends StatelessWidget {
  const AllGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllGroupsScreenViewModel>();
    final groups = model.groups;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: const Text(
              "Группы",
              style: TextStyle(fontSize: 16),
            )),
            body: groups.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImageView(
                        svgPath: ImageConstant.imgNotFound,
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      const Text(
                        'У вас пока нет групп',
                      ),
                    ],
                  ))
                : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          MainNavigationRouteNames.singleGroupScreen,
                          arguments: groups[index].name,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.12,
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
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          decoration: BoxDecoration(
                                              color:
                                                  Color(groups[index].bgColor)
                                                      .withOpacity(1.0),
                                              borderRadius:
                                                  BorderRadius.circular(2)),
                                          child: Icon(
                                            Icons.group,
                                            color:
                                                Color(groups[index].fontColor),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                groups[index].name.capitalize(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${groups[index].cardsNmIds.length} карточек',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.5)),
                                              ),
                                            ]),
                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 15,
                                          ),
                                        ])
                                  ],
                                ),
                              ),
                            )),
                      );
                    })));
  }
}
