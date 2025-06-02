import 'package:flutter/material.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBrandDetails extends StatelessWidget {
  const ShimmerBrandDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  child: Shimmer.fromColors(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 60),
                      width: MediaQuery.of(context).size.width,
                      height: 180,
                      decoration: BoxDecoration(
                        color: ColorManager.primary,
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 120,
                  child: Shimmer.fromColors(
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                          color: ColorManager.primary,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius: BorderRadius.circular(12)),
                            width: 140,
                            height: 20,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius: BorderRadius.circular(12)),
                            width: 150,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                ),
                Expanded(
                  child: Shimmer.fromColors(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius: BorderRadius.circular(12)),
                            width: 140,
                            height: 20,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius: BorderRadius.circular(12)),
                            width: 180,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Shimmer.fromColors(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Shimmer.fromColors(
                    child: Container(
                      width: 250,
                      height: 20,
                      margin: EdgeInsetsDirectional.only(start: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorManager.primary,
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ]),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Shimmer.fromColors(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Shimmer.fromColors(
                    child: Container(
                      width: 250,
                      height: 20,
                      margin: EdgeInsetsDirectional.only(start: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorManager.primary,
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ]),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Shimmer.fromColors(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Shimmer.fromColors(
                    child: Container(
                      width: 250,
                      height: 20,
                      margin: EdgeInsetsDirectional.only(start: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorManager.primary,
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ]),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Shimmer.fromColors(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Shimmer.fromColors(
                    child: Container(
                      width: 250,
                      height: 20,
                      margin: EdgeInsetsDirectional.only(start: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorManager.primary,
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ]),
            SizedBox(
              height: 20,
            ),
            Stack(children: [
              Shimmer.fromColors(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Shimmer.fromColors(
                    child: Container(
                      width: 250,
                      height: 20,
                      margin: EdgeInsetsDirectional.only(start: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorManager.primary,
                      ),
                    ),
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
