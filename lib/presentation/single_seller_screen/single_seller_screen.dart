import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild/presentation/single_seller_screen/single_seller_view_model.dart';

class SingleSellerScreen extends StatelessWidget {
  const SingleSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SingleSellerViewModel>();
    return const Placeholder();
  }
}
