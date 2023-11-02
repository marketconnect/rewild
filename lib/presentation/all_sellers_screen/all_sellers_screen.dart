import 'package:auto_size_text/auto_size_text.dart';
import 'package:rewild/core/utils/image_constant.dart';
import 'package:rewild/core/utils/strings.dart';
import 'package:rewild/presentation/all_sellers_screen/all_sellers_view_model.dart';

import 'package:rewild/routes/main_navigation_route_names.dart';
import 'package:rewild/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllSellersScreen extends StatelessWidget {
  const AllSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllSellersScreenViewModel>();
    final sellers = model.sellers;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: const Text(
              "Группы",
              style: TextStyle(fontSize: 16),
            )),
            body: sellers.isEmpty
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
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          MainNavigationRouteNames.singleGroupScreen,
                          arguments: sellers[index].name,
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          child: AutoSizeText(
                                            sellers[index].name.capitalize(),
                                            maxLines: 4,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          // '${sellers[index].cardsNmIds.length} карточек',
                                          '5 карточек',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.5)),
                                        ),
                                      ]),
                                ],
                              ),
                            )),
                      );
                    })));
  }
}
