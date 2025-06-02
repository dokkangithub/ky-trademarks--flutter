import 'package:flutter/material.dart';

import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';

class CustomerAddress extends StatelessWidget {
  const CustomerAddress({ required this.context,
    required this.model,});

  final BuildContext context;
  final GetBrandDetailsProvider model;
  @override
  Widget build(BuildContext context) {
    return model.brandDetails!.brand.customerAddress==''?SizedBox():
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "عنوان مقدم الطلب : ",
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 14,
              fontFamily:StringConstant.fontName
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width*0.6,
          child: Text(
            model.brandDetails!.brand.customerAddress??'',
            style:
            Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14,
                fontFamily:StringConstant.fontName),
            maxLines: null,
          ),
        ),
      ],
    )
    ;
  }
}