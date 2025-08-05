import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/Constant/Api_Constant.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/Color_Manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class GalleryPage extends StatefulWidget {
  GalleryPage({
    this.isTawkeel = false,
    this.isBrandImage = false,
    this.imagesList,
  });

  bool isTawkeel;
  bool isBrandImage;
  List<dynamic>? imagesList;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int activeIndex = 0;
  String activeImageUrl = '';
  bool downloading = false;

  List<String> imagesListOfString = [];

  // Add this function to download image as bytes
  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }

  getImagesListOfString() {
    if (widget.isTawkeel) {
      widget.imagesList!.map((e) {
        imagesListOfString.add('${ApiConstant.imagePath}${e.image}');
      }).toList();
    } else if (widget.imagesList != null && !widget.imagesList!.isEmpty) {
      widget.imagesList!.map((e) {
        imagesListOfString.add("${ApiConstant.imagePath}${e.image}");
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    if (mounted) {
      getImagesListOfString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.imagesList);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 20),
              child: IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          widget.imagesList == null ||
                  widget.imagesList!.isEmpty ||
                  widget.imagesList == []
              ? Expanded(
                  child: Center(
                    child: Text(
                      "no_images".tr(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              : imagesListOfString.isEmpty
                  ? CircularProgressIndicator(
                      color: ColorManager.primary,
                    )
                  : Column(
                      children: [
                        CarouselSlider.builder(
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * .72,

                            // aspectRatio: 16/9,
                            viewportFraction: 1,
                            padEnds: false,

                            initialPage: 0,
                            enableInfiniteScroll: false,
                            reverse: false,
                            autoPlay: false,

                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            enlargeFactor: 0.3,
                            onPageChanged: (index, _) {
                              setState(() {
                                activeIndex = index;
                              });
                            },
                            scrollDirection: Axis.horizontal,
                          ),
                          // items: widget.imagesList!.map((e) {
                          //
                          //   return ClipRRect(
                          //       borderRadius: BorderRadius.circular(10),
                          //       child: cachedImage("${ApiConstant.imagePath}${e.image}",
                          //           fit: BoxFit.cover));
                          // }).toList(),-
                          itemCount: imagesListOfString.length,
                          itemBuilder: (context, index, realIndex) {
                            print(imagesListOfString[index]);
                            return ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: imagesListOfString[index]
                                        .toString()
                                        .contains('.pdf')
                                    ? cachedImage(ImagesConstants.pdfIcon)
                                    : cachedImage(imagesListOfString[index],
                                        height: MediaQuery.sizeOf(context).height-100,
                                        width: MediaQuery.sizeOf(context).width-100,
                                        phWidth:
                                            MediaQuery.of(context).size.width -
                                                40,
                                        fit: BoxFit.contain));
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // widget.isBrandImage?SizedBox():
                        AnimatedSmoothIndicator(
                          activeIndex: activeIndex,
                          count: imagesListOfString.length,
                          effect: WormEffect(
                              dotColor: ColorManager.anotherTabBackGround,
                              activeDotColor: ColorManager.primaryByOpacity,
                              dotWidth: 10,
                              dotHeight: 10),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            if (kIsWeb) {
                              if (kIsWeb) {
                                // Web-specific behavior: Open in new tab
                                try {
                                  await launch(
                                      "${ApiConstant.baseUrl}${widget.imagesList![activeIndex].image}");
                                  setState(() {
                                    downloading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    downloading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          ColorManager.primaryByOpacity,
                                      content: Text(
                                        'Error opening file: $e',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                setState(() {
                                  downloading = true;
                                });
                                if (![
                                  '.jpg',
                                  '.jpeg',
                                  '.png',
                                  '.gif',
                                  '.webp',
                                  '.bmp',
                                  '.svg'
                                ].any((ext) => widget.imagesList![activeIndex]
                                    .toString()
                                    .toLowerCase()
                                    .contains(ext))) {
                                  print(widget.isBrandImage);
                                  launch(
                                      "${ApiConstant.baseUrl}${widget.imagesList![activeIndex].image}");

                                  setState(() {
                                    downloading = false;
                                  });
                                } else {
                                  String url = imagesListOfString[activeIndex];

                                  try {
                                    // Download the image as bytes
                                    final Uint8List? imageBytes =
                                        await _downloadImage(url);
                                    if (imageBytes != null) {
                                      // Use path_provider instead of ImageGallerySaver
                                      final directory = await getApplicationDocumentsDirectory();
                                      final fileName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
                                      final filePath = '${directory.path}/$fileName';
                                      
                                      // Write the file
                                      final file = File(filePath);
                                      await file.writeAsBytes(imageBytes);

                                      setState(() {
                                        downloading = false;
                                      });

                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: ColorManager.primaryByOpacity,
                                          content: Text(
                                            widget.isTawkeel
                                                ? 'pow_of_attr_down_succ'.tr()
                                                : widget.isBrandImage
                                                    ? 'image_downloded_succ'.tr()
                                                    : "attachment_downloaded_succ".tr(),
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      throw Exception('Failed to download image');
                                    }
                                  } catch (e) {
                                    setState(() {
                                      downloading = false;
                                    });
                                    print(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            ColorManager.primaryByOpacity,
                                        content: Text(
                                          e.toString(),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: downloading
                              ? CircularProgressIndicator(
                                  color: ColorManager.primary,
                                )
                              : Text(
                                  widget.isTawkeel
                                      ? "download_power_attroney".tr()
                                      : widget.isBrandImage
                                          ? "download_image".tr()
                                          : "download_attachment".tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                          color: ColorManager.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )
        ],
      ),
    );
  }
}
