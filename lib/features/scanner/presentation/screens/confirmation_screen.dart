import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationScreen extends StatefulWidget {
  final String? scannedImagePath;
  final String? detectedProductName;
  final String? detectedExpiryDate;
  final VoidCallback? onNavigateToInventory;

  const ConfirmationScreen({
    super.key,
    this.scannedImagePath,
    this.detectedProductName,
    this.detectedExpiryDate,
    this.onNavigateToInventory,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  late TextEditingController _expiryDateController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  String _selectedCategory = 'Dairy';
  String _selectedUnit = 'Liters';
  String _selectedLocation = 'Refrigerator';

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(
      text: widget.detectedProductName ?? 'Organic Whole Milk',
    );
    _expiryDateController = TextEditingController(
      text: widget.detectedExpiryDate ?? '01/25/2025',
    );
    _quantityController = TextEditingController(text: '1');
    _notesController = TextEditingController();
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
                      const SizedBox(height: 20),

                      // Similar Products Card
                      _buildSimilarProductsCard(),
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
      padding: const EdgeInsets.all(24),
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
          // Header with scanned image
          Row(
            children: [
              // Product image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child:
                    widget.scannedImagePath != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&h=200&fit=crop',
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 32,
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and edit the information below',
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
            ],
          ),

          const SizedBox(height: 24),

          // Form Fields
          _buildFormField(
            label: 'Product Name',
            controller: _productNameController,
            icon: Icons.shopping_bag_outlined,
            isDetected: widget.detectedProductName?.isNotEmpty ?? false,
          ),
          const SizedBox(height: 16),

          _buildFormField(
            label: 'Expiry Date',
            controller: _expiryDateController,
            icon: Icons.calendar_today_outlined,
            isDetected: widget.detectedExpiryDate?.isNotEmpty ?? false,
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
                  items: [
                    'Dairy',
                    'Meat',
                    'Vegetables',
                    'Fruits',
                    'Grains',
                    'Beverages',
                  ],
                  onChanged:
                      (value) => setState(() => _selectedCategory = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Quantity',
                  controller: _quantityController,
                  icon: Icons.numbers,
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
                  items: ['Liters', 'Pieces', 'Kg', 'Grams', 'Bottles', 'Cans'],
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
              Text(
                'Detection Results',
                style: const TextStyle(
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

          _buildDetectionItem(
            'Barcode Detection',
            'Product identified via barcode scan',
            Icons.qr_code_scanner,
            true,
          ),
          const SizedBox(height: 12),
          _buildDetectionItem(
            'OCR Text Recognition',
            'Expiry date extracted from label',
            Icons.text_fields,
            widget.detectedExpiryDate?.isNotEmpty ?? false,
          ),
          const SizedBox(height: 12),
          _buildDetectionItem(
            'Product Database',
            'Matched with OpenFoodFacts database',
            Icons.storage,
            true,
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

  Widget _buildSimilarProductsCard() {
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
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recommend,
                  color: Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Similar Products',
                style: const TextStyle(
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

          // Similar products list
          _buildSimilarProductItem('Whole Milk 2L', 'Dairy', '2 days ago'),
          const SizedBox(height: 12),
          _buildSimilarProductItem('Organic Milk 1L', 'Dairy', '1 week ago'),
          const SizedBox(height: 12),
          _buildSimilarProductItem('Low-fat Milk', 'Dairy', '2 weeks ago'),
        ],
      ),
    );
  }

  Widget _buildSimilarProductItem(
    String name,
    String category,
    String timeAdded,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                Text(
                  '$category • Added $timeAdded',
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
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'Use',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B82F6),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isDetected = false,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDetected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD1D5DB),
              width: isDetected ? 2 : 1,
            ),
            color:
                isDetected
                    ? const Color(0xFF10B981).withOpacity(0.05)
                    : Colors.white,
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
              suffixIcon:
                  isDetected
                      ? Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Auto-detected',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      )
                      : suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2937),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        _expiryDateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add to Pantry Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Add to pantry logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Product added to pantry!'),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                // Navigate directly to inventory without going back to scan screen
                _navigateToInventory();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add to Pantry',
                  style: const TextStyle(
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
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
}
