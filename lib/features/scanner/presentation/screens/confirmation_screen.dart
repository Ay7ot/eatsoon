import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatefulWidget {
  final String? scannedImagePath;
  final String? detectedProductName;
  final String? detectedExpiryDate;
  final String? productImageUrl; // OpenFoodFacts image URL
  final VoidCallback? onNavigateToInventory;

  const ConfirmationScreen({
    super.key,
    this.scannedImagePath,
    this.detectedProductName,
    this.detectedExpiryDate,
    this.productImageUrl,
    this.onNavigateToInventory,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventoryService _inventoryService = InventoryService();
  final ActivityService _activityService = ActivityService();

  late TextEditingController _productNameController;
  late TextEditingController _expiryDateController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  String _selectedCategory = 'Dairy';
  String _selectedUnit = 'Liters';
  String _selectedLocation = 'Refrigerator';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(
      text: widget.detectedProductName ?? 'Organic Whole Milk',
    );
    // Initialize expiry date controller with human-readable format
    final initialDateString = widget.detectedExpiryDate ?? '01/25/2025';
    final initialDate =
        _tryParseExpiryDate(initialDateString) ??
        DateTime.now().add(const Duration(days: 7));
    _expiryDateController = TextEditingController(
      text: _formatDateForDisplay(initialDate),
    );
    _quantityController = TextEditingController(text: '1');
    _notesController = TextEditingController();

    // Log scan activity when screen is initialized
    _logScanActivity();
  }

  void _logScanActivity() {
    // Log that a scan was performed
    _activityService.logScanPerformed(widget.detectedProductName);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _expiryDateController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00E5E7EB), AppTheme.secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.5, 1.0],
            ),
            border: Border(
              bottom: BorderSide(color: AppTheme.borderColor, width: 0.8),
            ),
          ),
          child: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            automaticallyImplyLeading: false,
            title: Text(
              'Eatsoon',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
                fontSize: 26,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              GestureDetector(
                onTap: () {
                  // Navigate to profile tab (index 4) using AppShell navigation
                  final shellState = AppShell.shellKey.currentState;
                  if (shellState != null) {
                    shellState.navigateToTab(4); // Profile tab is at index 4
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: AppTheme.whiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/settings_icon.svg',
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.secondaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Sub-header for confirmation context
          _buildSubHeader(),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Success Banner
                      _buildSuccessBanner(),
                      const SizedBox(height: 24),

                      // Main Product Card
                      _buildMainProductCard(),
                      const SizedBox(height: 20),

                      // Detection Results Card
                      _buildDetectionResultsCard(),
                      const SizedBox(height: 32),

                      // Action Buttons
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF4B5563),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Product Details',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                Text(
                  'Review and edit before adding to pantry',
                  style: const TextStyle(
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
                // Show help dialog or navigate to help screen
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Product Confirmation Help'),
                        content: const Text(
                          'Review the detected product information and make any necessary corrections before adding it to your pantry. Auto-detected fields are highlighted in green.',
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

  Widget _buildSuccessBanner() {
    final bool hasDetectedData =
        (widget.detectedProductName?.isNotEmpty ?? false) ||
        (widget.detectedExpiryDate?.isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDetectedData
                      ? 'Product Detected Successfully!'
                      : 'Manual Entry Mode',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF064E3B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasDetectedData
                      ? 'Review and confirm the details below'
                      : 'Enter product details manually',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF047857),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProductCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with product image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image from scan or database
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Review and edit the information below',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.2,
                      ),
                    ),

                    // Auto-detection indicators if any fields were detected
                    if ((widget.detectedProductName?.isNotEmpty ?? false) ||
                        (widget.detectedExpiryDate?.isNotEmpty ?? false))
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'AI-detected fields',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF10B981),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Form Fields
          _buildFormField(
            label: 'Product Name',
            controller: _productNameController,
            icon: Icons.shopping_bag_outlined,
            isDetected: widget.detectedProductName?.isNotEmpty ?? false,
            isRequired: true,
            validator: _validateProductName,
          ),
          const SizedBox(height: 16),

          _buildFormField(
            label: 'Expiry Date',
            controller: _expiryDateController,
            icon: Icons.calendar_today_outlined,
            isDetected: widget.detectedExpiryDate?.isNotEmpty ?? false,
            isRequired: true,
            validator: _validateExpiryDate,
            suffix: IconButton(
              icon: const Icon(
                Icons.edit_calendar,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              onPressed: () => _selectDate(),
            ),
          ),
          const SizedBox(height: 16),

          // Category and Quantity Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Category',
                  value: _selectedCategory,
                  icon: Icons.category_outlined,
                  items: const [
                    'Bakery',
                    'Beverages',
                    'Dairy',
                    'Frozen',
                    'Fruits',
                    'Meat',
                    'Pantry',
                    'Snacks',
                    'Vegetables',
                    'Other',
                  ],
                  onChanged:
                      (value) => setState(() => _selectedCategory = value!),
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Quantity',
                  controller: _quantityController,
                  icon: Icons.numbers,
                  isRequired: true,
                  validator: _validateQuantity,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Unit and Storage Location Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Unit',
                  value: _selectedUnit,
                  icon: Icons.straighten,
                  items: const [
                    'Liters',
                    'ml',
                    'Kg',
                    'Grams',
                    'Pieces',
                    'Pack(s)',
                    'Bottle(s)',
                    'Can(s)',
                    'lbs',
                    'oz',
                  ],
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Storage',
                  value: _selectedLocation,
                  icon: Icons.kitchen_outlined,
                  items: ['Refrigerator', 'Freezer', 'Pantry', 'Counter'],
                  onChanged:
                      (value) => setState(() => _selectedLocation = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes Field
          _buildFormField(
            label: 'Notes (Optional)',
            controller: _notesController,
            icon: Icons.note_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionResultsCard() {
    // Determine what was actually detected
    final bool hasBarcodeDetection =
        widget.productImageUrl !=
        null; // If we have a product image URL, it likely means barcode was detected
    final bool hasOcrTextDetection =
        widget.detectedExpiryDate?.isNotEmpty ?? false;
    final bool hasProductName = widget.detectedProductName?.isNotEmpty ?? false;

    // No need to show the card if nothing was detected (for manual entry)
    if (!hasBarcodeDetection && !hasOcrTextDetection && !hasProductName) {
      return const SizedBox.shrink(); // Don't show detection card for manual entry
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Results',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show the actual detection results with accurate status icons
          _buildDetectionItem(
            'Barcode Detection',
            hasBarcodeDetection
                ? 'Product matched via database lookup'
                : 'No barcode detected or recognized',
            Icons.qr_code_scanner,
            hasBarcodeDetection,
          ),
          const SizedBox(height: 12),
          _buildDetectionItem(
            'Text Recognition',
            hasOcrTextDetection
                ? 'Expiry date found: ${widget.detectedExpiryDate}'
                : 'No expiry date detected on packaging',
            Icons.text_fields,
            hasOcrTextDetection,
          ),
          const SizedBox(height: 12),
          _buildDetectionItem(
            'Product Name',
            hasProductName
                ? 'Identified: ${widget.detectedProductName}'
                : 'No product name identified',
            Icons.text_format,
            hasProductName,
          ),

          // Add information about how detection works
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Missing information? You can manually enter any details that weren\'t automatically detected.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(
    String title,
    String subtitle,
    IconData icon,
    bool isSuccess,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isSuccess
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            color:
                isSuccess ? const Color(0xFF10B981) : const Color(0xFF6B7280),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                  height: 1.2,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isDetected = false,
    bool isRequired = false,
    Widget? suffix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: controller.text,
      validator: validator,
      builder: (state) {
        // Resolve border color: detected > error > default
        Color borderColor;
        double borderWidth;
        if (state.hasError) {
          borderColor = const Color(0xFFEF4444); // red
          borderWidth = 1.5;
        } else if (isDetected) {
          borderColor = const Color(0xFF10B981); // green
          borderWidth = 1.5;
        } else {
          borderColor = const Color(0xFFD1D5DB); // gray
          borderWidth = 1;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEF4444),
                      height: 1.2,
                    ),
                  ),
                const Spacer(),
                if (isDetected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI-detected',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: borderWidth),
                color: Colors.white,
              ),
              child: TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                  suffixIcon: suffix,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB2B7BE),
                    height: 1.2,
                  ),
                  errorStyle: const TextStyle(
                    height: 0,
                    color: Colors.transparent,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1F2937),
                  height: 1.2,
                ),
                onChanged: (val) {
                  state.didChange(val);
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFEF4444),
                    height: 1.2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
                height: 1.2,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                  height: 1.2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items:
                items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            dropdownColor: Colors.white,
            elevation: 4,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280),
            ),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  void _navigateToInventory() {
    // Pop this screen first
    Navigator.pop(context);

    // Call the callback to navigate to inventory
    if (widget.onNavigateToInventory != null) {
      widget.onNavigateToInventory!();
    }
  }

  Future<void> _addToInventory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse form data
      final productName = _productNameController.text.trim();
      final expiryDate = _parseExpiryDate(_expiryDateController.text.trim());
      final quantity = double.parse(_quantityController.text.trim());
      final notes = _notesController.text.trim();

      // Add to Firestore via InventoryService
      await _inventoryService.addFoodItem(
        name: productName,
        expirationDate: expiryDate,
        category: _selectedCategory,
        quantity: quantity,
        unit: _selectedUnit,
        storageLocation: _selectedLocation,
        notes: notes.isNotEmpty ? notes : null,
        imageUrl:
            widget.productImageUrl, // Store OpenFoodFacts image URL or null
        barcode: null, // TODO: Pass barcode if available from scan result
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('$productName added to pantry!'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navigate to inventory
        _navigateToInventory();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to add item: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add to Pantry Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _addToInventory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFF10B981).withOpacity(0.5),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add to Pantry',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
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

        // Scan Again Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF374151),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Scan Again',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    // Priority 1: Show OpenFoodFacts product image if available
    if (widget.productImageUrl != null && widget.productImageUrl!.isNotEmpty) {
      return Image.network(
        widget.productImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10B981),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // If OpenFoodFacts image fails to load, show fallback
          return _buildFallbackImage();
        },
      );
    }

    // Priority 2: Fallback placeholder image
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Color(0xFF9CA3AF),
        size: 32,
      ),
    );
  }

  String? _validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }
    try {
      final date = _tryParseExpiryDate(value.trim());
      if (date == null) {
        return 'Use format like 27 January 2025';
      }
      final now = DateTime.now();
      if (date.isBefore(DateTime(now.year, now.month, now.day))) {
        return 'Expiry date cannot be in the past';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = double.tryParse(value.trim());
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    return null;
  }

  DateTime _parseExpiryDate(String dateString) {
    return _tryParseExpiryDate(dateString.trim()) ?? DateTime.now();
  }

  // -------------------------------------------------------------------------
  // DATE HELPER METHODS
  // -------------------------------------------------------------------------

  /// Formats a [DateTime] into a human-readable string, e.g. '27 January 2025'.
  String _formatDateForDisplay(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Attempts to parse various date formats that might come from detection or
  /// user input. Returns null if parsing fails.
  DateTime? _tryParseExpiryDate(String input) {
    final trimmed = input.trim();

    final formats = [
      DateFormat('MM/dd/yyyy'),
      DateFormat('M/d/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('d MMMM yyyy'),
    ];

    for (final f in formats) {
      try {
        return f.parseStrict(trimmed);
      } catch (_) {
        // Ignore and try next format
      }
    }
    return null;
  }
}
