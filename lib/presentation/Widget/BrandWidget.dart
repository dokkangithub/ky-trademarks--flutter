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
    final brand = isSearch || (isFromHomeFiltering && brandsList.isNotEmpty)
        ? model.allBrands[index]
        : model.allBrands.brand[index];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // الصورة
              _buildBrandImage(filteredImages[index].image),
              const SizedBox(width: 12),
              
              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم العلامة
                    Text(
                      brand.brandName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: StringConstant.fontName,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // رقم العلامة
                    Text(
                      "رقم العلامة: ${brand.brandNumber}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontFamily: StringConstant.fontName,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            brand.state.replaceAll("العلامه", "").trim(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontFamily: StringConstant.fontName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // حالة العلامة
                        if (brand.newCurrentStatus != '' || brand.currentStatus != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ColorManager.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              brand.newCurrentStatus.isEmpty
                                  ? convertStateBrandNumberToString(brand.currentStatus)
                                  : brand.newCurrentStatus,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: StringConstant.fontName,
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
        ),
      ),
    );
  }

  Widget _buildBrandImage(String imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: imageUrl.isEmpty
          ? Icon(
              Icons.business,
              size: 30,
              color: Colors.grey.shade500,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: cachedImage(
                ApiConstant.imagePath + imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeHolderFit: BoxFit.contain,
              ),
            ),
    );
  }
}