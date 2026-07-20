import 'dart:typed_data';

import 'package:file_selector/file_selector.dart' show XFile;
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppImageCache {
  AppImageCache._();

  static const int _maxItems = 80;
  static const int _maxBytes = 120 << 20;
  static final _bytes = <String, Uint8List>{};
  static final _futures = <String, Future<Uint8List>>{};
  static int _totalBytes = 0;

  static Uint8List? bytesFor(String path) => _bytes[path];

  static void remember(String path, Uint8List data) => _remember(path, data);

  static Future<Uint8List> load(String path) {
    final cached = _bytes[path];
    if (cached != null) return Future.value(cached);

    return _futures.putIfAbsent(path, () async {
      try {
        final bytes = await XFile(path).readAsBytes();
        _remember(path, bytes);
        return bytes;
      } finally {
        _futures.remove(path);
      }
    });
  }

  static void configureFlutterImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 220;
    imageCache.maximumSizeBytes = 220 << 20;
  }

  static Future<void> precachePath(
    BuildContext context,
    String path, {
    int? cacheWidth,
  }) async {
    try {
      if (path.startsWith('http') || path.startsWith('blob:')) {
        if (cacheWidth == null) {
          await precacheImage(NetworkImage(path), context);
        } else {
          await precacheImage(
            ResizeImage(NetworkImage(path), width: cacheWidth),
            context,
          );
        }
        return;
      }
      final bytes = await load(path);
      if (!context.mounted) return;
      if (cacheWidth == null) {
        await precacheImage(MemoryImage(bytes), context);
      } else {
        await precacheImage(
          ResizeImage(MemoryImage(bytes), width: cacheWidth),
          context,
        );
      }
    } catch (_) {}
  }

  static void _remember(String path, Uint8List data) {
    final old = _bytes.remove(path);
    if (old != null) _totalBytes -= old.lengthInBytes;
    _bytes[path] = data;
    _totalBytes += data.lengthInBytes;
    while (_bytes.length > 1 &&
        (_bytes.length > _maxItems || _totalBytes > _maxBytes)) {
      final removed = _bytes.remove(_bytes.keys.first);
      if (removed == null) break;
      _totalBytes -= removed.lengthInBytes;
    }
  }
}

class CachedAppImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final WidgetBuilder? fallbackBuilder;
  final Color? backgroundColor;
  final int? cacheWidth;
  final FilterQuality filterQuality;

  const CachedAppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.fallbackBuilder,
    this.backgroundColor,
    this.cacheWidth,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http') || path.startsWith('blob:')) {
      return _withConstraints(
        context,
        (targetWidth) => Image.network(
          path,
          fit: fit,
          cacheWidth: targetWidth,
          filterQuality: filterQuality,
          gaplessPlayback: true,
          frameBuilder: _fadeInFrame,
          errorBuilder: (context, error, stackTrace) => _fallback(context),
        ),
      );
    }

    final cached = AppImageCache.bytesFor(path);
    if (cached != null) return _memory(context, cached);

    return FutureBuilder<Uint8List>(
      future: AppImageCache.load(path),
      builder: (context, snapshot) {
        if (snapshot.hasData) return _memory(context, snapshot.data!);
        if (snapshot.hasError) return _fallback(context);
        return _loading(context);
      },
    );
  }

  Widget _memory(BuildContext context, Uint8List bytes) {
    return _withConstraints(
      context,
      (targetWidth) => Image.memory(
        bytes,
        fit: fit,
        cacheWidth: targetWidth,
        filterQuality: filterQuality,
        gaplessPlayback: true,
        frameBuilder: _fadeInFrame,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      ),
    );
  }

  Widget _withConstraints(
    BuildContext context,
    Widget Function(int? targetWidth) builder,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final targetWidth =
            cacheWidth ??
            (fit == BoxFit.cover && width.isFinite && width > 0
                ? (width * MediaQuery.devicePixelRatioOf(context)).round()
                : null);
        return builder(targetWidth);
      },
    );
  }

  Widget _fadeInFrame(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuart,
      child: child,
    );
  }

  Widget _loading(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.card,
      alignment: Alignment.center,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.navSelected,
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.card,
      alignment: Alignment.center,
      child:
          fallbackBuilder?.call(context) ??
          Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
    );
  }
}
