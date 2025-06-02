import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kyuser/domain/BrandDetails/Entities/BrandDetailsDataEntity.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import '../../../network/RestApi/Comman.dart';
import '../../../resources/Color_Manager.dart';
import '../gallery.dart';

class AcceptWidget extends StatelessWidget {
  final AllResult brandDetailsDataEntity;

  const AcceptWidget({super.key, required this.brandDetailsDataEntity});

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
                        /// DATA OF ACCEPT
                        stateOfBrand(displayLarge, brandDetailsDataEntity.states,
                            brandDetailsDataEntity.created_at),
                        SizedBox(height: 8),
                        checkNullValue(
                                value:
                                    brandDetailsDataEntity.admissionStatusDate)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("acceptance_date".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.admissionStatusDate}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        checkNullValue(value: brandDetailsDataEntity.record)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("tadween".tr(), style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.record}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(value: brandDetailsDataEntity.record)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .publicityFeePaymentDate)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("fees_payment_date".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.publicityFeePaymentDate}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity
                                    .publicityFeePaymentDate)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity.publishDate)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("publish_date".tr(), style: headline2),
                                  Expanded(
                                    child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 10),
                                        child: Text(
                                            "${brandDetailsDataEntity.publishDate}",
                                            style: displayLarge)),
                                  )
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity.publishDate)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity.numberOfNewspaper)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("edition_number".tr(), style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.numberOfNewspaper}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity.numberOfNewspaper)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .notifyTheStudentOfOpposition)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("informing_oppostion".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        textAlign: TextAlign.start,
                                        "${brandDetailsDataEntity.notifyTheStudentOfOpposition}",
                                        style: displayLarge),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .replyImportNumOpposition)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("reply_num_opposition".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.replyImportNumOpposition}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .dateNotifyTheStudentOfOpposition)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("import_date_opposition".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.dateNotifyTheStudentOfOpposition}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        checkNullValue(
                                value: brandDetailsDataEntity.opposition_note)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("opposition_note".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.opposition_note}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity.opposition_note)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity.exhibitionDetails)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("opposition_details".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.exhibitionDetails}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity.exhibitionDetails)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .firstNoticeOfOppositionApostate)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("returned_opposition1".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.firstNoticeOfOppositionApostate}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity
                                    .firstNoticeOfOppositionApostate)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .secondNoticeOfOppositionApostate)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("returned_opposition2".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.secondNoticeOfOppositionApostate}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity
                                    .secondNoticeOfOppositionApostate)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .theApplicantResponseToTheObjection)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("response_opposition".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.theApplicantResponseToTheObjection}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .theDateOfTheHearingSession)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("testimony_hearing".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.theDateOfTheHearingSession}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity
                                    .theDateOfTheHearingSession)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .decisionOfTheExhibitionCommittee)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("opposition_decision".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.decisionOfTheExhibitionCommittee}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity
                                    .decisionOfTheExhibitionCommittee)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity
                                    .dateOfPaymentOfTheRegistrationFee)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("registration_fees_date".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.dateOfPaymentOfTheRegistrationFee}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity
                                    .dateOfPaymentOfTheRegistrationFee)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity.renewalDate)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("expiration_date".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.renewalDate}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value: brandDetailsDataEntity.renewalDate)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value:
                                    brandDetailsDataEntity.dateOfRegistration)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("registration_date".tr(),
                                      style: headline2),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                        "${brandDetailsDataEntity.dateOfRegistration}",
                                        style: displayLarge),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        !checkNullValue(
                                value:
                                    brandDetailsDataEntity.dateOfRegistration)
                            ? SizedBox.shrink()
                            : const SizedBox(
                                height: 5,
                              ),
                        checkNullValue(
                                value: brandDetailsDataEntity.acceptanceNote)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("acceptance_note".tr(),
                                      style: headline2),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    child: Text(
                                      "${brandDetailsDataEntity.acceptanceNote}",
                                      style: displayLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 15,
                        ),
                        brandDetailsDataEntity
                            .acceptGallery==null||brandDetailsDataEntity
                            .acceptGallery!.isEmpty||brandDetailsDataEntity
                            .acceptGallery==[]
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
                        ) : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GalleryPage(
                                          imagesList: brandDetailsDataEntity
                                              .acceptGallery,
                                        )),
                              ),
                              child: Container(
                                margin: EdgeInsetsDirectional.only(
                                    end: 10, bottom: 10),
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
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
