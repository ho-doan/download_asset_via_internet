import 'dart:io';

import 'package:download_asset_via_internet/download_asset_via_internet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Download Assets Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(title: 'Download Assets'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DownloadAssetsController controller = DownloadAssetsController();
  String message = 'Press the download button to start the download';
  bool downloaded = false;
  double value = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await controller.init();
    downloaded = controller.assetsDirAlreadyExists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('${controller.assetsDir}/assets/images/cancle.svg');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (downloaded) ...[
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      File(
                        '${controller.assetsDir}/assets/coupon_noimg.png',
                      ),
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      File(
                        '${controller.assetsDir}/assets/images/coupon_noimg.png',
                      ),
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              AssetsDownloadWidget(
                controller: controller,
                subPath: 'assets/images',
                image: 'cancle.svg',
                builder: SvgPicture.file,
                builderError: () => const Icon(Icons.error),
              ),
              SvgPicture.file(
                File(
                  '${controller.assetsDir}/assets/images/cancle.svg',
                ),
                fit: BoxFit.fitWidth,
              ),
            ],
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0,
                end: value,
              ),
              builder: (context, value, _) => LinearProgressIndicator(
                minHeight: 10,
                value: value,
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _downloadAssets,
            tooltip: 'Download',
            child: const Icon(Icons.arrow_downward),
          ),
          const SizedBox(
            width: 25,
          ),
          FloatingActionButton(
            onPressed: () async {
              await controller.clearAssets();
              await _downloadAssets();
            },
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(
            width: 25,
          ),
          FloatingActionButton(
            onPressed: _cancel,
            tooltip: 'Cancel',
            child: const Icon(Icons.cancel_outlined),
          ),
          FloatingActionButton(
            onPressed: _cleanAssets,
            tooltip: 'Clean',
            child: const Icon(Icons.cancel_outlined),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _downloadAssets() async {
    final assetsDownloaded = controller.assetsDirAlreadyExists();

    if (assetsDownloaded) {
      setState(() {
        message = 'Click in refresh button to force download';
      });
      return;
    }

    try {
      value = 0.0;
      downloaded = false;
      await controller.startDownload(
        onCancel: () {
          message = 'Cancelled by user';
          setState(() {});
        },
        assetsUrls: [
          // 'http://10.50.10.93:3000/files/download/2',
          // 'http://10.50.10.93:3000/files/download/3',
          'http://10.50.10.93:3000/files/download/1',
          // 'http://localhost/assets_dem',
        ],
        onProgress: (progressValue) {
          value = progressValue;
          setState(() {
            message =
                'Downloading - ${(progressValue * 100).toStringAsFixed(2)}';
          });
        },
        onDone: () {
          setState(() {
            downloaded = true;
            message = 'Download completed\nClick in refresh '
                'button to force download';
          });
        },
      );
    } on DownloadAssetsException catch (e) {
      setState(() {
        downloaded = false;
        message = 'Error: $e';
      });
    }
  }

  void _cancel() => controller.cancelDownload();

  void _cleanAssets() => controller.clearAssets();
}
