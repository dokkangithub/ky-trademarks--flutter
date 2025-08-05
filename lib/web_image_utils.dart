// Create a new file: web_image_view.dart
// Only use this file in web builds

import 'dart:html' as html;
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class WebImageView extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const WebImageView({
    Key? key,
    required this.url,
    this.height,
    this.width,
    this.fit,
  }) : super(key: key);

  @override
  State<WebImageView> createState() => _WebImageViewState();
}

class _WebImageViewState extends State<WebImageView> {
  late final String viewType;

  @override
  void initState() {
    super.initState();
    viewType = 'img-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  void _registerView() {
    final imageElement = html.ImageElement()
      ..src = widget.url
      ..style.height = widget.height != null ? '${widget.height}px' : 'auto'
      ..style.width = widget.width != null ? '${widget.width}px' : 'auto'
      ..style.objectFit = _getObjectFit(widget.fit)
      ..crossOrigin = 'anonymous'; // Key for CORS

    // Register the view factory
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return imageElement;
    });
  }

  String _getObjectFit(BoxFit? fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'contain';
      case BoxFit.fitHeight:
        return 'contain';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      default:
        return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: HtmlElementView(viewType: viewType),
    );
  }
}