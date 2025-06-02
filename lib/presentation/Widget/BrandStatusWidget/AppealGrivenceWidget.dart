import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import '../../../network/RestApi/Comman.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/ImagesConstant.dart';
import '../gallery.dart';

class AppealGrivenceWidget extends StatelessWidget {
  final BrandDetailsDataEntity brandDetailsDataEntity;
  final int number;

  const AppealGrivenceWidget(
      {super.key, required this.brandDetailsDataEntity, required this.number});

  @override
  Widget build(BuildContext context) {
    TextStyle? displayLarge =
        Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14);
    TextStyle? headline2 =
        Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14);
    return Card(
      elevation: 15,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
              padding: EdgeInsetsDirectional.only(top: 25, start: 5),
              decoration: BoxDecoration(
                  color: ColorManager.anotherTabBackGround,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(ImagesConstants.status),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                stateOfBrand(
                                    displayLarge,
                                    brandDetailsDataEntity
                                        .AllResult[number].states,
                                    brandDetailsDataEntity
                                        .AllResult[number].created_at),

                                const SizedBox(
                                  height: 5,
                                ),

                                /// DATA OF ObjectionInGrievanceWidget
                                checkNullValue(
                                        value: brandDetailsDataEntity
                                            .AllResult[number]
                                            .theDateOfPaymentOfTheAppealFee)
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "appeal_fees_date".tr(),
                                            style: displayLarge,
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(end: 10),
                                            child: Text(
                                                "${brandDetailsDataEntity.AllResult[number].theDateOfPaymentOfTheAppealFee}"),
                                          )),
                                        ],
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 5,
                                ),
                                checkNullValue(
                                        value: brandDetailsDataEntity
                                            .AllResult[number].appealDecision)
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "appeal_decision".tr(),
                                            style: displayLarge,
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(end: 10),
                                            child: Text(
                                              "${brandDetailsDataEntity.AllResult[number].appealDecision}",
                                              style: headline2,
                                            ),
                                          )),
                                        ],
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 5,
                                ),

                                checkNullValue(
                                        value: brandDetailsDataEntity
                                            .AllResult[number].appealNotes)
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "note".tr(),
                                            style: displayLarge,
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(end: 10),
                                            child: Text(
                                              "${brandDetailsDataEntity.AllResult[number].appealNotes}",
                                              style: headline2,
                                            ),
                                          )),
                                        ],
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          )
                        ]),
                    brandDetailsDataEntity
                        .AllResult[number].appealGrivenceGallery==null||brandDetailsDataEntity
                        .AllResult[number].appealGrivenceGallery!.isEmpty||brandDetailsDataEntity
                        .AllResult[number].appealGrivenceGallery==[]
                        ? InkWell(
                      onTap: () => null,
                      child: Container(
                        margin:
                        EdgeInsetsDirectional.only(end: 10, bottom: 10),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorManager.primary,
                                ColorManager.primaryByOpacity
                                    .withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "no_Attachments".tr(),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ) :Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GalleryPage(
                                      imagesList: brandDetailsDataEntity
                                          .AllResult[number].appealGrivenceGallery,
                                    )),
                          ),
                          child: Container(
                            margin:
                                EdgeInsetsDirectional.only(end: 10, bottom: 10),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]))),
    );
  }
}
