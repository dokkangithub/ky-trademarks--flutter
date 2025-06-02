import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';
import 'CurrentBrandStatus.dart';

class BrandDescriptionAndDetails extends StatelessWidget {
  const BrandDescriptionAndDetails({
    Key? key,
    required this.context,
    required this.model,
  }) : super(key: key);

  final BuildContext context;
  final GetBrandDetailsProvider model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        model.brandDetails!.brand.markOrModel == 1
            ? const SizedBox()
            : model.brandDetails!.brand.brandDescription == '' ||
                    model.brandDetails!.brand.brandDescription == null
                ? SizedBox()
                : Row(
                    children: [
                      Text(
                        "brand_category".tr(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Expanded(
                        child: Text(
                          model.brandDetails!.brand.brandDescription,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 14,
                              fontFamily:StringConstant.fontName),
                        ),
                      ),
                    ],
                  ),
        model.brandDetails!.brand.brandDetails == '' ||
                model.brandDetails!.brand.brandDetails == null
            ? SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrentBrandStatus(context: context, model: model),
                  model.brandDetails == null
                      ? const SizedBox()
                      : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            model.brandDetails!.brand.markOrModel == 1
                                ? "model_details".tr()
                                : "category_details".tr(),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontFamily:StringConstant.fontName),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(
                            model.brandDetails!.brand.brandDetails
                                .replaceAll('<br>', '') ??
                                "",
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 14,
                                fontFamily:StringConstant.fontName),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                ],
              ),
      ],
    );
  }
}
