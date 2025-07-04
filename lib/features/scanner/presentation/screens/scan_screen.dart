import 'package:camera/camera.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/scanner/presentation/screens/confirmation_screen.dart';
import 'package:eat_soon/features/scanner/data/services/scanner_service.dart';
import 'package:eat_soon/features/scanner/data/services/ml_kit_service.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';

// -------------------------------------------------------------
// Scan workflow steps: product scan first, optional expiry date scan
// -------------------------------------------------------------

enum _ScanMode { product, expiryDate }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isDisposed = false;
  bool _cameraInitializationFailed = false;

  final ScannerService _scannerService = ScannerService();
  // Current step in the scan flow.
  _ScanMode _scanMode = _ScanMode.product;

  // Holds the first scan result (product info) while we ask the user to scan the expiry date.
  ScanResult? _initialScanResult;

  // Dynamic UI helpers -------------------------------------------------------
  String get _instructionText {
    if (_cameraInitializationFailed) {
      return 'scan_camera_failed_instruction'.tr;
    }
    if (_scanMode == _ScanMode.expiryDate) {
      return 'scan_expiry_instruction'.tr;
    }
    return 'scan_product_instruction'.tr;
  }

  String get _scanButtonLabel =>
      _scanMode == _ScanMode.expiryDate
          ? 'scan_button_scan_expiry'.tr
          : 'scan_button_scan_product'.tr;

  // Keep state alive to prevent camera reinitialization when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerService.initialize();
    _initializeCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _scannerService.dispose();
    _disposeCamera();
    super.dispose();
  }

  // Handle app lifecycle changes to properly manage camera
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _disposeCamera();
        break;
    }
  }

  void _handleAppPaused() {
    debugPrint('App paused - pausing camera to prevent conflicts');
    // Just pause instead of disposing to avoid buffer issues
    _pauseCamera();
  }

  void _handleAppResumed() {
    debugPrint('App resumed - resuming camera');
    // Resume instead of reinitializing to prevent buffer conflicts
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isDisposed && mounted) {
        _resumeCamera();
      }
    });
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed) return;

    debugPrint('Initializing camera...');

    // Reset failed state when starting initialization
    if (mounted && !_isDisposed) {
      setState(() {
        _cameraInitializationFailed = false;
      });
    }

    try {
      // Ensure any existing controller is disposed first
      if (_cameraController != null) {
        await _disposeCamera();
        // Add small delay to ensure cleanup is complete
        await Future.delayed(const Duration(milliseconds: 200));
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        debugPrint('Found ${_cameras!.length} cameras');

        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.low, // Use low resolution to reduce buffer usage
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();
        debugPrint('Camera initialized successfully');

        if (mounted && !_isDisposed) {
          setState(() {
            _isCameraInitialized = true;
            _cameraInitializationFailed = false;
          });
        }
      } else {
        debugPrint('No cameras available');
        if (mounted && !_isDisposed) {
          setState(() {
            _cameraInitializationFailed = true;
          });
          _showErrorSnackBar('scan_no_cameras'.tr);
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isCameraInitialized = false;
          _cameraInitializationFailed = true;
        });
        _showErrorSnackBar('scan_camera_failed_start'.tr);
      }
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      try {
        if (_cameraController!.value.isInitialized) {
          // Stop preview first to prevent new frames
          await _cameraController!.pausePreview();
          // Add delay to ensure all buffers are released
          await Future.delayed(const Duration(milliseconds: 300));
          await _cameraController!.dispose();
        }
      } catch (e) {
        debugPrint('Camera disposal error: $e');
      } finally {
        _cameraController = null;
        if (mounted && !_isDisposed) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
      }
    }
  }

  Future<void> _pauseCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.pausePreview();
      } catch (e) {
        debugPrint('Camera pause error: $e');
      }
    }
  }

  Future<void> _resumeCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Small delay to prevent buffer conflicts
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isDisposed) {
          await _cameraController!.resumePreview();
        }
      } catch (e) {
        debugPrint('Camera resume error: $e');
        // Only reinitialize if resume fails
        await _reinitializeCamera();
      }
    } else if (!_isDisposed) {
      // Camera not initialized, try to initialize
      await _initializeCamera();
    }
  }

  Future<void> _reinitializeCamera() async {
    await _disposeCamera();
    await _initializeCamera();
  }

  Future<void> _captureAndScan() async {
    if (!_isCameraInitialized || _isScanning || _isDisposed) return;

    // Delegate to the secondary scan when we are collecting the expiry date.
    if (_scanMode == _ScanMode.expiryDate) {
      await _captureExpiryDateScan();
      return;
    }

    // Prevent rapid consecutive scans to avoid buffer buildup
    if (_isScanning) {
      debugPrint('Scan already in progress, ignoring request');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    XFile? imageFile;
    try {
      // Take picture
      imageFile = await _cameraController!.takePicture();
      debugPrint('Image captured: ${imageFile.path}');

      // Perform full scan (barcode + OCR)
      final scanResult = await _scannerService.scanImage(imageFile.path);

      debugPrint('Scan completed: $scanResult');

      if (mounted && !_isDisposed) {
        if (scanResult.isSuccess) {
          if (!scanResult.hasExpiryDate) {
            // We have product info but no expiry date – ask the user to scan again.
            _initialScanResult = scanResult;
            setState(() {
              _scanMode = _ScanMode.expiryDate;
            });
            _showErrorSnackBar('scan_expiry_not_detected'.tr);
          } else {
            // We have all we need – proceed to confirmation.
            await _pauseCameraAndNavigate(
              scannedImagePath: imageFile.path,
              detectedProductName: scanResult.productName,
              detectedExpiryDate: scanResult.detectedExpiryDate,
              productImageUrl: scanResult.productInfo?.imageUrl,
              scanResult: scanResult,
            );
          }
        } else {
          _showErrorSnackBar(
            scanResult.errorMessage ?? 'scan_scanning_failed'.tr,
          );
        }
      }
    } catch (e) {
      debugPrint('Scanning error: $e');
      if (mounted && !_isDisposed) {
        _showErrorSnackBar('Failed to scan: $e');
      }
    } finally {
      // Clean up image file
      if (imageFile != null) {
        try {
          final file = File(imageFile.path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error cleaning up image file: $e');
        }
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // Secondary scan that only tries to find an expiry date using OCR.
  Future<void> _captureExpiryDateScan() async {
    if (!_isCameraInitialized || _isScanning || _isDisposed) return;

    setState(() {
      _isScanning = true;
    });

    XFile? imageFile;
    try {
      imageFile = await _cameraController!.takePicture();
      debugPrint('Image captured for expiry date: ${imageFile.path}');

      // OCR-only pass
      final recognizedText = await _scannerService.quickTextScan(
        imageFile.path,
      );

      final mlService = MLKitService();
      final dates = mlService.extractExpiryDates(recognizedText);
      final bestDate = mlService.getBestExpiryDate(dates);

      await _pauseCameraAndNavigate(
        scannedImagePath: imageFile.path,
        detectedProductName: _initialScanResult?.productName,
        detectedExpiryDate: bestDate,
        productImageUrl: _initialScanResult?.productInfo?.imageUrl,
        scanResult: _initialScanResult,
      );
    } catch (e) {
      debugPrint('Expiry date scan error: $e');
      if (mounted && !_isDisposed) {
        _showErrorSnackBar(
          'scan_failed_scan_expiry_date'.trArgs([e.toString()]),
        );
        // Proceed to confirmation without expiry date
        await _pauseCameraAndNavigate(
          detectedProductName: _initialScanResult?.productName,
          detectedExpiryDate: null,
          productImageUrl: _initialScanResult?.productInfo?.imageUrl,
          scanResult: _initialScanResult,
        );
      }
    } finally {
      if (imageFile != null) {
        try {
          final file = File(imageFile.path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Cleanup error: $e');
        }
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _isScanning = false;
          _scanMode = _ScanMode.product;
          _initialScanResult = null;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToInventory() {
    // Find the app shell in the widget tree and switch to inventory tab (index 1)
    final appShellState = context.findAncestorStateOfType<AppShellState>();
    if (appShellState != null) {
      appShellState.onItemTapped(1); // Index 1 is inventory
    }
  }

  Future<void> _pauseCameraAndNavigate({
    String? scannedImagePath,
    String? detectedProductName,
    String? detectedExpiryDate,
    String? productImageUrl,
    ScanResult? scanResult,
  }) async {
    // Dispose camera completely to clear image buffer
    await _disposeCamera();

    if (mounted && !_isDisposed) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmationScreen(
                scannedImagePath: scannedImagePath,
                detectedProductName: detectedProductName ?? '',
                detectedExpiryDate: detectedExpiryDate ?? '',
                productImageUrl: productImageUrl,
                onNavigateToInventory: _navigateToInventory,
              ),
        ),
      );

      // Reinitialize camera when returning to ensure fresh preview
      await _initializeCamera();
    }
  }

  Future<void> _handleManualEntry() async {
    // Dispose camera completely for manual entry too
    await _disposeCamera();

    if (mounted && !_isDisposed) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmationScreen(
                detectedProductName: '',
                detectedExpiryDate: '',
                productImageUrl: null, // No product image for manual entry
                onNavigateToInventory: _navigateToInventory,
              ),
        ),
      );

      // Reinitialize camera when returning from manual entry
      await _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsooon'),
      body: _buildScanView(),
    );
  }

  Widget _buildScanView() {
    return Column(
      children: [
        // Camera Preview Section - Maximum height allocation without subheader
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              16,
            ), // Added top margin to replace subheader space
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Camera Preview - Natural aspect ratio without cropping
                  if (_isCameraInitialized)
                    Positioned.fill(child: CameraPreview(_cameraController!))
                  else if (_cameraInitializationFailed)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'scan_camera_failed_title'.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'scan_camera_failed_subtitle'.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _cameraInitializationFailed = false;
                              });
                              await _reinitializeCamera();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 20),
                                const SizedBox(width: 8),
                                Text('scan_restart_camera'.tr),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'scan_initializing_camera'.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Scanning Overlay
                  if (_isScanning)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'scan_scanning_product'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'scan_detecting_barcodes'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Scan Frame Overlay
                  if (!_isScanning)
                    Positioned.fill(
                      child: CustomPaint(painter: ScanFramePainter()),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Instructions and Action Section - More flexible to prevent overflow
        SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8, // Reduced padding
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Instructions
                Flexible(
                  // Wrap in Flexible to prevent overflow
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                    decoration: BoxDecoration(
                      color:
                          _cameraInitializationFailed
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _cameraInitializationFailed
                                ? const Color(0xFFFECACA)
                                : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Text(
                      _instructionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11, // Reduced from 12 to 11
                        fontWeight: FontWeight.w400,
                        color:
                            _cameraInitializationFailed
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF1E40AF),
                        height: 1.2, // Reduced from 1.3 to 1.2
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12), // Reduced from 16 to 12
                // Scan Button
                SizedBox(
                  width: double.infinity,
                  height: 50, // Standard button height
                  child: ElevatedButton(
                    onPressed:
                        (_isScanning || !_isCameraInitialized)
                            ? null
                            : _captureAndScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      disabledBackgroundColor: const Color(0xFF6B7280),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isScanning
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _scanButtonLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(height: 8), // Reduced spacing
                // Manual Entry Option
                TextButton(
                  onPressed: _isScanning ? null : _handleManualEntry,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                    ), // Reduced padding
                  ),
                  child: Text(
                    'scan_enter_manual'.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for the scan frame overlay
class ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final frameSize = size.width * 0.7;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(left + frameSize - cornerLength, top),
      Offset(left + frameSize, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + frameSize, top),
      Offset(left + frameSize, top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + frameSize - cornerLength),
      Offset(left, top + frameSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + frameSize),
      Offset(left + cornerLength, top + frameSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + frameSize - cornerLength, top + frameSize),
      Offset(left + frameSize, top + frameSize),
      paint,
    );
    canvas.drawLine(
      Offset(left + frameSize, top + frameSize),
      Offset(left + frameSize, top + frameSize - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
