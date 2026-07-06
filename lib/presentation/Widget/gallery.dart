import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  final bool isTawkeel;
  final bool isBrandImage;
  final List<dynamic>? imagesList;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  static const MethodChannel _fileSaverChannel =
      MethodChannel('com.kytrademarks/file_saver');

  int activeIndex = 0;
  String activeImageUrl = '';
  bool downloading = false;
  bool downloadingPdf = false;

  List<String> imagesListOfString = [];

  String _fileUrl(dynamic imageModel) {
    final imagePath = imageModel.image?.toString() ?? '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    return '${ApiConstant.imagePath}$imagePath';
  }

  bool _isImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg']
        .any(path.endsWith);
  }

  bool _isPdfCompatibleImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.bmp'].any(path.endsWith);
  }

  String _downloadSuccessMessage() {
    if (widget.isTawkeel) {
      return 'pow_of_attr_down_succ'.tr();
    }
    if (widget.isBrandImage) {
      return 'image_downloded_succ'.tr();
    }
    return 'attachment_downloaded_succ'.tr();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorManager.primaryByOpacity,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Future<void> _openFileUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    throw Exception('Could not open file');
  }

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

  Future<void> _downloadCurrentAttachment() async {
    if (widget.imagesList == null ||
        widget.imagesList!.isEmpty ||
        activeIndex >= imagesListOfString.length) {
      return;
    }

    final url = imagesListOfString[activeIndex];

    setState(() {
      downloading = true;
    });

    try {
      if (kIsWeb || !_isImageUrl(url)) {
        await _openFileUrl(url);
        return;
      }

      final imageBytes = await _downloadImage(url);
      if (imageBytes == null) {
        throw Exception('Failed to download image');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePathFromUrl = Uri.tryParse(url)?.path ?? '';
      final extension = filePathFromUrl.contains('.')
          ? filePathFromUrl.split('.').last
          : 'jpg';
      final fileName =
          "attachment_${DateTime.now().millisecondsSinceEpoch}.$extension";
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      _showSnackBar(_downloadSuccessMessage());
    } catch (e) {
      print(e);
      _showSnackBar('download_failed'.tr());
    } finally {
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }
    }
  }

  Future<void> _downloadAttachmentsAsPdf() async {
    if (imagesListOfString.isEmpty) return;

    final imageUrls =
        imagesListOfString.where(_isPdfCompatibleImageUrl).toList();
    if (imageUrls.isEmpty) {
      _showSnackBar('no_images_for_pdf'.tr());
      return;
    }

    setState(() {
      downloadingPdf = true;
    });

    try {
      final document = pw.Document();

      for (final url in imageUrls) {
        final imageBytes = await _downloadImage(url);
        if (imageBytes == null) continue;

        final image = pw.MemoryImage(imageBytes);
        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            build: (_) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }

      final pdfBytes = await document.save();
      if (pdfBytes.lengthInBytes == 0) {
        throw Exception('Generated PDF is empty');
      }

      final fileName =
          'attachments_${DateTime.now().millisecondsSinceEpoch}.pdf';

      String? savedPath;
      if (!kIsWeb && Platform.isAndroid) {
        final tempDirectory = await getTemporaryDirectory();
        final tempFile = File('${tempDirectory.path}/$fileName');
        await tempFile.writeAsBytes(pdfBytes, flush: true);

        savedPath = await _fileSaverChannel.invokeMethod<String>(
          'savePdfFile',
          {
            'filePath': tempFile.path,
            'fileName': fileName,
          },
        );
      } else {
        savedPath = await FilePicker.saveFile(
          dialogTitle: 'download_attachments_pdf'.tr(),
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: const ['pdf'],
          bytes: pdfBytes,
        );
      }

      if (savedPath != null || kIsWeb) {
        _showSnackBar('file_downloaded_successfully'.tr());
      }
    } catch (e) {
      print(e);
      _showSnackBar('failed_to_download_file'.tr());
    } finally {
      if (mounted) {
        setState(() {
          downloadingPdf = false;
        });
      }
    }
  }

  getImagesListOfString() {
    if (widget.isTawkeel) {
      widget.imagesList!.map((e) {
        imagesListOfString.add(_fileUrl(e));
      }).toList();
    } else if (widget.imagesList != null && !widget.imagesList!.isEmpty) {
      widget.imagesList!.map((e) {
        imagesListOfString.add(_fileUrl(e));
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
      body: SafeArea(
        child: Column(
          children: [
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
            widget.imagesList == null ||
                    widget.imagesList!.isEmpty ||
                    widget.imagesList == []
                ? Expanded(
                    child: Center(
                      child: Text(
                        "no_images".tr(),
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  )
                : imagesListOfString.isEmpty
                    ? Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorManager.primary,
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return CarouselSlider.builder(
                                    options: CarouselOptions(
                                      height: constraints.maxHeight,
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
                                    itemCount: imagesListOfString.length,
                                    itemBuilder: (context, index, realIndex) {
                                      print(imagesListOfString[index]);
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: imagesListOfString[index]
                                                .toString()
                                                .contains('.pdf')
                                            ? cachedImage(
                                                ImagesConstants.pdfIcon)
                                            : cachedImage(
                                                imagesListOfString[index],
                                                height: constraints.maxHeight,
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width -
                                                        32,
                                                phWidth: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    40,
                                                fit: BoxFit.contain,
                                              ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSmoothIndicator(
                                    activeIndex: activeIndex,
                                    count: imagesListOfString.length,
                                    effect: WormEffect(
                                      dotColor:
                                          ColorManager.anotherTabBackGround,
                                      activeDotColor:
                                          ColorManager.primaryByOpacity,
                                      dotWidth: 10,
                                      dotHeight: 10,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    spacing: 20,
                                    runSpacing: 12,
                                    children: [
                                      InkWell(
                                        onTap: downloading
                                            ? null
                                            : _downloadCurrentAttachment,
                                        child: downloading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: ColorManager.primary,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                widget.isTawkeel
                                                    ? "download_power_attroney"
                                                        .tr()
                                                    : widget.isBrandImage
                                                        ? "download_image".tr()
                                                        : "download_attachment"
                                                            .tr(),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                      color:
                                                          ColorManager.primary,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                      ),
                                      InkWell(
                                        onTap: downloadingPdf
                                            ? null
                                            : _downloadAttachmentsAsPdf,
                                        child: downloadingPdf
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: ColorManager.primary,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                "download_attachments_pdf".tr(),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                      color:
                                                          ColorManager.primary,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
          ],
        ),
      ),
    );
  }
}
