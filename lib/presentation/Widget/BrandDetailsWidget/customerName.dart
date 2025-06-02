import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../resources/StringManager.dart';
import '../../Controllar/GetBrandDetailsProvider.dart';

class CustomerName extends StatelessWidget {
  const CustomerName({ required this.context,
    required this.model,});
  
final BuildContext context;
  final GetBrandDetailsProvider model;
  @override
  Widget build(BuildContext context) {
    return model.brandDetails!.brand.customerName==''? SizedBox():
    Row(
          children: [
            Text(
              "اسم مقدم الطلب : ",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 14,
                  fontFamily:StringConstant.fontName
              ),
            ),
            Text(
              model.brandDetails!.brand.applicant??'',

              style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14,
                  fontFamily:StringConstant.fontName),
            ),
          ],
        )
      ;
  }
}