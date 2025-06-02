import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';

class BrandNameAndNumber extends StatelessWidget {
  const BrandNameAndNumber({
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
        model.brandDetails == null ||
                model.brandDetails!.brand.brandName == null ||
                model.brandDetails!.brand.brandName == ''
            ? const SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.brandDetails!.brand.markOrModel == 1
                        ? "model_desc".tr()
                        : "brand_name".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 14,
                        fontFamily:StringConstant.fontName),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Text(
                        model.brandDetails!.brand.brandName ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 14,
                            fontFamily:StringConstant.fontName),
                        textAlign: TextAlign.start,
                        maxLines: null,
                      ),
                    ),
                  ),
                ],
              ),
        Row(
          children: [
            Text(
              model.brandDetails!.brand.markOrModel == 1
                  ? "model_number".tr()
                  : "brand_number".tr(),
              style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14,
                  fontFamily:StringConstant.fontName),
            ),
            Text(
              model.brandDetails!.brand.brandNumber ?? '',
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
