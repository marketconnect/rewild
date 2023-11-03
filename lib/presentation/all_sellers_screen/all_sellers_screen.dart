import 'package:auto_size_text/auto_size_text.dart';
import 'package:rewild/core/constants.dart';
import 'package:rewild/core/utils/image_constant.dart';
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
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            appBar: AppBar(
                title: const Text(
              "Продавцы",
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
                        'Пусто',
                      ),
                    ],
                  ))
                : ListView.builder(
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      final ogrn = sellers[index].ogrn;
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          MainNavigationRouteNames.singleGroupScreen,
                          arguments: sellers[index].name,
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.1),
                                      ),
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(2)),
                                  child: Column(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _TopRow(
                                          name: sellers[index].name,
                                          ogrn: ogrn),
                                      Divider(
                                        height: 0.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.1),
                                      ),
                                      const _BottomRow()
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      );
                    })));
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    // required this.sellers,
    required this.ogrn,
    required this.name,
  });

  // final List<SellerModel> sellers;
  final String? ogrn;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.03,
            child: AutoSizeText(
              name,
              maxLines: 4,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.03,
            child: AutoSizeText(
              (ogrn != null && ogrn!.length > 3)
                  ? "${RegionsNumsConstants.regions[ogrn!.substring(3, 5)]}"
                  : "-$ogrn",
              maxLines: 2,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
        ],
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.007,
                ),
                Text("Добавлен:",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5))),
                Text("20.01.2023",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5))),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.007,
                ),
              ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.005,
              ),
              child: Text(
                "Данные",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.015,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
          ],
        )
      ],
    );
  }
}
