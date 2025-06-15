import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:eat_soon/features/scanner/data/services/ml_kit_service.dart';
import 'package:eat_soon/features/scanner/data/services/openfoodfacts_service.dart';

class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  final MLKitService _mlKitService = MLKitService();
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();

  void initialize() {
    _mlKitService.initialize();
  }

  void dispose() {
    _mlKitService.dispose();
  }

  /// Perform complete scan of an image for product information and expiry date
  Future<ScanResult> scanImage(String imagePath) async {
    debugPrint('Starting scan for image: $imagePath');

    try {
      // Run barcode scanning and text recognition in parallel
      final futures = await Future.wait([
        _mlKitService.scanBarcodes(imagePath),
        _mlKitService.recognizeText(imagePath),
      ]);

      final barcodes = futures[0] as List<Barcode>;
      final recognizedText = futures[1] as RecognizedText;

      // Extract expiry dates from OCR text
      final potentialDates = _mlKitService.extractExpiryDates(recognizedText);
      final bestExpiryDate = _mlKitService.getBestExpiryDate(potentialDates);

      // Try to get product info from barcode
      ProductInfo? productInfo;
      String? detectedBarcode;

      if (barcodes.isNotEmpty) {
        // Use the first valid barcode found
        for (final barcode in barcodes) {
          if (barcode.displayValue != null &&
              barcode.displayValue!.isNotEmpty) {
            detectedBarcode = barcode.displayValue!;
            debugPrint(
              'Attempting to fetch product info for barcode: $detectedBarcode',
            );

            productInfo = await _openFoodFactsService.getProductInfo(
              detectedBarcode,
            );
            if (productInfo != null) {
              debugPrint('Product found: ${productInfo.productName}');
              break;
            }
          }
        }
      }

      return ScanResult(
        productInfo: productInfo,
        detectedBarcode: detectedBarcode,
        detectedExpiryDate: bestExpiryDate,
        allDetectedDates: potentialDates,
        recognizedText: recognizedText.text,
        barcodeCount: barcodes.length,
        hasProductInfo: productInfo != null,
        hasExpiryDate: bestExpiryDate != null,
      );
    } catch (e) {
      debugPrint('Error during scanning: $e');
      return ScanResult.error('Failed to scan image: $e');
    }
  }

  /// Quick barcode-only scan for faster processing
  Future<List<Barcode>> quickBarcodeScan(String imagePath) async {
    return await _mlKitService.scanBarcodes(imagePath);
  }

  /// Quick text-only scan for faster processing
  Future<RecognizedText> quickTextScan(String imagePath) async {
    return await _mlKitService.recognizeText(imagePath);
  }
}

class ScanResult {
  final ProductInfo? productInfo;
  final String? detectedBarcode;
  final String? detectedExpiryDate;
  final List<String> allDetectedDates;
  final String? recognizedText;
  final int barcodeCount;
  final bool hasProductInfo;
  final bool hasExpiryDate;
  final bool isSuccess;
  final String? errorMessage;

  ScanResult({
    this.productInfo,
    this.detectedBarcode,
    this.detectedExpiryDate,
    this.allDetectedDates = const [],
    this.recognizedText,
    this.barcodeCount = 0,
    this.hasProductInfo = false,
    this.hasExpiryDate = false,
    this.isSuccess = true,
    this.errorMessage,
  });

  ScanResult.error(String error)
    : productInfo = null,
      detectedBarcode = null,
      detectedExpiryDate = null,
      allDetectedDates = const [],
      recognizedText = null,
      barcodeCount = 0,
      hasProductInfo = false,
      hasExpiryDate = false,
      isSuccess = false,
      errorMessage = error;

  /// Get the product name from various sources
  String? get productName {
    if (productInfo?.productName != null &&
        productInfo!.productName!.isNotEmpty) {
      return productInfo!.productName;
    }
    return null;
  }

  /// Get the category from product info or default
  String get category {
    return productInfo?.category ?? 'Dairy'; // Default category
  }

  /// Get a display-friendly summary of what was detected
  String get detectionSummary {
    final List<String> detected = [];

    if (hasProductInfo) {
      detected.add('Product identified');
    }
    if (hasExpiryDate) {
      detected.add('Expiry date found');
    }
    if (barcodeCount > 0) {
      detected.add('$barcodeCount barcode(s)');
    }

    if (detected.isEmpty) {
      return 'No information detected';
    }

    return detected.join(', ');
  }

  @override
  String toString() {
    return 'ScanResult(product: ${productName ?? 'Unknown'}, '
        'expiry: ${detectedExpiryDate ?? 'Not found'}, '
        'barcode: ${detectedBarcode ?? 'None'}, '
        'success: $isSuccess)';
  }
}
