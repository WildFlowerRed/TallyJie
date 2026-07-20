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

class ZoomableCachedImage extends StatefulWidget {
  final String path;
  final int? cacheWidth;
  final WidgetBuilder? fallbackBuilder;
  final VoidCallback? onBackgroundTap;
  final ValueChanged<bool>? onZoomChanged;

  const ZoomableCachedImage({
    super.key,
    required this.path,
    this.cacheWidth,
    this.fallbackBuilder,
    this.onBackgroundTap,
    this.onZoomChanged,
  });

  @override
  State<ZoomableCachedImage> createState() => _ZoomableCachedImageState();
}

class _ZoomableCachedImageState extends State<ZoomableCachedImage> {
  final TransformationController _transformationController =
      TransformationController();
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  Size? _imageSize;
  Offset? _lastDoubleTapPosition;
  bool _isZoomed = false;
  int _resolveToken = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageSize();
  }

  @override
  void didUpdateWidget(covariant ZoomableCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _transformationController.value = Matrix4.identity();
      _setZoomed(false);
      _resolveImageSize();
    }
  }

  @override
  void dispose() {
    _removeImageListener();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _resolveImageSize() async {
    final token = ++_resolveToken;
    _removeImageListener();
    setState(() => _imageSize = null);

    ImageProvider provider;
    try {
      if (widget.path.startsWith('http') || widget.path.startsWith('blob:')) {
        provider = NetworkImage(widget.path);
      } else {
        final bytes =
            AppImageCache.bytesFor(widget.path) ??
            await AppImageCache.load(widget.path);
        if (!mounted || token != _resolveToken) return;
        provider = MemoryImage(bytes);
      }
    } catch (_) {
      return;
    }

    if (!mounted || token != _resolveToken) return;
    final stream = provider.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) {
      if (!mounted || token != _resolveToken) return;
      final image = info.image;
      setState(() {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      });
    }, onError: (_, _) {});
    _imageStream = stream;
    _imageStreamListener = listener;
    stream.addListener(listener);
  }

  void _removeImageListener() {
    final stream = _imageStream;
    final listener = _imageStreamListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  void _handleDoubleTap() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale > 1.05) {
      _transformationController.value = Matrix4.identity();
      _setZoomed(false);
      return;
    }

    final tapPosition = _lastDoubleTapPosition ?? Offset.zero;
    const targetScale = 2.4;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(
        -tapPosition.dx * (targetScale - 1),
        -tapPosition.dy * (targetScale - 1),
        0,
        1,
      )
      ..scaleByDouble(targetScale, targetScale, targetScale, 1);
    _setZoomed(true);
  }

  void _handleTapUp(TapUpDetails details, Rect imageRect) {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.05) return;
    if (!imageRect.inflate(8).contains(details.localPosition)) {
      widget.onBackgroundTap?.call();
    }
  }

  void _handleInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    _setZoomed(scale > 1.05);
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    _setZoomed(scale > 1.05);
  }

  void _setZoomed(bool value) {
    if (_isZoomed == value) return;
    _isZoomed = value;
    widget.onZoomChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _imageRectFor(viewport);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _handleTapUp(details, imageRect),
          onDoubleTapDown: (details) =>
              _lastDoubleTapPosition = details.localPosition,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1,
            maxScale: 4,
            boundaryMargin: const EdgeInsets.all(96),
            clipBehavior: Clip.none,
            onInteractionUpdate: _handleInteractionUpdate,
            onInteractionEnd: _handleInteractionEnd,
            child: SizedBox.expand(
              child: Center(
                child: SizedBox(
                  width: imageRect.width,
                  height: imageRect.height,
                  child: CachedAppImage(
                    path: widget.path,
                    fit: BoxFit.contain,
                    cacheWidth: widget.cacheWidth,
                    filterQuality: FilterQuality.medium,
                    backgroundColor: Colors.black,
                    fallbackBuilder: widget.fallbackBuilder,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Rect _imageRectFor(Size viewport) {
    if (viewport.width <= 0 || viewport.height <= 0) {
      return Rect.zero;
    }
    final source = _imageSize;
    if (source == null || source.width <= 0 || source.height <= 0) {
      final fallbackSize = Size(viewport.width, viewport.height * 0.72);
      final offset = Offset(
        (viewport.width - fallbackSize.width) / 2,
        (viewport.height - fallbackSize.height) / 2,
      );
      return offset & fallbackSize;
    }

    final fitted = applyBoxFit(BoxFit.contain, source, viewport).destination;
    final offset = Offset(
      (viewport.width - fitted.width) / 2,
      (viewport.height - fitted.height) / 2,
    );
    return offset & fitted;
  }
}
