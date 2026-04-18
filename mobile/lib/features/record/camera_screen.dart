import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _activeIdx = 0;
  FlashMode _flash = FlashMode.off;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _initFailed = true);
        return;
      }
      final ctrl = CameraController(
        _cameras[_activeIdx],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      await ctrl.setFlashMode(_flash);
      if (!mounted) return;
      setState(() => _controller = ctrl);
    } catch (_) {
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _flip() async {
    if (_cameras.length < 2) return;
    _activeIdx = (_activeIdx + 1) % _cameras.length;
    await _controller?.dispose();
    setState(() => _controller = null);
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    final next = _flash == FlashMode.off
        ? FlashMode.auto
        : (_flash == FlashMode.auto ? FlashMode.always : FlashMode.off);
    setState(() => _flash = next);
    await _controller?.setFlashMode(next);
  }

  Future<void> _shoot() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      final shot = await ctrl.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final dest = File(p.join(dir.path,
          'meal_${DateTime.now().millisecondsSinceEpoch}.jpg'));
      await File(shot.path).copy(dest.path);
      if (mounted) Navigator.of(context).pop(dest);
    } catch (_) {}
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      Navigator.of(context).pop(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget body;
    if (_initFailed) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.permission_camera_denied,
                  style: const TextStyle(color: AppColors.textMain)),
              const SizedBox(height: AppSpace.md),
              ElevatedButton.icon(
                onPressed: _pickGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(t.open_gallery),
              ),
            ],
          ),
        ),
      );
    } else if (_controller == null) {
      body = const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    } else {
      body = Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton.filled(
              onPressed: _toggleFlash,
              icon: Icon(
                _flash == FlashMode.always
                    ? Icons.flash_on
                    : (_flash == FlashMode.auto
                        ? Icons.flash_auto
                        : Icons.flash_off),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton.filled(
              onPressed: _pickGallery,
              icon: const Icon(Icons.photo_library_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  onPressed: _flip,
                  icon: const Icon(Icons.cameraswitch),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _shoot,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 56),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: body,
    );
  }
}
