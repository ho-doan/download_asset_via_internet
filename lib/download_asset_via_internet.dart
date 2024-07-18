library download_asset_via_internet;

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'src/exception/exception.dart';
import 'src/file_client_manager/file_client_manager.dart';
import 'src/file_manager/file_manager.dart';
import 'src/uncompress/uncompress_delegate.dart';

export 'src/exception/exception.dart';
export 'src/widgets/assets_download_widget.dart';

abstract class DownloadAssetsController {
  factory DownloadAssetsController() => createObject(
        fileManager: FileManagerImpl(),
        customHttpClient: CustomHttpClientImpl(),
      );

  /// Initialization method for setting up the assetsDir,
  /// which is required to be called during app initialization.
  /// [assetDir] -> Not required. Path to directory where
  /// your zipFile will be downloaded and unzipped
  /// (default value is getApplicationPath + assets)
  /// [useFullDirectoryPath] -> Not required (default value is false).
  /// If this is true the getApplicationPath won't be used (make sure
  /// that the app has to write permission and it is a valid path)
  Future init({
    String assetDir = 'assets',
    bool useFullDirectoryPath = false,
  });

  /// Directory that keeps all assets
  String? get assetsDir;

  /// If assets directory was already created it assumes
  /// that the content was already downloaded.
  bool assetsDirAlreadyExists();

  /// It checks if file already exists
  /// [file] -> full path to file
  bool assetsFileExists(String file);

  String ext(String file);

  /// Clear all download assets, if it already exists on local storage.
  Future<void> clearAssets();

  /// Start the download of your content to local storage,
  /// uncompress all data and delete
  /// the compressed file. It's not required be compressed file.
  /// [assetsUrls] -> A list of URLs representing each file to be downloaded.
  ///  (http://{YOUR_DOMAIN}:{FILE_NAME}.{EXTENSION})
  /// [uncompressDelegates] -> An optional list of [UncompressDelegate]
  /// objects responsible for handling asset decompression, if needed.
  /// If the [uncompressDelegates] list is empty, the [UnzipDelegate]
  /// class is automatically added as a delegate for ZIP file decompression.
  /// [onStartUnziping] -> Called right before the start of the
  /// uncompressing process.
  /// [onProgress] -> It's not required. Called after each iteration
  /// returning the current progress.
  /// The double parameter ranges from 0 to 1, where 1 indicates the
  /// completion of the download process.
  /// [onDone] -> Called when all files have been downloaded and uncompressed.
  /// [onCancel] -> Cancel the download (optional)
  /// [requestQueryParams] -> Query params to be used in the request
  /// (optional)
  /// [requestExtraHeaders] -> Extra headers to be added in the request
  /// (optional)
  Future startDownload({
    required List<String> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [UnzipDelegate()],
    ValueChanged<double>? onProgress,
    VoidCallback? onStartUnziping,
    VoidCallback? onCancel,
    VoidCallback? onDone,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  });

  /// Cancel the download
  void cancelDownload();
}

DownloadAssetsController createObject({
  required FileManager fileManager,
  required CustomHttpClient customHttpClient,
}) =>
    DownloadAssetsControllerImpl(
      fileManager: fileManager,
      customHttpClient: customHttpClient,
    );

class DownloadAssetsControllerImpl implements DownloadAssetsController {
  DownloadAssetsControllerImpl({
    required this.fileManager,
    required this.customHttpClient,
  });

  String? _assetsDir;
  final FileManager fileManager;
  final CustomHttpClient customHttpClient;

  @override
  String? get assetsDir => _assetsDir;

  @override
  Future init({
    String assetDir = 'assets',
    bool useFullDirectoryPath = false,
  }) async {
    if (useFullDirectoryPath) {
      _assetsDir = assetDir;
      return;
    }

    final rootDir = await fileManager.getApplicationPath();
    _assetsDir = '$rootDir/$assetDir';
  }

  @override
  bool assetsDirAlreadyExists() {
    assert(
      assetsDir != null,
      'DownloadAssets has not been initialized. Call init method first',
    );
    return fileManager.directoryExists(_assetsDir!);
  }

  @override
  bool assetsFileExists(String file) {
    assert(
      assetsDir != null,
      'DownloadAssets has not been initialized. Call init method first',
    );
    return fileManager.fileExists('$_assetsDir/$file');
  }

  @override
  Future<void> clearAssets() async {
    final assetsDirExists = assetsDirAlreadyExists();

    if (!assetsDirExists) {
      return;
    }

    await fileManager.deleteDirectory(_assetsDir!);
  }

  @override
  Future startDownload({
    required List<String> assetsUrls,
    List<UncompressDelegate> uncompressDelegates = const [UnzipDelegate()],
    ValueChanged<double>? onProgress,
    VoidCallback? onStartUnziping,
    VoidCallback? onCancel,
    VoidCallback? onDone,
    Map<String, dynamic>? requestQueryParams,
    Map<String, String> requestExtraHeaders = const {},
  }) async {
    assert(
      assetsDir != null,
      'DownloadAssets has not been initialized. Call init method first',
    );
    assert(assetsUrls.isNotEmpty, "AssetUrl param can't be empty");

    try {
      onProgress?.call(0);
      await fileManager.createDirectory(_assetsDir!);
      var totalSize = -1;
      var downloadedSize = 0;
      final assets = <({String assetUrl, String ext, String fullPath})>[];

      for (final assetsUrl in assetsUrls) {
        final path = basename(assetsUrl);
        final fileName = '$path${path.split('.').length > 1 ? '' : '.zip'}';
        final fullPath = '$_assetsDir/$fileName';
        assets.add(
          (
            assetUrl: assetsUrl,
            ext: fileName,
            fullPath: fullPath,
          ),
        );
        final size = await customHttpClient.checkSize(assetsUrl);
        totalSize += size;
      }

      final downloadedBytesPerAsset = <String, int>{};

      for (final asset in assets) {
        await customHttpClient.download(
          asset.assetUrl,
          asset.fullPath,
          onReceiveProgress: (int received, int total) {
            if (total == -1 || received <= 0) {
              return;
            }

            final previousReceived =
                downloadedBytesPerAsset[asset.fullPath] ?? 0;
            downloadedSize += received - previousReceived;
            downloadedBytesPerAsset[asset.fullPath] = received;
            final progress = downloadedSize / totalSize;
            onProgress?.call(progress);
          },
          requestExtraHeaders: requestExtraHeaders,
          requestQueryParams: requestQueryParams,
        );
      }

      onStartUnziping?.call();

      for (final asset in assets) {
        final fileExtension = extension(asset.ext);

        for (final delegate in uncompressDelegates) {
          if (delegate.extension != fileExtension) {
            continue;
          }

          await delegate.uncompress(asset.fullPath, _assetsDir!);
          break;
        }
      }

      onDone?.call();
    } on DownloadAssetsException catch (e) {
      if (e.downloadCancelled) {
        onCancel?.call();
        return;
      }

      rethrow;
    } on Exception catch (e) {
      throw DownloadAssetsException(e.toString(), exception: e);
    }
  }

  @override
  String ext(String file) => extension(file);

  @override
  void cancelDownload() => customHttpClient.cancel();
}
