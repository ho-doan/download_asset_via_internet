import 'dart:io';

import 'package:flutter/material.dart';

import '../../download_asset_via_internet.dart';

class AssetsDownloadWidget extends StatelessWidget {
  const AssetsDownloadWidget({
    required this.controller,
    required this.image,
    required this.builderError,
    required this.builder,
    this.subPath,
    super.key,
  });

  final DownloadAssetsController controller;
  final String? subPath;
  final String image;
  final Widget Function(File) builder;
  final Widget Function() builderError;

  @override
  Widget build(BuildContext context) {
    if (controller.assetsFileExists([subPath, image].join('/'))) {
      final imagePath = [
        controller.assetsDir ?? '',
        if (subPath != null) subPath!,
        image,
      ].join('/');
      switch (controller.ext(image)) {
        case '.svg':
        case '.png':
        case '.jpg':
          return builder.call(File(imagePath));
      }
    }
    // if(.contains(other))
    return builderError.call();
  }
}
