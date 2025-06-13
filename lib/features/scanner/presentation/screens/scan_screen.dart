import 'package:camera/camera.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/scanner/presentation/screens/confirmation_screen.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndScan() async {
    if (!_isCameraInitialized || _isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // TODO: Implement actual scanning logic
      // 1. Take picture
      // 2. Run barcode detection
      // 3. Run OCR for expiry date
      // 4. Navigate to confirmation screen

      await Future.delayed(const Duration(seconds: 2)); // Simulate processing

      // Navigate to confirmation screen and pause camera
      if (mounted) {
        await _pauseCameraAndNavigate(
          detectedProductName: 'Organic Whole Milk',
          detectedExpiryDate: '01/25/2025',
        );
      }
    } catch (e) {
      debugPrint('Scanning error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _navigateToInventory() {
    // Find the app shell in the widget tree and switch to inventory tab (index 1)
    final appShellState = context.findAncestorStateOfType<AppShellState>();
    if (appShellState != null) {
      appShellState.onItemTapped(1); // Index 1 is inventory
    }
  }

  Future<void> _pauseCameraAndNavigate({
    required String detectedProductName,
    required String detectedExpiryDate,
  }) async {
    // Pause the camera to save battery
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.pausePreview();
    }

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ConfirmationScreen(
                detectedProductName: detectedProductName,
                detectedExpiryDate: detectedExpiryDate,
                onNavigateToInventory: _navigateToInventory,
              ),
        ),
      );

      // Resume camera when returning from confirmation
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.resumePreview();
      }
    }
  }

  Future<void> _handleManualEntry() async {
    // Pause camera for manual entry too
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.pausePreview();
    }

    if (mounted) {
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
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.resumePreview();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B981),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Text(
                  'Position the product label within the frame. The app will automatically detect barcodes and expiry dates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E40AF),
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
                  onPressed: _isScanning ? null : _captureAndScan,
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
                          : const Text(
                            'Scan Product',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 12),

              // Manual Entry Option
              TextButton(
                onPressed: _handleManualEntry,
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
            child: Text(
              'Smart Scanner',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.3,
              ),
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
              onPressed: () {},
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
