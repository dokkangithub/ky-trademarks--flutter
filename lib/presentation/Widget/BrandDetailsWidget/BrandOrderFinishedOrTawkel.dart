import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/resources/Color_Manager.dart';

import '../../../core/Constant/Api_Constant.dart';
import '../../../data/Brand/models/BrandDataModel.dart';
import '../../../domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';
import '../gallery.dart';
class BrandOrderFinishedOrTawkel extends StatelessWidget {

  BrandOrderFinishedOrTawkel({
    Key? key,
    required this.context,
    required this.model,
  }) : super(key: key);

  final BuildContext context;
  final GetBrandDetailsProvider model;

  @override
  Widget build(BuildContext context) {
    var value = model.brandDetails?.brand.completedPowerOfAttorneyRequest;
    String? tawkeelImages = model.brandDetails?.brand.tawkeelImage;

    List attachments = model.brandDetails?.images
        .where((image) => image.conditionId == null)
        .toList() ?? [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        value == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GalleryPage(
                              imagesList: attachments)),
                    ),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 0, bottom: 10, top: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorManager.primary,
                              ColorManager.primaryByOpacity.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        "attachments".tr(),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily:StringConstant.fontName),
                      ),
                    ),
                  ),
                ],
              ),
        value == 2
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GalleryPage(
                                isTawkeel: true,
                                imagesList: [ImagesModel(image: tawkeelImages!, conditionId: 0, type: 'type')],),),
                      ),
                      child: Text(
                        'tawkeel_image'.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                            color: ColorManager.primaryByOpacity,
                            decoration: TextDecoration.underline,
                            decorationColor:
                            ColorManager.primaryByOpacity,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily:StringConstant.fontName),
                      ),
                    ),
                  )
                ],
              )
            : const SizedBox(),
        value == 4
            ? Row(
                children: [
                  Container(
                    child: Text(
                      "recording_attorney_date".tr(),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 14,
                          fontFamily:StringConstant.fontName),
                    ),
                  ),
                  Container(
                    child: Text(
                      model.brandDetails!.brand.recordingDateOfSupply ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 14,
                          fontFamily:StringConstant.fontName),
                    ),
                  ),
                ],
              )
            : SizedBox(),
        value == 3
            ? Row(
                children: [
                  Container(
                    child: Text(
                      "date_undertaking_submit_attorney".tr(),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 14,
                          fontFamily:StringConstant.fontName),
                    ),
                  ),
                  Container(
                    child: Text(
                      model.brandDetails!.brand.dateOfUnderTaking ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 14,
                          fontFamily:StringConstant.fontName),
                    ),
                  ),
                ],
              )
            : SizedBox(),
      ],
    );
  }
}
