import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({super.key, this.size = 50.0});
  final double size;
  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(
      duration: const Duration(milliseconds: 1000),
      size: size,
      itemBuilder: (context, index) {
        final colors = [
          const Color(0xFF21005D),
          const Color(0xFF6750A4),
          const Color(0xFF625B71),
          const Color(0xFF7D5260),
        ];
        final color = colors[index % colors.length];
        return DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      },
    );
  }
}
