import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';

class BrandDateAndClass extends StatelessWidget {
  const BrandDateAndClass({
    Key? key,
    required this.context,
    required this.model,
  }) : super(key: key);

  final BuildContext context;
  final GetBrandDetailsProvider model;

  @override
  Widget build(BuildContext context) {
    return model.brandDetails==null?const SizedBox(): Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Row(
              children: [
                Text(
                  "order_date".tr(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 14,
                      fontFamily:StringConstant.fontName
                  ),
                ),
                Text(
                  model.brandDetails!.brand.applicationDate??"",
                  style:
                  Theme.of(context).textTheme.displayLarge?.copyWith(fontFamily:StringConstant.fontName,fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //
        //       "فئة العلامة : ",
        //       style: Theme.of(context).textTheme.displayMedium?.copyWith(
        //           fontSize: 14
        //       ),
        //     ),
        //     Expanded(
        //       child: Text(
        //         model.brandDetails!.brand.brandDescription,
        //         style: Theme.of(context).textTheme.displayLarge?.copyWith(
        //             fontSize: 14
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        model.brandDetails!.brand.notes==''?SizedBox():
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(

              "notes".tr(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 14,
                  fontFamily:StringConstant.fontName
              ),
            ),
            Expanded(
              child: Text(
                model.brandDetails!.brand.notes,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 14,
                    fontFamily:StringConstant.fontName
                ),
              ),
            ),
          ],
        ),
        model.brandDetails!.brand.paymentStatus==''?SizedBox():
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(

              "payment_status".tr(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 14,
                  fontFamily:StringConstant.fontName
              ),
            ),
            Expanded(
              child: Text(
                model.brandDetails!.brand.paymentStatus,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 14,
                    fontFamily:StringConstant.fontName
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
