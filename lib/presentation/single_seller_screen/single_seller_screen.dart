// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// // import 'package:rewild/domain/entities/price_history_model.dart';
// import 'package:rewild/presentation/single_seller_screen/single_seller_view_model.dart';
// import 'package:rewild/widgets/progress_indicator.dart';
// // import 'package:syncfusion_flutter_charts/charts.dart';

// class SingleSellerScreen extends StatelessWidget {
//   const SingleSellerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<SingleSellerViewModel>();
//     final cards = model.allSellerCards;
//     final loading = model.loading;

//     return SafeArea(
//       child: Scaffold(
//         body: loading
//             ? const MyProgressIndicator()
//             : SingleChildScrollView(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: cards.length,
//                   itemBuilder: (context, index) {
//                     // print(cards[index].priceHistory);
//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 2),
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primaryContainer,
//                       ),
//                       child: Row(children: [
//                         SizedBox(
//                           width: model.screenWidth * 0.2,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: CachedNetworkImage(
//                                 imageUrl: cards[index].img ?? ''),
//                           ),
//                         ),
//                         // SizedBox(
//                         //     width: model.screenWidth * 0.5,
//                         //     height: model.screenWidth * 0.2,
//                         //     child: SfCartesianChart(
//                         //         // Initialize category axis
//                         //         primaryXAxis: CategoryAxis(),
//                         //         series: <LineSeries<PriceHistoryModel, String>>[
//                         //           LineSeries<PriceHistoryModel, String>(
//                         //               // Bind data source
//                         //               dataSource: cards[index].priceHistory,
//                         //               xValueMapper:
//                         //                   (PriceHistoryModel price, _) {
//                         //                 final date =
//                         //                     DateTime.fromMillisecondsSinceEpoch(
//                         //                         price.dt * 1000);
//                         //                 final day = date.day > 9
//                         //                     ? date.day
//                         //                     : '0${date.day}';
//                         //                 final month = date.month > 9
//                         //                     ? date.month
//                         //                     : '0${date.month}';

//                         //                 return '$day.$month';
//                         //               },
//                         //               yValueMapper:
//                         //                   (PriceHistoryModel price, _) =>
//                         //                       price.price)
//                         //         ])
//                         //         )
//                       ]),
//                     );
//                   },
//                 ),
//               ),
//       ),
//     );
//   }
// }
