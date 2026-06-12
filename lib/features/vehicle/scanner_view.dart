import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'scanner_viewmodel.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScannerViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ScannerViewModel>(
          builder: (context, vm, _) {
            return Stack(
              children: [
                _buildCameraPreview(vm),
                _buildOverlay(vm),
                _buildTopControls(vm),
                if (vm.extractedPlate != null)
                  _buildResultPanel(vm),
                if (!vm.hasPermission)
                  _buildPermissionDenied(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview(ScannerViewModel vm) {
    if (!vm.isInitialized || vm.cameraController == null) {
      return const Center(
        child: Text('Initializing camera...',
            style: TextStyle(color: Colors.white)),
      );
    }
    return SizedBox.expand(
      child: CameraPreview(vm.cameraController!),
    );
  }

  Widget _buildOverlay(ScannerViewModel vm) {
    if (!vm.isInitialized) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ScannerOverlayPainter(
            scanLineProgress: vm.extractedPlate != null ? 0.5 : _scanLineAnimation.value,
            showScanLine: vm.extractedPlate == null,
          ),
        );
      },
    );
  }

  Widget _buildTopControls(ScannerViewModel vm) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Scan Number Plate',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            if (vm.isInitialized)
              IconButton(
                icon: Icon(
                  vm.isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                  color: Colors.white,
                ),
                onPressed: vm.toggleTorch,
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(ScannerViewModel vm) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Plate Detected!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            const SizedBox(height: 12),
            Text(vm.extractedPlate ?? '',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 4,
                    color: Color(0xFF212121))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.retryScanning,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A237E),
                      side: const BorderSide(color: Color(0xFF1A237E)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => vm.confirmPlate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  size: 64, color: Color(0xFF9E9E9E)),
              const SizedBox(height: 16),
              const Text('Camera Permission Required',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Enable camera access in your device settings to use the scanner',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanLineProgress;
  final bool showScanLine;

  _ScannerOverlayPainter({
    required this.scanLineProgress,
    required this.showScanLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final cutoutWidth = size.width * 0.75;
    final cutoutHeight = cutoutWidth * 0.5;
    final left = (size.width - cutoutWidth) / 2;
    final top = (size.height - cutoutHeight) / 2 - 40;

    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cutoutWidth, cutoutHeight),
      const Radius.circular(12),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(cutoutRect),
      ),
      overlayPaint,
    );

    final cornerPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 24;

    // Top-left
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + cutoutWidth - cornerLength, top),
      Offset(left + cutoutWidth, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + cutoutWidth, top),
      Offset(left + cutoutWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + cutoutHeight - cornerLength),
      Offset(left, top + cutoutHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + cutoutHeight),
      Offset(left + cornerLength, top + cutoutHeight),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + cutoutWidth - cornerLength, top + cutoutHeight),
      Offset(left + cutoutWidth, top + cutoutHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + cutoutWidth, top + cutoutHeight - cornerLength),
      Offset(left + cutoutWidth, top + cutoutHeight),
      cornerPaint,
    );

    // Scanning line
    if (showScanLine) {
      final lineY = top + 8 + (cutoutHeight - 16) * scanLineProgress;
      final linePaint = Paint()
        ..color = const Color(0xFF2E7D32).withValues(alpha: 0.7)
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(left + 4, lineY),
        Offset(left + cutoutWidth - 4, lineY),
        linePaint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = const Color(0xFF2E7D32).withValues(alpha: 0.15)
        ..strokeWidth = 8;
      canvas.drawLine(
        Offset(left + 4, lineY),
        Offset(left + cutoutWidth - 4, lineY),
        glowPaint,
      );
    }

    // Label below cutout
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Align plate within the frame',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 13,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: cutoutWidth);
    textPainter.paint(
      canvas,
      Offset(left, top + cutoutHeight + 16),
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanLineProgress != scanLineProgress ||
        oldDelegate.showScanLine != showScanLine;
  }
}
