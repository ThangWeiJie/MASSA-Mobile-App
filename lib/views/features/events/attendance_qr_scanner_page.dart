import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:massa/view_models/features/events/mark_attendance_viewmodel.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class AttendanceQrScannerPage extends StatefulWidget {
  const AttendanceQrScannerPage({super.key});

  @override
  State<AttendanceQrScannerPage> createState() =>
      _AttendanceQrScannerPageState();
}

class _AttendanceQrScannerPageState extends State<AttendanceQrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handlingScan = false;
  bool _completed = false;
  String? _scannerError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  late final WidgetsBindingObserver _lifecycleObserver =
      _ScannerLifecycleObserver(onChanged: _handleLifecycleChange);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLifecycleChange(AppLifecycleState state) async {
    if (!mounted || _completed || _handlingScan) return;

    try {
      if (state == AppLifecycleState.resumed) {
        if (!_controller.value.isRunning) {
          await _controller.start();
        }
      } else if (_controller.value.isRunning) {
        await _controller.stop();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Scanner lifecycle update failed',
        name: 'AttendanceQrScannerPage',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MarkAttendanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Attendance QR'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Toggle torch',
            onPressed: _controller.toggleTorch,
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _controller.switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) => _onDetect(context, capture, viewModel),
              onDetectError: (error, stackTrace) {
                developer.log(
                  'Scanner detection failed',
                  name: 'AttendanceQrScannerPage',
                  error: error,
                  stackTrace: stackTrace,
                );
                if (!mounted) return;
                setState(() {
                  _scannerError =
                      'The QR could not be read. Hold the phone steady and try again.';
                });
              },
              placeholderBuilder: (_) => const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),
              errorBuilder: (context, error) {
                return ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.no_photography_outlined,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Camera access is unavailable. Allow camera '
                            'permission in your phone settings, then reopen '
                            'the scanner.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            error.errorCode.name,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (!_handlingScan)
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            if (_handlingScan)
              const ColoredBox(
                color: Color(0xDD000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.orange),
                      SizedBox(height: 18),
                      Text(
                        'Validating attendance...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 32,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _scannerError ??
                      viewModel.errorMessage ??
                      'Place the attendance QR inside the frame.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _scannerError == null && viewModel.errorMessage == null
                        ? Colors.white
                        : Colors.red[200],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onDetect(
    BuildContext context,
    BarcodeCapture capture,
    MarkAttendanceViewModel viewModel,
  ) async {
    if (_handlingScan || capture.barcodes.isEmpty) return;
    final payload = capture.barcodes.first.rawValue;
    if (payload == null || payload.isEmpty) return;

    viewModel.clearError();
    setState(() {
      _handlingScan = true;
      _scannerError = null;
    });

    try {
      if (_controller.value.isRunning) {
        await _controller.stop().timeout(const Duration(seconds: 3));
      }

      final success = await viewModel.submitQrPayload(payload);
      if (!context.mounted) return;
      if (success) {
        _completed = true;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 54),
            title: const Text('Attendance submitted'),
            content: Text(
              '${viewModel.lastRecord?.type.label ?? 'Event'} attendance was marked successfully.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
        return;
      }
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'Scanner operation timed out',
        name: 'AttendanceQrScannerPage',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _scannerError =
              'The scanner took too long to respond. Please try again.';
        });
      }
    } catch (error, stackTrace) {
      developer.log(
        'QR scan processing failed',
        name: 'AttendanceQrScannerPage',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _scannerError =
              'The QR could not be processed. Please try again or use the manual code.';
        });
      }
    } finally {
      if (mounted && !_completed) {
        setState(() {
          _handlingScan = false;
        });
        await _restartScanner();
      }
    }
  }

  Future<void> _restartScanner() async {
    try {
      if (!_controller.value.isRunning) {
        await _controller.start().timeout(const Duration(seconds: 5));
      }
    } catch (error, stackTrace) {
      developer.log(
        'Scanner restart failed',
        name: 'AttendanceQrScannerPage',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _scannerError =
              'Camera preview could not restart. Return and open the scanner again.';
        });
      }
    }
  }
}

class _ScannerLifecycleObserver with WidgetsBindingObserver {
  final Future<void> Function(AppLifecycleState state) onChanged;

  _ScannerLifecycleObserver({required this.onChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(onChanged(state));
  }
}
