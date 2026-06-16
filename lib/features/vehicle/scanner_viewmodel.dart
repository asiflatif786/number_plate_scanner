import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/plate_extractor.dart';

class ScannerViewModel extends ChangeNotifier {
  static const String _tag = 'ScannerVM';

  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();

  bool isInitialized = false;
  bool isScanning = false;
  String? detectedText;
  String? extractedPlate;
  bool hasPermission = true;
  String? errorMessage;
  bool isTorchOn = false;
  bool isProcessing = false;

  CameraController? get cameraController => _cameraController;

  DateTime _lastProcessed = DateTime.now();
  static const int _processIntervalMs = 500;

  List<CameraDescription>? _availableCameras;

  Future<void> initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      hasPermission = false;
      errorMessage = 'Camera permission required';
      notifyListeners();
      return;
    }

    hasPermission = true;
    notifyListeners();

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras == null || _availableCameras!.isEmpty) {
        errorMessage = 'No camera available';
        notifyListeners();
        return;
      }

      _cameraController = CameraController(
        _availableCameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      isInitialized = true;
      notifyListeners();

      _startScanning();
    } catch (e) {
      errorMessage = 'Failed to initialize camera. Please try again.';
      AppLogger.logError(_tag, 'initialize error', e);
      notifyListeners();
    }
  }

  void _startScanning() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    isScanning = true;
    notifyListeners();

    try {
      _cameraController!.startImageStream(_onImageStream);
    } catch (e) {
      AppLogger.logError(_tag, 'startImageStream error', e);
    }
  }

  void _onImageStream(CameraImage image) {
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < _processIntervalMs) {
      return;
    }
    if (!isScanning || isProcessing) return;
    isProcessing = true;
    _lastProcessed = now;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        isProcessing = false;
        return;
      }

      _textRecognizer.processImage(inputImage).then((result) {
        if (!isScanning) {
          isProcessing = false;
          return;
        }

        detectedText = result.text;
        AppLogger.logDebug(_tag, 'OCR raw text: "${result.text.trim()}"');

        final plate = _extractLicensePlate(result.text);
        if (plate != null) {
          AppLogger.logInfo(_tag, 'Plate detected: $plate');
        }
        if (plate != null && extractedPlate == null) {
          extractedPlate = plate;
          isScanning = false;
          _stopImageStream();
          notifyListeners();
        }
        isProcessing = false;
      }).catchError((_) {
        isProcessing = false;
      });
    } catch (e) {
      isProcessing = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation rotation;
    switch (sensorOrientation) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
      case 180:
        rotation = InputImageRotation.rotation180deg;
      case 270:
        rotation = InputImageRotation.rotation270deg;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    final formatGroup = image.format.group;
    InputImageFormat format;
    if (formatGroup == ImageFormatGroup.bgra8888) {
      format = InputImageFormat.bgra8888;
    } else if (formatGroup == ImageFormatGroup.yuv420) {
      format = InputImageFormat.yuv_420_888;
    } else {
      format = InputImageFormat.nv21;
    }

    AppLogger.logDebug(_tag,
        'Camera image: ${image.width}x${image.height}, format: $formatGroup, planes: ${image.planes.length}, bpr: ${image.planes.first.bytesPerRow}');

    final bytesBuilder = BytesBuilder();
    for (final plane in image.planes) {
      bytesBuilder.add(plane.bytes);
    }
    final bytes = bytesBuilder.toBytes();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  String? _extractLicensePlate(String rawText) {
    return PlateExtractor.extractPlate(rawText);
  }

  Future<void> toggleTorch() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        return;
      }
      isTorchOn = !isTorchOn;
      await _cameraController!.setFlashMode(
        isTorchOn ? FlashMode.torch : FlashMode.off,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.logError(_tag, 'toggleTorch error', e);
    }
  }

  void retryScanning() {
    extractedPlate = null;
    detectedText = null;
    isProcessing = false;
    notifyListeners();
    _startScanning();
  }

  void confirmPlate(BuildContext context) {
    Navigator.pop(context, extractedPlate);
  }

  void _stopImageStream() {
    try {
      _cameraController?.stopImageStream();
    } catch (e) {
      AppLogger.logError(_tag, 'stopImageStream error', e);
    }
  }

  @override
  void dispose() {
    _stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _textRecognizer.close();
    super.dispose();
  }
}
