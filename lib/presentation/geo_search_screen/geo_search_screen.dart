import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/core/constants/constants.dart';
import 'package:rewild/presentation/geo_search_screen/geo_search_view_model.dart';
import 'package:rewild/widgets/network_image.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class GeoSearchScreen extends StatefulWidget {
  const GeoSearchScreen({super.key});

  @override
  _GeoSearchScreenState createState() => _GeoSearchScreenState();
}

class _GeoSearchScreenState extends State<GeoSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late Map<String, bool> _selectedGeos;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedGeos = geoDistance.map((key, value) => MapEntry(key, false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjusts to the content size
                children: <Widget>[
                  // Draggable Indicator
                  Container(
                    width: 40, // Width of the indicator
                    height: 5, // Height of the indicator
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Light grey color
                      borderRadius: BorderRadius.circular(10), // Rounded edges
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Введите запрос',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _onSearchPressed();
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: Text(
                        'Поиск',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Выберите города:",
                      ),
                      ..._selectedGeos.keys.map((geo) {
                        return CheckboxListTile(
                          title: Text(geo),
                          value: _selectedGeos[geo],
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedGeos[geo] = value!;
                            });
                          },
                        );
                      }).toList(),
                    ]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onSearchPressed() {
    List<String> selectedGNums = _selectedGeos.entries
        .where((entry) => entry.value)
        .map((entry) => geoDistance[entry.key]!)
        .toList();
    context
        .read<GeoSearchViewModel>()
        .searchProducts(selectedGNums, _controller.text);
    // Navigator.pop(context); // Close the bottom sheet after search
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GeoSearchViewModel>();
    final isLoading = model.isLoading;
    final showTabBar = model.searchAdvData.length > 0; // Check for condition

    return DefaultTabController(
      length: showTabBar ? 2 : 1, // Adjust length based on condition
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Гео поиск'),
          bottom: showTabBar
              ? const TabBar(
                  tabs: [
                    Tab(text: 'Поиск'),
                    Tab(text: 'Реклама'),
                  ],
                )
              : null, // Conditional rendering of TabBar
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchBottomSheet,
            ),
          ],
        ),
        body: isLoading
            ? const MyProgressIndicator()
            : model.productsByGeo.isEmpty
                ? const Center(child: Text('Не найдено'))
                : showTabBar
                    ? TabBarView(
                        children: [
                          // First Tab Content
                          ListView.builder(
                            itemCount: model.productsByGeo.length,
                            itemBuilder: (BuildContext context, int index) {
                              int nmId =
                                  model.productsByGeo.keys.elementAt(index);
                              Map<String, int> geoIndices =
                                  model.productsByGeo[nmId]!;
                              String imageUrl = model.imageForProduct(nmId);
                              List<Widget> geoIndexWidgets =
                                  geoIndices.entries.map((entry) {
                                return Text(
                                    '${getDistanceCity(entry.key)} - Место: ${entry.value + 1}');
                              }).toList();

                              return ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  child: imageUrl.isNotEmpty
                                      ? ReWildNetworkImage(
                                          image: imageUrl,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          fit: BoxFit.cover)
                                      : const Placeholder(),
                                ),
                                title: Text('Product $nmId'),
                                subtitle: Column(children: geoIndexWidgets),
                              );
                            },
                          ),
                          // Second Tab Content
                          ListView.builder(
                            itemCount: model.searchAdvData.length,
                            itemBuilder: (BuildContext context, int index) {
                              int nmId =
                                  model.searchAdvData.elementAt(index).id;

                              String imageUrl = model.imageForProduct(nmId);

                              final advData = model.searchAdvData[index];

                              return ListTile(
                                leading: SizedBox(
                                  width: 50,
                                  child: imageUrl.isNotEmpty
                                      ? ReWildNetworkImage(
                                          image: imageUrl,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          fit: BoxFit.cover)
                                      : const Placeholder(),
                                ),
                                title: Text('Product $nmId'),
                                subtitle: Column(children: [
                                  Text('${advData.cpm} ₽'),
                                  Text('${advData.order} ставка')
                                ]),
                              );
                            },
                          ),
                        ],
                      )
                    :
                    // First Tab Content
                    ListView.builder(
                        itemCount: model.productsByGeo.length,
                        itemBuilder: (BuildContext context, int index) {
                          int nmId = model.productsByGeo.keys.elementAt(index);
                          Map<String, int> geoIndices =
                              model.productsByGeo[nmId]!;
                          String imageUrl = model.imageForProduct(nmId);
                          List<Widget> geoIndexWidgets =
                              geoIndices.entries.map((entry) {
                            return Text(
                                '${getDistanceCity(entry.key)} - Место: ${entry.value + 1}');
                          }).toList();

                          return ListTile(
                            leading: SizedBox(
                              width: 50,
                              child: imageUrl.isNotEmpty
                                  ? ReWildNetworkImage(
                                      image: imageUrl,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      fit: BoxFit.cover)
                                  : const Placeholder(),
                            ),
                            title: Text('Product $nmId'),
                            subtitle: Column(children: geoIndexWidgets),
                          );
                        },
                      ),
      ),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<GeoSearchViewModel>();
//     final isLoading = model.isLoading;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Гео поиск'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: _showSearchBottomSheet,
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const MyProgressIndicator()
//           : model.productsByGeo.isEmpty
//               ? const Center(child: Text('Не найдено'))
//               : Column(
//                   children: [
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: model.productsByGeo.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           int nmId = model.productsByGeo.keys.elementAt(index);
//                           Map<String, int> geoIndices =
//                               model.productsByGeo[nmId]!;
//                           String imageUrl = model.imageForProduct(nmId);
//                           List<Widget> geoIndexWidgets =
//                               geoIndices.entries.map((entry) {
//                             return Text(
//                                 '${getDistanceCity(entry.key)} - Место: ${entry.value + 1}');
//                           }).toList();

//                           return ListTile(
//                             leading: SizedBox(
//                               width: 50,
//                               child: imageUrl.isNotEmpty
//                                   ? ReWildNetworkImage(
//                                       image: imageUrl,
//                                       width: MediaQuery.of(context).size.width *
//                                           0.2,
//                                       fit: BoxFit.cover)
//                                   : const Placeholder(),
//                             ),
//                             title: Text('Product $nmId'),
//                             subtitle: Column(children: geoIndexWidgets),
//                           );
//                         },
//                       ),
//                     ),
//                     Text(
//                       "Реклама в поиске: ${model.searchAdvData.length}",
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount:
//                             model.searchAdvData.length, // Adjust as needed
//                         itemBuilder: (BuildContext context, int index) {
//                           int nmId = model.searchAdvData.elementAt(index).id;

//                           String imageUrl = model.imageForProduct(nmId);

//                           final advData = model.searchAdvData[index];

//                           return ListTile(
//                             leading: SizedBox(
//                               width: 50,
//                               child: imageUrl.isNotEmpty
//                                   ? ReWildNetworkImage(
//                                       image: imageUrl,
//                                       width: MediaQuery.of(context).size.width *
//                                           0.2,
//                                       fit: BoxFit.cover)
//                                   : const Placeholder(),
//                             ),
//                             title: Text('Product $nmId'),
//                             subtitle: Column(children: [
//                               Text('${advData.cpm} ₽'),
//                               Text('${advData.order} ставка')
//                             ]),
//                           );
//                         },
//                       ),
//                     )
//                   ],
//                 ),
//     );
//   }
}
