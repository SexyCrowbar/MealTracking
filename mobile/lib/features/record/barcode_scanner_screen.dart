import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme.dart';
import '../../food/off_client.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs.dart';
import 'manual_entry_screen.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (code == null) return;
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    await _controller.stop();
    try {
      final product = await OffClient().lookup(code);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ManualEntryScreen(prefill: product),
        ),
      );
    } on OffLookupException catch (e) {
      if (!mounted) return;
      String msg;
      if (e.notFound) {
        msg = t.barcode_not_found;
      } else if (e.noNutrition) {
        msg = t.barcode_no_nutrition;
      } else {
        msg = t.barcode_lookup_failed;
      }
      showAppSnack(context, msg);
      await _controller.start();
      if (mounted) setState(() => _busy = false);
    } catch (_) {
      if (!mounted) return;
      showAppSnack(context, t.barcode_lookup_failed);
      await _controller.start();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.scan_barcode)),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpace.md),
              color: Colors.black.withValues(alpha: 0.55),
              child: Row(
                children: [
                  if (_busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.qr_code_scanner, color: Colors.white),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      _busy ? t.looking_up_barcode : t.scanning_barcode,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
