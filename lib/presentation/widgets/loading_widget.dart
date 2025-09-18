import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';


class LoadingWidget extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingWidget({
    super.key,
    this.color, // Default color
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.fourRotatingDots(
      color: color ?? AppColor.primaryColor.withOpacity(0.7),
      size: size ?? Sizes.loaderBig(context) ,
/*      secondRingColor: AppColor.secondaryColor,
      thirdRingColor: AppColor.secondaryColor.withOpacity(0.5),*/
    );
  }
}