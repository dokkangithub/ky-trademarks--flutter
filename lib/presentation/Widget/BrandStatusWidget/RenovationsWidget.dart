import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import '../../../network/RestApi/Comman.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/ImagesConstant.dart';
import '../gallery.dart';

class RenovationsWidget extends StatelessWidget {
  final BrandDetailsDataEntity brandDetailsDataEntity;
  final int number;

  const RenovationsWidget(
      {super.key, required this.brandDetailsDataEntity, required this.number});

  @override
  Widget build(BuildContext context) {
    TextStyle? displayLarge =
        Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14);
    TextStyle? headline2 =
        Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14);
    var data = brandDetailsDataEntity.AllResult[number];
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
                                              .AllResult[number].states ==
                                          "التجديدات"
                                      ? 'مجددة'
                                      : brandDetailsDataEntity
                                          .AllResult[number].states,
                                  brandDetailsDataEntity
                                      .AllResult[number].created_at),

                              const SizedBox(
                                height: 5,
                              ),

                              /// DATA OF RenovationsWidget

                              checkNullValue(value: data.dateOfRenewalStatus)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "date_renewal_fees".tr(),
                                          style: headline2,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            " ${data.dateOfRenewalStatus}",
                                            style: displayLarge,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 5,
                              ),

                              checkNullValue(value: data.dateOfRenewalFee)
                                  ? Row(
                                      children: [
                                        Text(
                                          "renewal_date".tr(),
                                          style: headline2,
                                        ),
                                        Expanded(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(end: 10),
                                              child: Text(
                                                " ${data.dateOfRenewalFee}",
                                                style: displayLarge,
                                              )),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 5,
                              ),

                              checkNullValue(value: data.renewalDateRenovations)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "expiration_date".tr(),
                                          style: headline2,
                                        ),
                                        Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(end: 10),
                                            child: Text(
                                              " ${data.renewalDateRenovations}",
                                              style: displayLarge,
                                              textAlign: TextAlign.start,
                                            )),
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 5,
                              ),

                              checkNullValue(value: data.renewalPeriod)
                                  ? Row(
                                      children: [
                                        Text(
                                          "renewal_period".tr(),
                                          style: headline2,
                                        ),
                                        Expanded(
                                            child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${data.renewalPeriod}",
                                            style: displayLarge,
                                          ),
                                        )),
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ))
                        ]),
                    brandDetailsDataEntity
                        .AllResult[number].renovationsGallery==null||brandDetailsDataEntity
                        .AllResult[number].renovationsGallery!.isEmpty||brandDetailsDataEntity
                        .AllResult[number].renovationsGallery==[]
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
                                          .AllResult[number].renovationsGallery,
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
