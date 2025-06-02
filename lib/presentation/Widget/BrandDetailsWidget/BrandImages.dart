import 'package:flutter/material.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import '../../../core/Constant/Api_Constant.dart';
import '../../../network/RestApi/Comman.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';
import '../gallery.dart';

class BrandImages extends StatelessWidget {
  final GetBrandDetailsProvider model;
  final GlobalKey tutorialKey;

  const BrandImages({required this.model, required this.tutorialKey});

  @override
  Widget build(BuildContext context) {
    // Get the screen width to make the image size responsive
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate the image width based on screen width (e.g., 30% of screen width, with a min and max)
    final imageWidth = (screenWidth * 0.3)
        .clamp(120.0, 180.0); // Adjusted for better visibility

    return SizedBox(
      height: 200, // Increased height to accommodate larger images
      child: Stack(
        children: [
          // Gradient background
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primaryByOpacity.withValues(alpha: 0.9),
                  ColorManager.primary,
                ],
              ),
            ),
          ),
          // Centered image container
          Positioned(
            top: 50,
            left: 0,
            right: 0, // Use left and right to center the container
            child: Center(
              child: model.brandDetails != null
                  ? Container(
                      key: tutorialKey,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryPage(
                              isBrandImage: true,
                              imagesList: model.brandDetails!.images,
                            ),
                          ),
                        ),
                        child: model.brandDetails!.images.isEmpty
                            ? SizedBox(
                                width: imageWidth,
                                child: Image.asset(
                                  'assets/images/plashHolder.png',
                                  fit: BoxFit.contain, // Preserve aspect ratio
                                ),
                              )
                            : SizedBox(
                                width: imageWidth,
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  // Adjust based on your image's aspect ratio
                                  child: PageView(
                                    children:
                                        model.brandDetails!.images.map((e) {
                                      print('qqqqq${e.image}');
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child:
                                            e.image.toString().contains('.pdf')
                                                ? cachedImage(null)
                                                : cachedImage(
                                                    "${ApiConstant.imagePath}${e.image}",
                                                    fit: BoxFit
                                                        .contain, // Preserve aspect ratio
                                                  ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                      ),
                    )
                  : Container(
                      width: imageWidth,
                      color: Colors.white,
                      child: cachedImage(null),
                    ),
            ),
          ),
          // Back arrow
          PositionedDirectional(
            top: 25,
            start: 16,
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
