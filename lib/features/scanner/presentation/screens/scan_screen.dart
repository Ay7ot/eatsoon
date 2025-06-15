import 'package:camera/camera.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/scanner/presentation/screens/confirmation_screen.dart';
import 'package:eat_soon/features/scanner/data/services/scanner_service.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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
    debugPrint('App paused - disposing camera to prevent conflicts');
    // Dispose camera completely when app goes to background
    _disposeCamera();
  }

  void _handleAppResumed() {
    debugPrint('App resumed - reinitializing camera');
    // Add delay and reinitialize camera when app comes back to foreground
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isDisposed && mounted) {
        _reinitializeCamera();
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
          ResolutionPreset.medium, // Use medium for better stability
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
          _showErrorSnackBar('No cameras available on this device');
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isCameraInitialized = false;
          _cameraInitializationFailed = true;
        });
        _showErrorSnackBar('Camera failed to start. Try the restart button.');
      }
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      try {
        if (_cameraController!.value.isInitialized) {
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
        // Add small delay to prevent buffer conflicts
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isDisposed) {
          await _cameraController!.resumePreview();
        }
      } catch (e) {
        debugPrint('Camera resume error: $e');
        // If resume fails, try reinitializing
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

    setState(() {
      _isScanning = true;
    });

    try {
      // Take picture
      final XFile imageFile = await _cameraController!.takePicture();
      debugPrint('Image captured: ${imageFile.path}');

      // Perform ML Kit scanning
      final scanResult = await _scannerService.scanImage(imageFile.path);

      debugPrint('Scan completed: $scanResult');

      if (mounted && !_isDisposed) {
        if (scanResult.isSuccess) {
          // Navigate to confirmation screen with detected data
          await _pauseCameraAndNavigate(
            scannedImagePath: imageFile.path,
            detectedProductName: scanResult.productName,
            detectedExpiryDate: scanResult.detectedExpiryDate,
            scanResult: scanResult,
          );
        } else {
          _showErrorSnackBar(scanResult.errorMessage ?? 'Scanning failed');
        }
      }
    } catch (e) {
      debugPrint('Scanning error: $e');
      if (mounted && !_isDisposed) {
        _showErrorSnackBar('Failed to scan: $e');
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isScanning = false;
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
    ScanResult? scanResult,
  }) async {
    // Pause the camera to save battery and prevent buffer issues
    await _pauseCamera();

    if (mounted && !_isDisposed) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmationScreen(
                scannedImagePath: scannedImagePath,
                detectedProductName: detectedProductName ?? '',
                detectedExpiryDate: detectedExpiryDate ?? '',
                onNavigateToInventory: _navigateToInventory,
              ),
        ),
      );

      // Resume camera when returning from confirmation
      await _resumeCamera();
    }
  }

  Future<void> _handleManualEntry() async {
    // Pause camera for manual entry too
    await _pauseCamera();

    if (mounted && !_isDisposed) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmationScreen(
                detectedProductName: '',
                detectedExpiryDate: '',
                onNavigateToInventory: _navigateToInventory,
              ),
        ),
      );

      // Resume camera when returning from confirmation
      await _resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: _buildScanView(),
    );
  }

  Widget _buildScanView() {
    return Column(
      children: [
        // Sub-header for scan
        _buildScanSubHeader(),

        // Camera Preview Section
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(20),
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
                  // Camera Preview
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
                          const Text(
                            'Camera initialization failed',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This can happen after unlocking your phone',
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh, size: 20),
                                SizedBox(width: 8),
                                Text('Restart Camera'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF10B981)),
                          SizedBox(height: 16),
                          Text(
                            'Initializing camera...',
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
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Scanning product...',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Detecting barcodes and expiry dates',
                                style: TextStyle(
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

        // Instructions and Action Section
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cameraInitializationFailed 
                      ? const Color(0xFFFEF2F2) 
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _cameraInitializationFailed 
                        ? const Color(0xFFFECACA) 
                        : const Color(0xFFBFDBFE)
                  ),
                ),
                child: Text(
                  _cameraInitializationFailed
                      ? 'Camera failed to start. This often happens after unlocking your phone. Use the restart button above to fix this.'
                      : 'Position the product label within the frame. The app will automatically detect barcodes and expiry dates using AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _cameraInitializationFailed 
                        ? const Color(0xFFDC2626) 
                        : const Color(0xFF1E40AF),
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Scan Button
              SizedBox(
                width: double.infinity,
                height: 50,
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
                              const Text(
                                'Scan Product',
                                style: TextStyle(
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

              const SizedBox(height: 12),

              // Manual Entry Option
              TextButton(
                onPressed: _isScanning ? null : _handleManualEntry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Enter product manually',
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
      ],
    );
  }

  Widget _buildScanSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Scanner',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const Text(
                  'AI-powered barcode and expiry date detection',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Color(0xFF4B5563),
                size: 20,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Smart Scanner Help'),
                        content: const Text(
                          'Point your camera at a product label or barcode. The app will:\n\n'
                          '• Detect barcodes and look up product information\n'
                          '• Find expiry dates using text recognition\n'
                          '• Allow manual entry if detection fails\n\n'
                          'Make sure the label is well-lit and clearly visible.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                );
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
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
