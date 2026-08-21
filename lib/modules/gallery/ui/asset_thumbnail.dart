import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatefulWidget {
  final AssetEntity asset;

  const AssetThumbnail({super.key, required this.asset});

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  Uint8List? _bytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final bytes = await widget.asset.thumbnailDataWithSize(
        const ThumbnailSize.square(240),
      );
      if (mounted) {
        setState(() {
          _bytes = bytes;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        fit: BoxFit.cover,
        semanticLabel: 'Gallery photo thumbnail',
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (_hasError) {
      return _placeholder();
    }
    return Container(
      color: Colors.grey.withAlpha(50),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.withAlpha(50),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
