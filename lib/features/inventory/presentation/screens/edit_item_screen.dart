import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';
import 'package:intl/intl.dart';
import 'package:eat_soon/features/home/models/food_item.dart';

class EditItemScreen extends StatefulWidget {
  final FoodItem item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventoryService _inventoryService = InventoryService();

  late TextEditingController _productNameController;
  late TextEditingController _expiryDateController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  late String _selectedCategory;
  late List<String> _categoryItems;
  late String _selectedUnit;
  late String _selectedLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _productNameController = TextEditingController(text: item.name);
    _expiryDateController = TextEditingController(
      text: DateFormat('MM/dd/yyyy').format(item.expirationDate),
    );
    _quantityController = TextEditingController(text: item.quantity.toString());
    _notesController = TextEditingController(text: item.notes);

    _categoryItems = [
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
    ];
    _selectedCategory = item.category;
    if (!_categoryItems.contains(_selectedCategory)) {
      _categoryItems.insert(0, _selectedCategory);
    }

    _selectedUnit = item.unit;
    _selectedLocation = item.storageLocation;
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
          _buildSubHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildFormField(
                        label: 'Product Name',
                        controller: _productNameController,
                        icon: Icons.shopping_bag_outlined,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: 'Expiry Date',
                        controller: _expiryDateController,
                        icon: Icons.calendar_today_outlined,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Expiry date is required';
                          }
                          return null;
                        },
                        suffix: IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: _selectDate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Category',
                              value: _selectedCategory,
                              icon: Icons.category_outlined,
                              items: _categoryItems,
                              onChanged:
                                  (value) => setState(
                                    () => _selectedCategory = value!,
                                  ),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    double.tryParse(value) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                              onChanged:
                                  (value) =>
                                      setState(() => _selectedUnit = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Storage',
                              value: _selectedLocation,
                              icon: Icons.kitchen_outlined,
                              items: const [
                                'Refrigerator',
                                'Freezer',
                                'Pantry',
                                'Counter',
                              ],
                              onChanged:
                                  (value) => setState(
                                    () => _selectedLocation = value!,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: 'Notes (Optional)',
                        controller: _notesController,
                        icon: Icons.note_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: const Color(
                              0xFF10B981,
                            ).withOpacity(0.5),
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
                                  : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                        ),
                      ),
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
                const Text(
                  'Edit Item',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const Text(
                  'Update the item details below',
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
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime initial;
    try {
      initial = _parseExpiryDate(_expiryDateController.text);
    } catch (e) {
      initial = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isRequired = false,
    Widget? suffix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            color: Colors.white,
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
              suffixIcon: suffix,
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
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final expiryDate = _parseExpiryDate(_expiryDateController.text);
      await _inventoryService.updateFoodItem(
        itemId: widget.item.id,
        name: _productNameController.text.trim(),
        expirationDate: expiryDate,
        category: _selectedCategory,
        quantity: double.parse(_quantityController.text.trim()),
        unit: _selectedUnit,
        storageLocation: _selectedLocation,
        notes: _notesController.text.trim(),
        imageUrl: widget.item.imageUrl,
        barcode: widget.item.barcode,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Item updated successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to update item: ${e.toString()}')),
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

  DateTime _parseExpiryDate(String dateString) {
    return DateFormat('MM/dd/yyyy').parse(dateString);
  }
}
