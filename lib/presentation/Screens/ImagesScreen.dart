import 'package:flutter/material.dart';

import '../../core/Constant/Api_Constant.dart';
import '../../network/RestApi/Comman.dart';

class ImagesScreen extends StatelessWidget {
 List<dynamic> images;
 ImagesScreen(this.images);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: ()=>Navigator.of(context).pop(),
      ),),
      backgroundColor: Colors.black,
      body: PageView(
        children:  images.map((e) {
          return ClipRRect(
              borderRadius: BorderRadius.circular(10)
              ,child: cachedImage("${ApiConstant.imagePath}${e.image}", fit: BoxFit.contain));
        }).toList(),
      ),
    );
  }
}
