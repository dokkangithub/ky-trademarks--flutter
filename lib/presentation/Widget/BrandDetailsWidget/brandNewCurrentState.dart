// import 'package:flutter/material.dart';
//
// import '../../Controllar/GetBrandDetailsProvider.dart';
// import 'CurrentBrandStatus.dart';
//
// class BrandNewCurrentState extends StatelessWidget {
//   const BrandNewCurrentState({
//     Key? key,
//     required this.context,
//     required this.model,
//   }) : super(key: key);
//
//   final BuildContext context;
//   final GetBrandDetailsProvider model;
//
//   @override
//   Widget build(BuildContext context) {
//     return model.brandDetails=='' || model.brandDetails!.brand.newCurrentState=='' ? SizedBox(): Row(
//       children: [
//         Text(
//           model.brandDetails!.brand.markOrModel == 1
//               ?
//           "حالة النموذج  :  ":
//           "حالة العلامة  :  ",
//           style: Theme.of(context).textTheme.headline2?.copyWith(
//               fontSize: 14
//           ),
//         ),
//         Text(
//           model.brandDetails!.brand.newCurrentState??"",
//           style:
//           Theme.of(context).textTheme.headline1?.copyWith(fontSize: 14),
//         ),
//       ],
//     );
//   }
// }
