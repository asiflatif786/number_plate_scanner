import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  bool _isProcessing = false;
  bool _isScanning = true;
  List<CameraDescription>? _cameras;
  
  String _debugText = "Waiting for plate...";
  final Map<String, int> _votes = {};
  final int _threshold = 4; // Low threshold for quick response in demo
  String? _lockedResult;

  // Demo Database
  final Map<String, Map<String, dynamic>> _mockDb = {
    'ABC-593JR': {
      'status': 'COMPLIANT',
      'owner': 'Musa Ibrahim',
      'vehicle': 'Black Land Rover Discovery',
      'toll': 'Pre-paid (Valid)',
      'color': Colors.green,
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high, // High resolution is better for small plate text
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      try {
        await _cameraController?.initialize();
        if (mounted) {
          setState(() {});
          _cameraController?.startImageStream(_processCameraImage);
        }
      } catch (e) {
        debugPrint('Camera error: $e');
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (!_isScanning || _isProcessing || _cameraController == null) return;
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      bool foundInFrame = false;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // Clean text: keep only Alphanumeric
          String text = line.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
          
          if (text.length >= 7 && text.length <= 9) {
            foundInFrame = true;
            if (mounted) setState(() => _debugText = "Detected: $text");
            
            // Apply Nigerian format LLL-NNN-LL
            if (text.length == 8) {
              text = _formatAndFixPlate(text);
              _tallyVote(text);
            }
          }
        }
      }
      
      if (!foundInFrame && mounted) {
        setState(() => _debugText = "Align plate in frame...");
      }
    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  String _formatAndFixPlate(String raw) {
    List<String> s = raw.split('');
    // Nigerian Format Template: LLL NNN LL
    // Correct common OCR swaps based on position
    for (int i = 0; i < 3; i++) {
      if (s[i] == '0') s[i] = 'O';
      if (s[i] == '1') s[i] = 'I';
      if (s[i] == '5') s[i] = 'S';
    }
    for (int i = 3; i < 6; i++) {
      if (s[i] == 'O') s[i] = '0';
      if (s[i] == 'I') s[i] = '1';
      if (s[i] == 'S') s[i] = '5';
    }
    for (int i = 6; i < 8; i++) {
      if (s[i] == '0') s[i] = 'O';
      if (s[i] == '1') s[i] = 'I';
    }
    return "${s[0]}${s[1]}${s[2]}-${s[3]}${s[4]}${s[5]}${s[6]}${s[7]}";
  }

  void _tallyVote(String plate) {
    _votes[plate] = (_votes[plate] ?? 0) + 1;
    if (_votes[plate]! >= _threshold) {
      if (mounted && _lockedResult != plate) {
        setState(() {
          _lockedResult = plate;
          _isScanning = false;
        });
        _showSuccessSheet(plate);
      }
    }
  }

  void _showSuccessSheet(String plate) {
    final data = _mockDb[plate] ?? {
      'status': 'VERIFIED',
      'owner': 'Registered Citizen',
      'vehicle': 'Detected Vehicle',
      'toll': 'Compliant',
      'color': Colors.blueAccent,
    };

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('PLATE VERIFIED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text(plate, style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Divider(color: Colors.white12, height: 40),
            _infoRow('STATUS', data['status'], data['color']),
            _infoRow('OWNER', data['owner'], Colors.white),
            _infoRow('VEHICLE', data['vehicle'], Colors.white),
            _infoRow('TOLL FEE', data['toll'], Colors.white),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _lockedResult = null;
                  _votes.clear();
                  _isScanning = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('CONTINUE SCANNING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;
    
    final camera = _cameras![0];
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          // Debug Header
          Positioned(
            top: 50, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Text(_debugText, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          // Scanning Frame
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: _lockedResult != null ? Colors.green : Colors.blueAccent, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          if (_isScanning)
            const Positioned(
              bottom: 80, left: 0, right: 0,
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                    SizedBox(height: 10),
                    Text('SCANNING FOR NIGERIAN PLATE...', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
