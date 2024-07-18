# ble_sdk

* [![download_asset_via_internet version](https://img.shields.io/pub/v/download_asset_via_internet?label=download_asset_via_internet)](https://pub.dev/packages/download_asset_via_internet)
[![download_asset_via_internet size](https://img.shields.io/github/repo-size/ho-doan/download_asset_via_internet)](https://github.com/ho-doan/download_asset_via_internet)
[![download_asset_via_internet issues](https://img.shields.io/github/issues/ho-doan/download_asset_via_internet)](https://github.com/ho-doan/download_asset_via_internet)
[![download_asset_via_internet issues](https://img.shields.io/pub/likes/download_asset_via_internet)](https://github.com/ho-doan/download_asset_via_internet)
* Download assets via internet

## Futures

* Download assets via internet
* Load assets from File
* Delete assets from local

## Getting Started

* init controller

```dart
    DownloadAssetsController controller = DownloadAssetsController();
    await controller.init();
    downloaded = controller.assetsDirAlreadyExists();
```

* start download

```dart
    await controller.startDownload(
        assetsUrls: [
          // 'http://10.50.10.93:3000/files/download/2',
          // 'http://10.50.10.93:3000/files/download/3',
          'http://10.50.10.93:3000/files/download/1',
          // 'http://localhost/assets_dem',
        ],
      );
```

* load assets from file

```dart
AssetsDownloadWidget(
    controller: controller,
    subPath: 'assets/images',
    image: 'cancle.svg',
    builder: SvgPicture.file,
    builderError: () => const Icon(Icons.error),
),
```
