import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';

class MLKitService {
  static final MLKitService _instance = MLKitService._internal();
  factory MLKitService() => _instance;
  MLKitService._internal();

  late final TextRecognizer _textRecognizer;
  late final BarcodeScanner _barcodeScanner;

  void initialize() {
    _textRecognizer = TextRecognizer();
    _barcodeScanner = BarcodeScanner();
  }

  void dispose() {
    _textRecognizer.close();
    _barcodeScanner.close();
  }

  /// Scan for barcodes in the image
  Future<List<Barcode>> scanBarcodes(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      debugPrint('Found ${barcodes.length} barcodes');
      for (final barcode in barcodes) {
        debugPrint('Barcode: ${barcode.displayValue} (${barcode.type})');
      }

      return barcodes;
    } catch (e) {
      debugPrint('Error scanning barcodes: $e');
      return [];
    }
  }

  /// Extract text from image using OCR
  Future<RecognizedText> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      debugPrint('Recognized text: ${recognizedText.text}');
      return recognizedText;
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      rethrow;
    }
  }

  /// Extract potential expiry dates from recognized text
  List<String> extractExpiryDates(RecognizedText recognizedText) {
    final List<String> potentialDates = [];

    // Common date patterns
    final datePatterns = [
      // MM/DD/YYYY, MM/DD/YY
      RegExp(r'\b(0?[1-9]|1[0-2])/(0?[1-9]|[12][0-9]|3[01])/(\d{2}|\d{4})\b'),
      // DD/MM/YYYY, DD/MM/YY
      RegExp(r'\b(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/(\d{2}|\d{4})\b'),
      // YYYY-MM-DD
      RegExp(r'\b(\d{4})-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01])\b'),
      // DD-MM-YYYY
      RegExp(r'\b(0?[1-9]|[12][0-9]|3[01])-(0?[1-9]|1[0-2])-(\d{2}|\d{4})\b'),
      // DD.MM.YYYY
      RegExp(r'\b(0?[1-9]|[12][0-9]|3[01])\.(0?[1-9]|1[0-2])\.(\d{2}|\d{4})\b'),
      // Month DD, YYYY (e.g., Jan 25, 2025)
      RegExp(
        r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2}),?\s+(\d{4})\b',
        caseSensitive: false,
      ),
      // DD Month YYYY (e.g., 25 Jan 2025)
      RegExp(
        r'\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{4})\b',
        caseSensitive: false,
      ),
    ];

    // Search for dates in all text blocks
    for (final textBlock in recognizedText.blocks) {
      for (final textLine in textBlock.lines) {
        final text = textLine.text;

        for (final pattern in datePatterns) {
          final matches = pattern.allMatches(text);
          for (final match in matches) {
            final dateStr = match.group(0);
            if (dateStr != null && !potentialDates.contains(dateStr)) {
              potentialDates.add(dateStr);
            }
          }
        }
      }
    }

    // Look for keywords that might indicate expiry dates
    final expiryKeywords = [
      'exp',
      'expiry',
      'expires',
      'best before',
      'use by',
      'sell by',
    ];

    for (final textBlock in recognizedText.blocks) {
      for (final textLine in textBlock.lines) {
        final text = textLine.text.toLowerCase();

        // Check if line contains expiry keywords
        if (expiryKeywords.any((keyword) => text.contains(keyword))) {
          // Look for dates in nearby lines
          final blockIndex = recognizedText.blocks.indexOf(textBlock);
          final lineIndex = textBlock.lines.indexOf(textLine);

          // Check current line and next few lines
          for (
            int i = lineIndex;
            i < textBlock.lines.length && i < lineIndex + 3;
            i++
          ) {
            final lineText = textBlock.lines[i].text;
            for (final pattern in datePatterns) {
              final matches = pattern.allMatches(lineText);
              for (final match in matches) {
                final dateStr = match.group(0);
                if (dateStr != null && !potentialDates.contains(dateStr)) {
                  potentialDates.add(dateStr);
                }
              }
            }
          }
        }
      }
    }

    debugPrint('Extracted potential expiry dates: $potentialDates');
    return potentialDates;
  }

  /// Get the most likely expiry date from the list
  String? getBestExpiryDate(List<String> dates) {
    if (dates.isEmpty) return null;

    // For now, return the first date found
    // TODO: Implement logic to determine the most likely expiry date
    // based on date format, position in image, etc.
    return dates.first;
  }
}
