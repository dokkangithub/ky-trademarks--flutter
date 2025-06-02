import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kyuser/presentation/Widget/gallery.dart';

import '../../../resources/Color_Manager.dart';
import '../../../resources/ImagesConstant.dart';

class proccessingWidget extends StatelessWidget {
  const proccessingWidget({Key? key, required this.data, required this.index})
      : super(key: key);

  final List data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
              color: ColorManager.anotherTabBackGround,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 20, right: 10, left: 10),
                          child: SvgPicture.asset(ImagesConstants.status),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  top: 4, end: 15),
                              child: Text(
                                data[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontSize: 14),
                              ),
                            ),
                            Text(
                              "${DateFormat('EEEE , d MMM, yyyy').format(DateTime.parse(data[index].created_at))}",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                      fontSize: 14,
                                      color: ColorManager.primaryByOpacity),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  data[index].processingGallery == null ||
                          data[index].processingGallery!.isEmpty ||
                          data[index].processingGallery == []
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
                  )
                      : InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GalleryPage(
                                      imagesList: data[index].processingGallery,
                                    )),
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
