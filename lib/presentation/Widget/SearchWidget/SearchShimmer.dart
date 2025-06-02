import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../resources/Color_Manager.dart';

class SearchShimmer extends StatelessWidget {
  const SearchShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Shimmer.fromColors(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
                SizedBox(
                  width: 10,
                ),
                Shimmer.fromColors(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 200,
                        height: 20,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12)),
                        width: 250,
                        height: 20,
                      ),
                    ],
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
