import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import 'package:kyuser/presentation/Controllar/GetBrandDetailsProvider.dart';

import '../../../resources/StringManager.dart';

class CurrentBrandStatus extends StatelessWidget {
  const CurrentBrandStatus({
    Key? key,
    required this.context,
    required this.model,
  }) : super(key: key);

  final BuildContext context;
  final GetBrandDetailsProvider model;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.brandDetails!.brand.markOrModel == 1
              ?
          "model_status".tr():
          "brand_status".tr(),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14,
              fontFamily:StringConstant.fontName),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .7,
          child: Text(
            model.brandDetails!.brand.newCurrentState == ''
                ? convertStateBrandNumberToString(
                model.brandDetails!.brand.currentStatus)
                : model.brandDetails!.brand.newCurrentState,
            style:
            Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 15,
                fontFamily:StringConstant.fontName),
          ),
        ),
      ],
    );
  }
}
