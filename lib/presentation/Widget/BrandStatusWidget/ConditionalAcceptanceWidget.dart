import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kyuser/domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';

import '../../../network/RestApi/Comman.dart';
import '../../../resources/Color_Manager.dart';
import '../../../resources/ImagesConstant.dart';
import '../gallery.dart';

class ConditionalAcceptanceWidget extends StatelessWidget {
  final BrandDetailsDataEntity brandDetailsDataEntity;
  final int number;

  const ConditionalAcceptanceWidget(
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
                              brandDetailsDataEntity.AllResult[number].states,
                              brandDetailsDataEntity
                                  .AllResult[number].created_at),

                          /// DATA OF ACCEPT

                          checkNullValue(
                                  value: data.admissionStatusDateConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "acceptance_date".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${data.admissionStatusDateConditional}",
                                        style: headline2,
                                      ),
                                    )),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data.admissionStatusDateConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(value: data.recordConditional)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "tadween".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${data.recordConditional}",
                                        style: headline2,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(value: data.recordConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value:
                                      data.publicityFeePaymentDateConditional)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "fees_payment_date".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${data.publicityFeePaymentDateConditional}",
                                        style: headline2,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value:
                                      data.publicityFeePaymentDateConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(value: data.publishDateConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "publish_date".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${data.publishDateConditional}",
                                            style: headline2,
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(value: data.publishDateConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data.numberOfNewspaperConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "edition_number".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${data.numberOfNewspaperConditional}",
                                            style: headline2,
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data.numberOfNewspaperConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data.notifyTheStudentOfTheOpposition)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "informing_oppostion".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${brandDetailsDataEntity.AllResult[number].notifyTheStudentOfTheOpposition}",
                                        style: headline2,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data.notifyTheStudentOfTheOpposition)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),
                          checkNullValue(
                                  value: data.exhibitionDetailsConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "opposition_details".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${brandDetailsDataEntity.AllResult[number].exhibitionDetailsConditional}",
                                        style: headline2,
                                      ),
                                    )),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data.exhibitionDetailsConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data
                                      .firstNotificationOfTheOppositionApostate)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "returned_opposition1".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${brandDetailsDataEntity.AllResult[number].firstNotificationOfTheOppositionApostate}",
                                        style: headline2,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data
                                      .firstNotificationOfTheOppositionApostate)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data
                                      .secondNotificationOfTheOppositionApostate)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "returned_opposition2".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${brandDetailsDataEntity.AllResult[number].secondNotificationOfTheOppositionApostate}",
                                        style: headline2,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data
                                      .secondNotificationOfTheOppositionApostate)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data
                                      .theApplicantResponseToTheObjectionConditional)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "response_opposition".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${brandDetailsDataEntity.AllResult[number].theApplicantResponseToTheObjectionConditional}",
                                        style: headline2,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data
                                      .theApplicantResponseToTheObjectionConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data
                                      .theDateOfTheHearingSessionConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "testimony_hearing".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${brandDetailsDataEntity.AllResult[number].theDateOfTheHearingSessionConditional}",
                                            style: headline2,
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data
                                      .theDateOfTheHearingSessionConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data
                                      .decisionOfTheExhibitionCommitteeConditional)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "opposition_decision".tr(),
                                      style: displayLarge,
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                end: 10),
                                        child: Text(
                                          "${brandDetailsDataEntity.AllResult[number].decisionOfTheExhibitionCommitteeConditional}",
                                          style: headline2,
                                          textAlign: TextAlign.start,
                                        )),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data
                                      .decisionOfTheExhibitionCommitteeConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data
                                      .dateOfPaymentOfTheRegistrationFeeConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "registration_fees_date".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          end: 10),
                                      child: Text(
                                        "${brandDetailsDataEntity.AllResult[number].dateOfPaymentOfTheRegistrationFeeConditional}",
                                        style: headline2,
                                      ),
                                    )),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data
                                      .dateOfPaymentOfTheRegistrationFeeConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(value: data.recordConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "renewal_date".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${brandDetailsDataEntity.AllResult[number].recordConditional}",
                                            style: headline2,
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(value: data.recordConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data.dateOfRegistrationConditional)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "registration_date".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${brandDetailsDataEntity.AllResult[number].dateOfRegistrationConditional}",
                                            style: headline2,
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data.dateOfRegistrationConditional)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),

                          checkNullValue(
                                  value: data.noteTheConditionalAcceptance)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "acceptance_note".tr(),
                                      style: displayLarge,
                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 10),
                                          child: Text(
                                            "${brandDetailsDataEntity.AllResult[number].noteTheConditionalAcceptance}",
                                            style: headline2,
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          !checkNullValue(
                                  value: data.noteTheConditionalAcceptance)
                              ? SizedBox.shrink()
                              : const SizedBox(
                                  height: 5,
                                ),
                        ],
                      ),
                    )
                  ]),
              brandDetailsDataEntity
                  .AllResult[number].conditionalAcceptanceGallery==null||brandDetailsDataEntity
                  .AllResult[number].conditionalAcceptanceGallery!.isEmpty||brandDetailsDataEntity
                  .AllResult[number].conditionalAcceptanceGallery==[]
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
                                    .AllResult[number].conditionalAcceptanceGallery,
                              )),
                    ),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(end: 10, bottom: 10),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
