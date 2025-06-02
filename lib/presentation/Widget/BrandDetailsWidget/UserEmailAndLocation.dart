import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../resources/StringManager.dart';
import '../../../utilits/Local_User_Data.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';

class UserEmailAndLocation extends StatelessWidget {
  const UserEmailAndLocation({
    Key? key,
    required this.context,
    required this.model,
  }) : super(key: key);

  final BuildContext context;
  final GetBrandDetailsProvider model;

  @override
  Widget build(BuildContext context) {
    return model.brandDetails==null?const SizedBox(): Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        model.brandDetails!.brand.country==null? SizedBox():
        Row(
          children: [
            Text(
              "in_out_egy".tr(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 14,
                  fontFamily:StringConstant.fontName
              ),
            ),
            Text(
              model.brandDetails!.brand.country == 0 ? "in_egypt".tr() : "out_egypt".tr(),
              style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14,
                  fontFamily:StringConstant.fontName),
            ),

            Text(
              model.brandDetails!.brand.country == 0 ? '' : '   ،   ${model.brandDetails!.brand.countryName ?? ''}',
              style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14,
                  fontFamily:StringConstant.fontName),
            ),
          ],
        ),
      ],
    );
  }
}
