import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rewild/core/constants/image_constant.dart';
import 'package:rewild/widgets/progress_indicator.dart';

class ReWildNetworkImage extends StatelessWidget {
  const ReWildNetworkImage({
    super.key,
    this.width,
    this.height,
    required this.image,
    this.fit,
  }) : assert(width != null || height != null);

  final double? width;
  final double? height;
  final BoxFit? fit;
  final String image;
  bool validateURL(String? input) {
    if (input == null) {
      return false;
    }
    if (Uri.tryParse(input)?.hasAbsolutePath ?? false) {
      return Uri.parse(input).host.isNotEmpty;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!validateURL(image)) {
      return Image.asset(
        width: width,
        height: height,
        ImageConstant.taken,
        fit: BoxFit.scaleDown,
      );
    }
    return SizedBox(
      height: height,
      width: width,
      child: CachedNetworkImage(
        imageUrl: image,
        placeholder: (context, url) => const MyProgressIndicator(),
        errorWidget: (context, url, error) => Image.asset(
          ImageConstant.taken,
          fit: BoxFit.scaleDown,
        ),
        fit: fit ?? BoxFit.fill,
      ),
    );
  }
}
