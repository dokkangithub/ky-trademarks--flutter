import 'dart:io';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kyuser/presentation/Screens/contacts/contacts.dart';
import 'package:kyuser/resources/ImagesConstant.dart';
import 'package:kyuser/utilits/Local_User_Data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../app/RequestState/RequestState.dart';
import '../../core/Constant/Api_Constant.dart';
import '../../data/Brand/DataSource/GetBrandRemotoData.dart';
import '../../domain/Brand/Entities/BrandEntity.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/Color_Manager.dart';
import '../Controllar/GetSuccessPartners.dart';
import '../Controllar/userProvider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PageController controller = PageController(initialPage: 0);
  int pages = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetSuccessPartners>(context, listen: false).getSuccessPartners();
      Provider.of<GetUserProvider>(context, listen: false).getUserData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen is a large screen based on width
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 1200 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 24 : 0,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context, isLargeScreen),
                      const SizedBox(height: 20),
                      _buildHelpCenterCard(context, isLargeScreen),
                      const SizedBox(height: 20),
                      _buildPartnersSection(context, isLargeScreen),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Header with user profile
  Widget _buildHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: isLargeScreen
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : BorderRadius.zero,
        gradient: LinearGradient(
          colors: [
            ColorManager.primaryByOpacity.withOpacity(0.9),
            ColorManager.primary,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: isLargeScreen ? 40 : 16,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isLargeScreen ? 4 : 0,
          color: isLargeScreen
              ? Colors.white
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildUserProfileInfo(context),
          ),
        ),
      ),
    );
  }

  // User profile info widget
  Widget _buildUserProfileInfo(BuildContext context) {
    return Consumer<GetUserProvider>(
      builder: (context, userProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildProfileAvatar(userProvider),
                  const SizedBox(width: 14),
                  _buildUserInfo(context, userProvider),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildStatusBadge(context),
          ],
        );
      },
    );
  }

  // Profile avatar with image picker
  Widget _buildProfileAvatar(GetUserProvider userProvider) {
    return GestureDetector(
      onTap: () {
        if (userProvider.state == RequestState.loaded && userProvider.userData != null) {
          _showAvatarFullScreen(userProvider.userData!.avatar);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: userProvider.state == RequestState.loaded && userProvider.userData != null
                ? cachedImage(
              ApiConstant.imagePathUser + userProvider.userData!.avatar,
              width: 80,
              height: 80,
              fit: BoxFit.fill,
              placeHolderFit: BoxFit.cover,
            )
                : Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: cachedImage(
                null,
                width: 80,
                height: 80,
                fit: BoxFit.fill,
                placeHolderFit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildImagePickerButton(userProvider),
          ),
        ],
      ),
    );
  }

  // Image picker button
  Widget _buildImagePickerButton(GetUserProvider userProvider) {
    return InkWell(
      onTap: () async {
        await _pickAndUpdateAvatar(userProvider);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  // User info display
  Widget _buildUserInfo(BuildContext context, GetUserProvider userProvider) {
    return Expanded(
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userProvider.state == RequestState.loaded && userProvider.userData != null
                ? userProvider.userData!.name
                : globalAccountData.getUsername().toString(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: ColorManager.white,
              fontSize: 17,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            userProvider.state == RequestState.loaded && userProvider.userData != null
                ? userProvider.userData!.email
                : globalAccountData.getEmail().toString(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: kIsWeb? ColorManager.primary:ColorManager.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: ColorManager.lightGrey.withOpacity(0.9),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.online_prediction,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                "active".tr(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Help center card widget
  Widget _buildHelpCenterCard(BuildContext context, bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 0 : 15),
      width: isLargeScreen ? 600 : double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black54.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 5),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "help_center".tr(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 20),
            // Help center options
            _buildHelpOption(
              context,
              text: 'help'.tr(),
              image: ImagesConstants.askHelp,
              onTap: _handleContactUs,
            ),
            _buildHelpOption(
              context,
              text: 'rate_us'.tr(),
              image: ImagesConstants.rateUs,
              onTap: _launchRateApp,
            ),
            _buildHelpOption(
              context,
              text: 'contact_us'.tr(),
              image: ImagesConstants.contactUs,
              onTap: _handleContactUsTap,
            ),
            _buildHelpOption(
              context,
              text: 'logout'.tr(),
              image: ImagesConstants.logout,
              transform: true,
              onTap: _handleLogoutTap,
            ),
          ],
        ),
      ),
    );
  }

  // Individual help option item
  Widget _buildHelpOption(
      BuildContext context, {
        required String text,
        required VoidCallback onTap,
        String? image,
        bool transform = false,
      }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: image == null
                    ? const Icon(
                  Icons.power_settings_new_outlined,
                  color: Colors.grey,
                )
                    : transform
                    ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14),
                  child: Image.asset(
                    image,
                    width: 30,
                    height: 30,
                  ),
                )
                    : Image.asset(
                  image,
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Divider(),
          )
        ],
      ),
    );
  }

  // Partners section
  Widget _buildPartnersSection(BuildContext context, bool isLargeScreen) {
    return Consumer<GetSuccessPartners>(
      builder: (context, model, _) {
        if (model.state == RequestState.loading) {
          return _buildPartnersLoadingState(isLargeScreen);
        } else if (model.state == RequestState.failed) {
          return _buildPartnersFailedState(isLargeScreen);
        } else if (model.allPartnerSuccess == null || model.allPartnerSuccess!.isEmpty) {
          return Text("no_data".tr());
        } else {
          return _buildPartnersContent(context, model, isLargeScreen);
        }
      },
    );
  }

  // Partners loading state
  Widget _buildPartnersLoadingState(bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Shimmer.fromColors(
            child: Container(
              width: 120,
              height: 60,
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            baseColor: ColorManager.primary,
            highlightColor: ColorManager.primaryByOpacity,
          ),
          SizedBox(height: 20),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 16,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8 / 1.7,
              crossAxisCount: isLargeScreen ? 8 : 4,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Shimmer.fromColors(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                baseColor: ColorManager.primary,
                highlightColor: ColorManager.primaryByOpacity,
              );
            },
          ),
        ],
      ),
    );
  }

  // Partners failed state
  Widget _buildPartnersFailedState(bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Shimmer.fromColors(
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            baseColor: ColorManager.primary,
            highlightColor: ColorManager.primaryByOpacity,
          ),
          const SizedBox(height: 20),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 16,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8 / 1.7,
              crossAxisCount: isLargeScreen ? 8 : 4,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Shimmer.fromColors(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                baseColor: ColorManager.primary,
                highlightColor: ColorManager.primaryByOpacity,
              );
            },
          ),
        ],
      ),
    );
  }

  // Partners content
  Widget _buildPartnersContent(
      BuildContext context,
      GetSuccessPartners model,
      bool isLargeScreen
      ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 0 : 15),
      child: Column(
        children: [
          _buildPartnersHeader(context),
          const SizedBox(height: 20),
          isLargeScreen
              ? _buildPartnersGrid(context, model.allPartnerSuccess!)
              : _buildPartnersPageView(context, model.allPartnerSuccess!),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Partners header with title
  Widget _buildPartnersHeader(BuildContext context) {
    return Container(
      height: 80,
      width: 230,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            ColorManager.primaryByOpacity.withValues(alpha: 0.9),
            ColorManager.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "success_partner".tr(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (!kIsWeb)
            Consumer<GetSuccessPartners>(
              builder: (context, model, _) {
                return DotsIndicator(
                  dotsCount: (model.allPartnerSuccess!.length / 3).ceil(),
                  position: double.parse(pages.toString()),
                  decorator: DotsDecorator(
                    size: const Size.square(7.0),
                    activeColor: Colors.white,
                    color: ColorManager.lightGrey.withValues(alpha: 0.5),
                    activeSize: const Size(22.0, 5.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                );
              },
            ),

        ],
      ),
    );
  }

  // Partners grid view (for large screens)
  Widget _buildPartnersGrid(BuildContext context, List<BrandImages> partners) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: partners.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          crossAxisCount: 6,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildPartnerItem(partners[index]);
        },
      ),
    );
  }

  // Partners page view (for small screens)
  Widget _buildPartnersPageView(BuildContext context, List<BrandImages> partners) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 60),
      height: MediaQuery.of(context).size.width * .29,
      child: PageView.builder(
        onPageChanged: (page) {
          setState(() {
            pages = page;
          });
        },
        scrollDirection: Axis.horizontal,
        allowImplicitScrolling: true,
        controller: controller,
        physics: const BouncingScrollPhysics(),
        itemCount: (partners.length / 3).ceil(),
        itemBuilder: (BuildContext context, int pageIndex) {
          int startIndex = pageIndex * 3;
          int endIndex = (startIndex + 3 < partners.length)
              ? startIndex + 3
              : partners.length;

          List<BrandImages> pageItems = partners.sublist(startIndex, endIndex);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: pageItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: MediaQuery.of(context).size.width * .29,
                width: MediaQuery.of(context).size.width * .29,
                child: _buildPartnerItem(pageItems[index]),
              );
            },
          );
        },
      ),
    );
  }

  // Individual partner item
  Widget _buildPartnerItem(BrandImages partner) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: .5,
          color: ColorManager.primary.withOpacity(.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: cachedImage(
          ApiConstant.imagePathPartners + partner.image,
          placeHolderFit: BoxFit.contain,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Show avatar in full screen
  void _showAvatarFullScreen(String avatar) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: cachedImage(
              ApiConstant.imagePathUser + avatar,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  // Pick and update avatar
  Future<void> _pickAndUpdateAvatar(GetUserProvider userProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await userProvider.updateUserAvatar(avatarFile: imageFile);
    }
  }

  // Handler for help option
  void _handleContactUs() async {
    try {
      print('Starting _handleContactUs');
      final getBrandRemoteData = GetBrandRemoteData();

      final String phoneNumber = await getBrandRemoteData.adminPhone();
      print('Retrieved phone number: $phoneNumber');

      if (phoneNumber.isNotEmpty) {
        await openWhatsappCrossPlatform(
          context: context,
          number: phoneNumber,
          text: "من فضلك , اريد انشاء حساب جديد",
        );
      } else {
        print('Empty phone number returned');
        // Handle empty phone number case
      }
    } catch (e) {
      print('Error in _handleContactUs: $e');
      // Show an error message to the user
    }
  }

  Future<void> openWhatsappCrossPlatform({
    required BuildContext context,
    required String number,
    required String text,
  }) async {
    print(number);
    String formattedNumber = number.replaceAll('+', '');
    String encodedText = Uri.encodeComponent(text);
    final String urlString = kIsWeb
        ? "https://web.whatsapp.com/send?phone=$formattedNumber&text=$encodedText"
        : "https://wa.me/$formattedNumber?text=$encodedText";
    final Uri url = Uri.parse(urlString);

    try {
      if (kIsWeb) {
        // On web, open in a new tab to avoid same-tab navigation issues
        final bool launched = await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
          // Forces new tab/window
          webOnlyWindowName: '_blank',
        );

      } else {
        // On mobile, use external application mode
        final bool launched = await launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
        );

      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _launchRateApp() {
    if (!kIsWeb) {
      final appId = Platform.isAndroid ? 'com.kytrademarkstrademarks' : '1605389392';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }else{
      launch(
        "https://play.google.com/store/apps/details?id=com.kytrademarks",
      );
      launch(
        "https://apps.apple.com/app/id1605389392",
      );
    }
  }


  // Handler for contact us option
  void _handleContactUsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Contacts(canBack: true),
      ),
    );
  }

  // Handler for logout option
  void _handleLogoutTap() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            "note".tr(),
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'logoutCaught'.tr(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary,
                    ColorManager.primaryByOpacity.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(45),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'no'.tr(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                logOut().then((value) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/MainTabs",
                        (route) => false,
                  );
                });
              },
              child: Text(
                'yes'.tr(),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}