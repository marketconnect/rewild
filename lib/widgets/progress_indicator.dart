import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(
      duration: const Duration(milliseconds: 1000),
      size: 50.0,
      itemBuilder: (context, index) {
        final colors = [
          const Color(0xFF83735c),
          const Color(0xFF18191d),
          const Color(0xFFa9a092)
        ];
        final color = colors[index % colors.length];
        return DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      },
    );
  }
}
