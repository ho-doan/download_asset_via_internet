/// Exception thrown during asset download operations
class DownloadAssetsException implements Exception {
  /// Creates a new instance of [DownloadAssetsException].
  ///
  /// The [_message] parameter represents the error message to be
  /// associated with the exception.
  /// The optional [exception] parameter represents the underlying
  /// exception that caused the error.
  /// The optional [downloadCancelled] parameter indicates if the
  /// download was explicitly cancelled by the user.
  DownloadAssetsException(
    this._message, {
    this.exception,
    this.downloadCancelled = false,
  });

  /// The underlying exception that caused the error.
  final Exception? exception;

  /// Indicates if the download was explicitly cancelled by the user.
  final bool downloadCancelled;

  final String _message;

  @override
  String toString() => exception?.toString() ?? _message;
}
