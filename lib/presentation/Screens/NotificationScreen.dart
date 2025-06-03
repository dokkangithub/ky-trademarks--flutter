import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:kyuser/app/RequestState/RequestState.dart';
import 'package:kyuser/network/RestApi/Comman.dart';
import 'package:kyuser/presentation/Controllar/notificationModel/notificationProvider.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:shimmer/shimmer.dart';

import '../../resources/ImagesConstant.dart';
import '../../resources/StringManager.dart';
import 'brand details/BrandDetails.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .getUserNotification();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorManager.primaryByOpacity,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "notification".tr(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18,fontFamily:StringConstant.fontName),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, model, _) {
          if (model.state == RequestState.loading) {
            return ListView.builder(
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 16,
                              color: Colors.white,
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: MediaQuery.of(context).size.width - 90,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Divider(height: 25),
                    ),
                  ],
                ),
              ),
              itemCount: 20,
            );
          }
          if (model.state == RequestState.failed) {
            return Text("something_wrong".tr(),style: TextStyle(fontFamily:StringConstant.fontName),);
          }
          if (model.state == RequestState.loaded) {
            return model.notification!.length == 0
                ? Column(
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          Lottie.asset(ImagesConstants.noData,
                              width: 380, height: 410, fit: BoxFit.contain),
                          Text(
                            StringConstant.noDataFound,
                            style: TextStyle(
                              fontFamily:StringConstant.fontName,
                              color: ColorManager.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          Lottie.asset(ImagesConstants.noData,
                              width: 380, height: 410, fit: BoxFit.contain),
                          Text(
                            StringConstant.noDataFound,
                            style: TextStyle(
                              fontFamily:StringConstant.fontName,
                              color: ColorManager.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(top: 10, left: 14, right: 14),
                    itemCount: model.notification!.length,
                    itemBuilder: (context, index) => InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            if (model.notification![index].id != 0) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => BranDetails(
                                        brandId: model.notification![index].id,
                                      )));
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: ColorManager.white)),
                                      child: cachedImage(null,
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.contain)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.notification![index].title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(
                                                fontSize: 17,
                                                color: Colors.black,fontFamily:StringConstant.fontName),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                90,
                                        child: Text(
                                          model.notification![index].content,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                  fontSize: 14,
                                              fontFamily:StringConstant.fontName,
                                                  color: ColorManager.accent),
                                          maxLines: 2,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Divider(
                                    height: 25,
                                  )),
                            ],
                          ),
                        ));
          }
          return SizedBox();
        },
      ),
    );
  }
}
