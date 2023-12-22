import 'package:flutter/material.dart';

class RateStars extends StatelessWidget {
  const RateStars({super.key, required this.valuation});
  final int valuation;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFFf8d253),
          ),
          Icon(
            Icons.star,
            color: valuation > 1
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
          Icon(
            Icons.star,
            color: valuation > 2
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
          Icon(
            Icons.star,
            color: valuation > 3
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
          Icon(
            Icons.star,
            color: valuation > 4
                ? const Color(0xFFf8d253)
                : const Color(0xFFd9d9d9),
          ),
        ],
      ),
    );
  }
}
