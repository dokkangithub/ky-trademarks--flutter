import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import '../../core/Constant/Api_Constant.dart';
import '../../data/Brand/models/BrandDataModel.dart';
import '../../domain/Brand/Entities/BrandEntity.dart';
import '../../network/RestApi/Comman.dart';
import '../../resources/StringManager.dart';
import '../Screens/brand details/BrandDetails.dart';

class BrandWidget extends StatelessWidget {
  final BuildContext context;
  final dynamic model;
  final int index;
  final bool isFromHomeFiltering;
  final List<BrandEntity> brandsList;
  final bool isSearch;

  const BrandWidget({
    super.key,
    required this.context,
    required this.index,
    this.isSearch = false,
    this.isFromHomeFiltering = false,
    this.brandsList = const [],
    required this.model,
  });

  List<BrandImages> _getFilteredImages(List<BrandEntity> brands) {
    return brands.map((brand) {
      return brand.images.firstWhere(
            (image) => image.conditionId == null,
        orElse: () => ImagesModel(image: '', conditionId: '', type: ''),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredImages = _getFilteredImages(model.allBrands);
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BranDetails(
                brandId: isFromHomeFiltering && brandsList.isNotEmpty
                    ? brandsList[index].id
                    : model.allBrands[index].id,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: isLargeScreen
                      ? _LargeScreenLayout(
                    filteredImages: filteredImages,
                    model: model,
                    index: index,
                    isSearch: isSearch,
                    isFromHomeFiltering: isFromHomeFiltering,
                    brandsList: brandsList,
                  )
                      : _SmallScreenLayout(
                    filteredImages: filteredImages,
                    model: model,
                    index: index,
                    isSearch: isSearch,
                    isFromHomeFiltering: isFromHomeFiltering,
                    brandsList: brandsList,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Widget for Large Screens (e.g., Web or Tablets)
class _LargeScreenLayout extends StatelessWidget {
  final List<BrandImages> filteredImages;
  final dynamic model;
  final int index;
  final bool isSearch;
  final bool isFromHomeFiltering;
  final List<BrandEntity> brandsList;

  const _LargeScreenLayout({
    required this.filteredImages,
    required this.model,
    required this.index,
    required this.isSearch,
    required this.isFromHomeFiltering,
    required this.brandsList,
  });

  @override
  Widget build(BuildContext context) {
    final brand = isSearch || (isFromHomeFiltering && brandsList.isNotEmpty)
        ? model.allBrands[index]
        : model.allBrands.brand[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BrandImage(imageUrl: filteredImages[index].image, size: 150),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrandName(name: brand.brandName),
              const SizedBox(height: 5),
              _BrandDetails(number: brand.brandNumber, state: brand.state),
              if (brand.newCurrentStatus != '' || brand.currentStatus != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _BrandStatus(
                    status: brand.newCurrentStatus.isEmpty
                        ? convertStateBrandNumberToString(brand.currentStatus)
                        : brand.newCurrentStatus,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget for Small Screens (e.g., Mobile)
class _SmallScreenLayout extends StatelessWidget {
  final List<BrandImages> filteredImages;
  final dynamic model;
  final int index;
  final bool isSearch;
  final bool isFromHomeFiltering;
  final List<BrandEntity> brandsList;

  const _SmallScreenLayout({
    required this.filteredImages,
    required this.model,
    required this.index,
    required this.isSearch,
    required this.isFromHomeFiltering,
    required this.brandsList,
  });

  @override
  Widget build(BuildContext context) {
    final brand = isSearch || (isFromHomeFiltering && brandsList.isNotEmpty)
        ? model.allBrands[index]
        : model.allBrands.brand[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandImage(imageUrl: filteredImages[index].image, size: 100),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrandName(name: brand.brandName),
              const SizedBox(height: 3),
              _BrandDetails(number: brand.brandNumber, state: brand.state),
              if (brand.newCurrentStatus != '' || brand.currentStatus != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _BrandStatus(
                    status: brand.newCurrentStatus.isEmpty
                        ? convertStateBrandNumberToString(brand.currentStatus)
                        : brand.newCurrentStatus,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Reusable Widgets following the "Law of Widgets"

// Brand Image Widget
class _BrandImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _BrandImage({required this.imageUrl, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return imageUrl.isEmpty
        ? const SizedBox.shrink()
        : ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: cachedImage(
        ApiConstant.imagePath + imageUrl,
        width: size,
        height: size,
        fit: kIsWeb? BoxFit.cover:BoxFit.contain,
        placeHolderFit: BoxFit.contain,
      ),
    );
  }
}

// Brand Name Widget
class _BrandName extends StatelessWidget {
  final String name;

  const _BrandName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: Theme.of(context)
          .textTheme
          .displayLarge
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600,
          fontFamily:StringConstant.fontName),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

// Brand Details Widget (Number and State)
class _BrandDetails extends StatelessWidget {
  final String number;
  final String state;

  const _BrandDetails({required this.number, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            number,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: Colors.grey.withOpacity(0.9), fontSize: 14,
                fontFamily:StringConstant.fontName),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            " - ${state.replaceAll("العلامه", "")}",
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: Colors.grey.withOpacity(0.9), fontSize: 14,
                fontFamily:StringConstant.fontName),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Brand Status Widget
class _BrandStatus extends StatelessWidget {
  final String status;

  const _BrandStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryByOpacity.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          status,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
              fontFamily:StringConstant.fontName
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}