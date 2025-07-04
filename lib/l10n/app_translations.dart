import 'package:get/get.dart';

/// Centralised translation map for the entire application.
///
/// • Add new keys in snake_case.
/// • Keep English (`en_US`) as the reference language.
/// • Provide equivalent Spanish (`es_ES`) values.
///
/// When you need a string in a widget: `"login_title".tr`.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': _enUS, 'es_ES': _esES};

  // ---------- English strings ---------- //
  static const Map<String, String> _enUS = {
    // General
    'app_name': 'Eat Soon',
    'language': 'Language',
    'change_language': 'Change app language',
    'english': 'English',
    'spanish': 'Spanish',

    // Auth
    'login_title': 'Login',
    // 'signup_title': 'Sign Up', // removed duplicate
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'logout': 'Logout',

    // Inventory
    'inventory': 'Inventory',
    'add_item': 'Add Item',
    'edit_item': 'Edit Item',
    'inventory_edit_item': 'Edit Item',

    // Family
    'family_members': 'Family Members',
    'create_family': 'Create Family',
    'invite_member': 'Invite Member',

    // Misc
    'settings': 'Settings',

    // Login Screen
    'login_welcome_title': 'Welcome to Eatsooon!',
    'login_welcome_subtitle': 'Hello there, Log in to continue!',
    'login_email_hint': 'Enter Email',
    'login_password_hint': 'Enter password',
    'login_forget_password': 'Forget Password?',
    'login_continue': 'Continue',
    'login_continue_google': 'Continue with Google',
    'login_no_account': "Don't have an account?",
    'login_signup': 'Sign up',
    'login_email_required': 'Please enter your email',
    'login_email_invalid': 'Please enter a valid email',
    'login_password_required': 'Please enter your password',
    'login_password_short': 'Password must be at least 6 characters',
    'login_failed': 'Login failed',
    'login_success': 'Logged in successfully!',

    // Reset Password Dialog
    'reset_password_title': 'Reset Password',
    'reset_password_description':
        'Enter your email address to receive a password reset link.',
    'reset_password_email_label': 'Email',
    'reset_password_cancel': 'Cancel',
    'reset_password_send': 'Send',
    'reset_password_email_sent': 'Password reset email sent!',
    'reset_password_email_failed': 'Failed to send reset email',
    'reset_password_email_required': 'Please enter your email',
    'reset_password_email_invalid': 'Please enter a valid email',

    // Signup Screen
    'signup_title': 'Create Account',
    'signup_subtitle': 'Sign up to get started!',
    'signup_name_hint': 'Enter Name',
    'signup_email_hint': 'Enter Email',
    'signup_password_hint': 'Enter password',
    'signup_create_button': 'Create Account',
    'signup_success':
        'Account created successfully! Please check your email for verification.',
    'signup_failed': 'Signup failed',
    'signup_already_have_account': 'Already have an account?',
    'signup_login': 'Log in',
    'signup_name_required': 'Please enter your name',
    'signup_email_required': 'Please enter your email',
    'signup_email_invalid': 'Please enter a valid email',
    'signup_password_required': 'Please enter your password',
    'signup_password_short': 'Password must be at least 6 characters',

    // Home Screen
    'home_quick_actions': 'Quick Actions',
    'home_scan_product': 'Scan Product',
    'home_recipe_suggestions': 'Recipe Suggestions',
    'home_recent_activity': 'Recent Activity',
    'home_expiring_soon': 'Expiring\nSoon',
    'home_total_items': 'Total Items',
    'home_error_loading_data': 'Error loading data',
    'home_retry': 'Retry',
    'home_no_family_connected': 'No Family Connected',
    'home_family_subtitle': 'Create or join a family to share your pantry',
    'home_get_started': 'Get Started',
    'home_error_loading_members': 'Error loading members',
    'home_no_family_members': 'No family members found',
    'home_family_members_count': '%s Family Members',
    'home_sharing_pantry': 'Sharing pantry together',
    'home_active': 'Active',

    // Common
    'view_all': 'View All',

    // Recent Activity
    'recent_view_all': 'View All',
    'recent_no_activity_yet': 'No Activity Yet',
    'recent_no_activity': 'No recent activity',
    'recent_failed_load': 'Failed to load activity',
    'today': 'Today',
    'yesterday': 'Yesterday',

    // Activity Titles/Subtitles
    'act_item_added_title': '%s added to pantry',
    'act_item_added_sub': 'New item in your inventory',
    'act_item_deleted_title': '%s removed from pantry',
    'act_item_deleted_sub': 'Item deleted from inventory',
    'act_item_updated_title': '%s updated',
    'act_item_updated_sub': 'Item details modified',
    'act_recipe_viewed_title': 'Viewed %s',
    'act_recipe_viewed_sub': 'Recipe details opened',
    'act_recipe_favorited_title': 'Favorited %s',
    'act_recipe_favorited_sub': 'Recipe added to favorites',
    'act_scan_performed_title': 'Product scanned',
    'act_scan_performed_sub': '',
    'act_inventory_cleared_title': 'Inventory cleared (%s)',
    'act_inventory_cleared_sub': '',

    // Inventory Screen additional strings
    'inventory_title': 'Inventory',
    'inventory_search_hint': 'Search products...',
    'inventory_no_items': 'No items in inventory',
    'inventory_start_scanning': 'Start by scanning your first product',
    'inventory_no_items_found': 'No items found',
    'inventory_adjust_search_filters': 'Try adjusting your search or filters',
    'inventory_clear_all': 'Clear all',
    'inventory_expiring': 'Expiring',
    'inventory_today': 'Today',
    'inventory_total': 'Total',
    'inventory_filter_by_category': 'Filter by Category',
    'inventory_no_categories': 'No categories available',
    'inventory_reset': 'Reset',
    'inventory_apply': 'Apply',
    'inventory_sort_by': 'Sort by',
    'inventory_sort_expiration': 'Expiration Date',
    'inventory_sort_name': 'Name',
    'inventory_sort_category': 'Category',
    'inventory_error_loading': 'Error loading inventory',
    'inventory_retry': 'Retry',
    'inventory_tab_all': 'All Items',
    'inventory_tab_expiring_soon': 'Expiring Soon',
    'inventory_tab_expires_today': 'Expires Today',
    'inventory_tab_expired': 'Expired',
    'inventory_delete_item': 'Delete Item',
    'inventory_delete_confirm':
        'Are you sure you want to delete "%s"? This action cannot be undone.',
    'inventory_delete': 'Delete',
    'inventory_delete_success': '%s deleted successfully',
    'inventory_delete_error': 'Error deleting item: %s',
    'inventory_items_found': '%s %s found %s',
    'inventory_item': 'item',
    'inventory_items': 'items',
    'inventory_for_query': 'for "%s"',
    'inventory_in_categories': 'in %s categories',
    'inventory_in_filter': 'in %s',

    // Confirmation Screen
    'confirm_title': 'Confirm Product Details',
    'confirm_subtitle': 'Review and edit before adding to pantry',
    'confirm_success': 'Product detected!',
    'confirm_scan_details': 'Scan Details',
    'confirm_add_pantry': 'Add to Pantry',
    'confirm_edit': 'Edit',
    'confirm_help_title': 'Product Confirmation Help',
    'confirm_help_description':
        'Review the detected product information and make any necessary corrections before adding it to your pantry. Auto-detected fields are highlighted in green.',
    'confirm_got_it': 'Got it',
    'confirm_detected': 'Product Detected Successfully!',
    'confirm_manual_mode': 'Manual Entry Mode',
    'confirm_review_details': 'Review and confirm the details below',
    'confirm_enter_manually': 'Enter product details manually',
    'confirm_product_details_header': 'Product Details',
    'confirm_review_edit_info': 'Review and edit the information below',
    'confirm_ai_detected_fields': 'AI-detected fields',
    'confirm_barcode_detection': 'Barcode Detection',
    'confirm_barcode_matched': 'Product matched via database lookup',
    'confirm_barcode_none': 'No barcode detected or recognized',
    'confirm_text_recognition': 'Text Recognition',
    'confirm_expiry_found': 'Expiry date found: %s',
    'confirm_expiry_none': 'No expiry date detected on packaging',
    'confirm_name_identified': 'Identified: %s',
    'confirm_name_none': 'No product name identified',
    'confirm_missing_info':
        'Missing information? You can manually enter any details that weren\'t automatically detected.',
    'confirm_add_pantry_button': 'Add to Pantry',
    'confirm_scan_again': 'Scan Again',

    // Confirmation Additional Headers & Fields
    'confirm_detection_results': 'Detection Results',
    'field_product_name': 'Product Name',
    'field_expiry_date': 'Expiry Date',
    'field_category': 'Category',
    'field_quantity': 'Quantity',
    'field_unit': 'Unit',
    'field_storage': 'Storage',
    'field_notes_optional': 'Notes (Optional)',
    'confirm_item_added': '%s added to pantry!',

    // Edit Item Screen
    'edit_item_update_details': 'Update the item details below',
    'edit_item_save_changes': 'Save Changes',
    'edit_item_updated_success': 'Item updated successfully!',
    'edit_item_failed_update': 'Failed to update item',

    // Category labels
    'cat_bakery': 'Bakery',
    'cat_beverages': 'Beverages',
    'cat_dairy': 'Dairy',
    'cat_frozen': 'Frozen',
    'cat_fruits': 'Fruits',
    'cat_meat': 'Meat',
    'cat_pantry': 'Pantry',
    'cat_snacks': 'Snacks',
    'cat_vegetables': 'Vegetables',
    'cat_other': 'Other',

    // Unit labels
    'unit_liters': 'Liters',
    'unit_ml': 'ml',
    'unit_kg': 'Kg',
    'unit_grams': 'Grams',
    'unit_pieces': 'Pieces',
    'unit_packs': 'Pack(s)',
    'unit_bottles': 'Bottle(s)',
    'unit_cans': 'Can(s)',
    'unit_lbs': 'lbs',
    'unit_oz': 'oz',

    // Storage labels
    'store_refrigerator': 'Refrigerator',
    'store_freezer': 'Freezer',
    'store_pantry': 'Pantry',
    'store_counter': 'Counter',

    // Scan Screen
    'scan_camera_failed_instruction':
        'Camera failed to start. This often happens after unlocking your phone. Use the restart button above to fix this.',
    'scan_expiry_instruction':
        'Expiry date not detected. Please focus on the expiry / "best before" date and scan again.',
    'scan_product_instruction':
        'Position the product label within the frame. The app will automatically detect barcodes and expiry dates using AI.',
    'scan_button_scan_expiry': 'Scan Expiry Date',
    'scan_button_scan_product': 'Scan Product',
    'scan_camera_failed_title': 'Camera initialization failed',
    'scan_camera_failed_subtitle': 'This can happen after unlocking your phone',
    'scan_restart_camera': 'Restart Camera',
    'scan_initializing_camera': 'Initializing camera...',
    'scan_scanning_product': 'Scanning product...',
    'scan_detecting_barcodes': 'Detecting barcodes and expiry dates',
    'scan_enter_manual': 'Enter product manually',
    'scan_no_cameras': 'No cameras available on this device',
    'scan_camera_failed_start':
        'Camera failed to start. Try the restart button.',
    'scan_expiry_not_detected':
        'Expiry date not detected. Please scan the expiry / "best before" section.',
    'scan_scanning_failed': 'Scanning failed',
    'scan_failed_scan_expiry_date': 'Failed to scan expiry date: %s',

    // Recipes Screen
    'recipes_search_hint': 'Search recipes...',
    'recipes_fallback_notice':
        'No expiring items found. Showing some easy recipe ideas to get you started!',
    'recipes_error': 'Error: %s',
    'recipes_no_results': 'No recipes found',
    'recipes_cook_time': 'Cook Time',
    'recipes_servings': 'Servings',
    'recipes_difficulty': 'Difficulty',
    'recipes_used': 'Used',
    'recipes_missing': 'Missing',
    'recipes_view_recipe': 'View Recipe',

    // Recipe Detail Screen
    'recipe_detail_description': 'Description',
    'recipe_detail_cook_time': 'Cook Time',
    'recipe_detail_difficulty': 'Difficulty',
    'recipe_detail_servings': 'Servings',
    'recipe_detail_ingredients': 'Ingredients',
    'recipe_detail_instructions': 'Instructions',
    'recipe_detail_no_instructions':
        'No instructions available for this recipe.',

    // Difficulty & Category Values
    'recipes_diff_easy': 'Easy',
    'recipes_diff_medium': 'Medium',
    'recipes_diff_hard': 'Hard',
    'recipe_cat_main_course': 'Main Course',
    'recipe_cat_side_dish': 'Side Dish',
    'recipe_cat_dessert': 'Dessert',
    'recipe_cat_appetizer': 'Appetizer',
    'recipe_cat_salad': 'Salad',
    'recipe_cat_breakfast': 'Breakfast',
    'recipe_cat_soup': 'Soup',
    'recipe_cat_beverage': 'Beverage',
    'recipe_cat_snack': 'Snack',
    'recipe_cat_general': 'General',
    'recipe_cat_lunch': 'Lunch',

    // Profile Screen
    'profile_title': 'Profile',
    'profile_recent_activity': 'Recent Activity',
    'profile_items_added': 'Items\nAdded',
    'profile_recipes_viewed': 'Recipes\nViewed',
    'profile_days_active': 'Days\nActive',
    'profile_quick_actions': 'Quick Actions',
    'profile_actions_available': '2 available',
    'profile_edit_profile': 'Edit Profile',
    'profile_edit_profile_subtitle':
        'Update your personal information and preferences',

    'profile_family': 'Family',
    'profile_family_subtitle': 'Manage family',
    'profile_account': 'Account',
    'profile_sign_out': 'Sign Out',
    'profile_sign_out_subtitle': 'Sign out of your account',
    'profile_sign_out_confirm_title': 'Sign Out',
    'profile_sign_out_confirm_message':
        'Are you sure you want to sign out of your account? You\'ll need to sign in again to access your data.',
    'profile_cancel': 'Cancel',

    // Edit Profile Screen
    'edit_profile_title': 'Edit Profile',
    'edit_profile_subtitle': 'Update your personal information',
    'edit_profile_personal_info': 'Personal Information',
    'edit_profile_full_name': 'Full Name',
    'edit_profile_name_required': 'Please enter your full name',
    'edit_profile_contact_info': 'Contact Information',
    'edit_profile_email_address': 'Email Address',
    'edit_profile_email_required': 'Please enter your email address',
    'edit_profile_email_invalid': 'Please enter a valid email address',
    'edit_profile_about': 'About',
    'edit_profile_bio_optional': 'Bio (Optional)',
    'edit_profile_bio_hint':
        'Tell us a bit about yourself and your food waste reduction goals...',
    'edit_profile_save_changes': 'Save',
    'edit_profile_cancel': 'Cancel',
    'edit_profile_updated_success': 'Profile updated successfully!',
    'edit_profile_update_error': 'Error updating profile: ',

    // Family Members Screen
    'family_members_title': 'Family Members',
    'family_members_subtitle': 'Manage your family and view invitations',
    'family_members_no_family': 'No Family Yet',
    'family_members_no_family_desc':
        'Create a family to share and manage your pantry with others.',
    'family_members_create_family': 'Create Family',
    'family_members_enter_code': 'Enter Invitation Code',
    'family_members_create_dialog_title': 'Create Family',
    'family_members_create_dialog_desc':
        'Enter a name for your new family to begin sharing your pantry.',
    'family_members_family_name': 'Family Name',
    'family_members_name_required': 'Please enter a family name',
    'family_members_name_short': 'Family name must be at least 3 characters',
    'family_members_cancel': 'Cancel',
    'family_members_create': 'Create',
    'family_members_created_success': 'Family created successfully!',
    'family_members_create_failed': 'Failed to create family: ',
    'family_members_join_dialog_title': 'Enter Invitation Code',
    'family_members_join_dialog_desc':
        'Paste the invitation code sent to your email to join the family.',
    'family_members_invitation_code': 'Invitation Code',
    'family_members_code_required': 'Please enter the code',
    'family_members_join': 'Join',
    'family_members_joined_success': 'Successfully joined family!',
    'family_members_join_failed': 'Failed to join family: ',
    'family_members_recent_activity': 'Recent Family Activity',
    'family_members_members': 'Members',
    'family_members_items_added': 'Items\nAdded',
    'family_members_family_members': 'Family Members',
    'family_members_new_family': 'New Family',
    'family_members_invite_member': 'Invite Member',
    'family_members_invite_dialog_title': 'Invite Family Member',
    'family_members_invite_dialog_desc':
        'Enter the email address of the person you\'d like to invite to your family.',
    'family_members_email_address': 'Enter email address',
    'family_members_email_required': 'Please enter an email address',
    'family_members_email_invalid': 'Please enter a valid email address',
    'family_members_send_invite': 'Send Invite',
    'family_members_invite_sent': 'Invitation sent successfully!',
    'family_members_invite_failed': 'Failed to send invitation: ',
    'family_members_remove_dialog_title': 'Remove Family Member',
    'family_members_remove_dialog_desc':
        'Are you sure you want to remove %s from this family? They will lose access to the shared pantry and all family data.',
    'family_members_remove': 'Remove',
    'family_members_removed_success': '%s has been removed from the family.',
    'family_members_remove_failed': 'Failed to remove member: ',
    'family_members_choose_family': 'Choose a Family',
    'family_members_switch_desc': 'Switch between the families you belong to.',
    'family_members_more_members': '+%s more members',
    'family_members_loading': 'Loading...',
    'family_members_loading_details': 'Loading family details...',
    'family_members_managing_pantry': 'Managing pantry together since %s',
    'family_members_error_loading': 'Error: %s',
    'family_members_no_members_found': 'No family members found.',
    'family_members_joined': 'Joined %s',
    'family_members_you': 'You',
    'family_members_pending': 'Pending',
    'family_members_sent': 'Sent %s',
    'family_members_just_now': 'Just now',
    'family_members_day_ago': '%s day ago',
    'family_members_days_ago': '%s days ago',
    'family_members_hour_ago': '%s hour ago',
    'family_members_hours_ago': '%s hours ago',
    'family_members_minute_ago': '%s minute ago',
    'family_members_minutes_ago': '%s minutes ago',

    // Family Switcher
    'family_switcher_choose_family': 'Elegir una familia',
    'family_switcher_switch_desc':
        'Cambia entre las familias a las que perteneces.',
  };

  // ---------- Spanish strings ---------- //
  static const Map<String, String> _esES = {
    // General
    'app_name': 'Comer Pronto',
    'language': 'Idioma',
    'change_language': 'Cambiar idioma de la aplicación',
    'english': 'Inglés',
    'spanish': 'Español',

    // Auth
    'login_title': 'Iniciar sesión',
    // 'signup_title': 'Registrarse', // removed duplicate
    'email': 'Correo electrónico',
    'password': 'Contraseña',
    'confirm_password': 'Confirmar contraseña',
    'logout': 'Cerrar sesión',

    // Inventory
    'inventory': 'Inventario',
    'add_item': 'Añadir artículo',
    'edit_item': 'Editar artículo',
    'inventory_edit_item': 'Editar artículo',

    // Family
    'family_members': 'Miembros de la familia',
    'create_family': 'Crear familia',
    'invite_member': 'Invitar miembro',

    // Misc
    'settings': 'Configuración',

    // Login Screen
    'login_welcome_title': 'Bienvenido a Eatsooon!',
    'login_welcome_subtitle': 'Hola! Inicia sesión para continuar.',
    'login_email_hint': 'Ingresa correo',
    'login_password_hint': 'Ingresa contraseña',
    'login_forget_password': '¿Olvidaste tu contraseña?',
    'login_continue': 'Continuar',
    'login_continue_google': 'Continuar con Google',
    'login_no_account': 'No tienes una cuenta?',
    'login_signup': 'Regístrate',
    'login_email_required': 'Por favor ingresa tu correo',
    'login_email_invalid': 'Ingrese un correo válido',
    'login_password_required': 'Ingresa tu contraseña',
    'login_password_short': 'La contraseña debe tener al menos 6 caracteres',
    'login_failed': 'Error de inicio de sesión',
    'login_success': '¡Inicio de sesión exitoso!',

    // Reset Password Dialog
    'reset_password_title': 'Restablecer contraseña',
    'reset_password_description':
        'Ingresa tu correo para recibir un enlace de restablecimiento.',
    'reset_password_email_label': 'Correo',
    'reset_password_cancel': 'Cancelar',
    'reset_password_send': 'Enviar',
    'reset_password_email_sent': 'Correo de restablecimiento enviado!',
    'reset_password_email_failed':
        'No se pudo enviar el correo de restablecimiento',
    'reset_password_email_required': 'Por favor ingresa tu correo',
    'reset_password_email_invalid': 'Por favor ingresa un correo válido',

    // Signup Screen
    'signup_title': 'Crear cuenta',
    'signup_subtitle': 'Regístrate para comenzar!',
    'signup_name_hint': 'Ingresa nombre',
    'signup_email_hint': 'Ingresa correo',
    'signup_password_hint': 'Ingresa contraseña',
    'signup_create_button': 'Crear cuenta',
    'signup_success':
        'Cuenta creada con éxito! Por favor revisa tu correo para verificar.',
    'signup_failed': 'Error de registro',
    'signup_already_have_account': 'Ya tienes una cuenta?',
    'signup_login': 'Iniciar sesión',
    'signup_name_required': 'Por favor ingresa tu nombre',
    'signup_email_required': 'Por favor ingresa tu correo',
    'signup_email_invalid': 'Ingrese un correo válido',
    'signup_password_required': 'Ingresa tu contraseña',
    'signup_password_short': 'La contraseña debe tener al menos 6 caracteres',

    // Home Screen
    'home_quick_actions': 'Acciones rápidas',
    'home_scan_product': 'Escanear producto',
    'home_recipe_suggestions': 'Sugerencias de recetas',
    'home_recent_activity': 'Actividad reciente',
    'home_expiring_soon': 'Próximo a\nVencer',
    'home_total_items': 'Artículos totales',
    'home_error_loading_data': 'Error al cargar datos',
    'home_retry': 'Reintentar',
    'home_no_family_connected': 'Sin familia conectada',
    'home_family_subtitle':
        'Crea o únete a una familia para compartir tu despensa',
    'home_get_started': 'Comenzar',
    'home_error_loading_members': 'Error al cargar miembros',
    'home_no_family_members': 'No se encontraron miembros de la familia',
    'home_family_members_count': '%s miembros de la familia',
    'home_sharing_pantry': 'Compartiendo despensa',
    'home_active': 'Activo',

    // Common
    'view_all': 'Ver todo',

    // Recent Activity
    'recent_view_all': 'Ver todo',
    'recent_no_activity_yet': 'Sin actividad',
    'recent_no_activity': 'Sin actividad reciente',
    'recent_failed_load': 'Error al cargar actividad',
    'today': 'Hoy',
    'yesterday': 'Ayer',

    // Activity Titles/Subtitles
    'act_item_added_title': '%s añadido a la despensa',
    'act_item_added_sub': 'Nuevo artículo en tu inventario',
    'act_item_deleted_title': '%s eliminado de la despensa',
    'act_item_deleted_sub': 'Artículo eliminado del inventario',
    'act_item_updated_title': '%s actualizado',
    'act_item_updated_sub': 'Detalles del artículo modificados',
    'act_recipe_viewed_title': 'Receta vista %s',
    'act_recipe_viewed_sub': 'Detalles de la receta abiertos',
    'act_recipe_favorited_title': 'Receta favorita %s',
    'act_recipe_favorited_sub': 'Receta añadida a favoritos',
    'act_scan_performed_title': 'Producto escaneado',
    'act_scan_performed_sub': '',
    'act_inventory_cleared_title': 'Inventario limpiado (%s)',
    'act_inventory_cleared_sub': '',

    // Inventory Screen additional strings
    'inventory_title': 'Inventario',
    'inventory_search_hint': 'Buscar productos...',
    'inventory_no_items': 'Sin artículos en el inventario',
    'inventory_start_scanning': 'Comienza escaneando tu primer producto',
    'inventory_no_items_found': 'No se encontraron artículos',
    'inventory_adjust_search_filters': 'Intenta ajustar tu búsqueda o filtros',
    'inventory_clear_all': 'Limpiar todo',
    'inventory_expiring': 'Por vencer',
    'inventory_today': 'Hoy',
    'inventory_total': 'Total',
    'inventory_filter_by_category': 'Filtrar por categoría',
    'inventory_no_categories': 'No hay categorías disponibles',
    'inventory_reset': 'Restablecer',
    'inventory_apply': 'Aplicar',
    'inventory_sort_by': 'Ordenar por',
    'inventory_sort_expiration': 'Fecha de vencimiento',
    'inventory_sort_name': 'Nombre',
    'inventory_sort_category': 'Categoría',
    'inventory_error_loading': 'Error al cargar inventario',
    'inventory_retry': 'Reintentar',
    'inventory_tab_all': 'Todos los artículos',
    'inventory_tab_expiring_soon': 'Pronto a vencer',
    'inventory_tab_expires_today': 'Vence hoy',
    'inventory_tab_expired': 'Vencido',
    'inventory_delete_item': 'Eliminar artículo',
    'inventory_delete_confirm':
        '¿Estás seguro de que deseas eliminar "%s"? Esta acción no se puede deshacer.',
    'inventory_delete': 'Eliminar',
    'inventory_delete_success': '%s eliminado correctamente',
    'inventory_delete_error': 'Error al eliminar artículo: %s',
    'inventory_items_found': '%s %s encontrados %s',
    'inventory_item': 'artículo',
    'inventory_items': 'artículos',
    'inventory_for_query': 'para "%s"',
    'inventory_in_categories': 'en %s categorías',
    'inventory_in_filter': 'en %s',

    // Confirmation Screen
    'confirm_title': 'Confirmar detalles del producto',
    'confirm_subtitle': 'Revisa y edita antes de añadir a la despensa',
    'confirm_success': '¡Producto detectado!',
    'confirm_scan_details': 'Detalles del escaneo',
    'confirm_add_pantry': 'Agregar a la despensa',
    'confirm_edit': 'Editar',
    'confirm_help_title': 'Ayuda de confirmación de producto',
    'confirm_help_description':
        'Revisa la información detectada y corrige lo necesario antes de añadirla a la despensa. Los campos detectados automáticamente se resaltan en verde.',
    'confirm_got_it': 'Entendido',
    'confirm_detected': '¡Producto detectado con éxito!',
    'confirm_manual_mode': 'Modo de entrada manual',
    'confirm_review_details': 'Revisa y confirma los detalles abajo',
    'confirm_enter_manually': 'Ingresa los detalles manualmente',
    'confirm_product_details_header': 'Detalles del producto',
    'confirm_review_edit_info': 'Revisa y edita la información abajo',
    'confirm_ai_detected_fields': 'Campos detectados por IA',
    'confirm_barcode_detection': 'Detección de código de barras',
    'confirm_barcode_matched': 'Producto encontrado en la base de datos',
    'confirm_barcode_none': 'No se detectó o reconoció código de barras',
    'confirm_text_recognition': 'Reconocimiento de texto',
    'confirm_expiry_found': 'Fecha de vencimiento encontrada: %s',
    'confirm_expiry_none': 'No se detectó fecha de vencimiento en el envase',
    'confirm_name_identified': 'Identificado: %s',
    'confirm_name_none': 'No se identificó nombre de producto',
    'confirm_missing_info':
        '¿Falta información? Puedes ingresar manualmente los detalles que no se detectaron automáticamente.',
    'confirm_add_pantry_button': 'Agregar a la despensa',
    'confirm_scan_again': 'Escanear de nuevo',

    // Confirmation Additional Headers & Fields
    'confirm_detection_results': 'Resultados de detección',
    'field_product_name': 'Nombre del producto',
    'field_expiry_date': 'Fecha de vencimiento',
    'field_category': 'Categoría',
    'field_quantity': 'Cantidad',
    'field_unit': 'Unidad',
    'field_storage': 'Almacenamiento',
    'field_notes_optional': 'Notas (opcional)',
    'confirm_item_added': '%s agregado a la despensa!',

    // Edit Item Screen
    'edit_item_update_details': 'Actualiza los detalles del artículo',
    'edit_item_save_changes': 'Guardar cambios',
    'edit_item_updated_success': '¡Artículo actualizado con éxito!',
    'edit_item_failed_update': 'No se pudo actualizar el artículo',

    // Category labels
    'cat_bakery': 'Panadería',
    'cat_beverages': 'Bebidas',
    'cat_dairy': 'Lácteos',
    'cat_frozen': 'Congelados',
    'cat_fruits': 'Frutas',
    'cat_meat': 'Carne',
    'cat_pantry': 'Despensa',
    'cat_snacks': 'Aperitivos',
    'cat_vegetables': 'Verduras',
    'cat_other': 'Otro',

    // Unit labels
    'unit_liters': 'Litros',
    'unit_ml': 'ml',
    'unit_kg': 'Kg',
    'unit_grams': 'Gramos',
    'unit_pieces': 'Piezas',
    'unit_packs': 'Paquete(s)',
    'unit_bottles': 'Botella(s)',
    'unit_cans': 'Lata(s)',
    'unit_lbs': 'lbs',
    'unit_oz': 'oz',

    // Storage labels
    'store_refrigerator': 'Refrigerador',
    'store_freezer': 'Congelador',
    'store_pantry': 'Despensa',
    'store_counter': 'Encimera',

    // Scan Screen
    'scan_camera_failed_instruction':
        'La cámara no se pudo iniciar. Esto a menudo sucede después de desbloquear tu teléfono. Usa el botón de reinicio arriba para solucionarlo.',
    'scan_expiry_instruction':
        'Fecha de caducidad no detectada. Enfoca la fecha de caducidad o "consumir antes de" y escanea de nuevo.',
    'scan_product_instruction':
        'Coloca la etiqueta del producto dentro del marco. La aplicación detectará automáticamente códigos de barras y fechas de caducidad usando IA.',
    'scan_button_scan_expiry': 'Escanear fecha de caducidad',
    'scan_button_scan_product': 'Escanear producto',
    'scan_camera_failed_title': 'Fallo de inicialización de la cámara',
    'scan_camera_failed_subtitle':
        'Esto puede suceder después de desbloquear el teléfono',
    'scan_restart_camera': 'Reiniciar cámara',
    'scan_initializing_camera': 'Inicializando la cámara...',
    'scan_scanning_product': 'Escaneando producto...',
    'scan_detecting_barcodes':
        'Detectando códigos de barras y fechas de caducidad',
    'scan_enter_manual': 'Ingresar producto manualmente',
    'scan_no_cameras': 'No hay cámaras disponibles en este dispositivo',
    'scan_camera_failed_start':
        'La cámara falló al iniciar. Intenta el botón de reinicio.',
    'scan_expiry_not_detected':
        'Fecha de caducidad no detectada. Escanea la sección de fecha de caducidad o "consumir antes de".',
    'scan_scanning_failed': 'Error de escaneo',
    'scan_failed_scan_expiry_date':
        'Error al escanear la fecha de caducidad: %s',

    // Recipes Screen
    'recipes_search_hint': 'Buscar recetas...',
    'recipes_fallback_notice':
        'No se encontraron artículos próximos a vencer. Mostrando algunas recetas fáciles para empezar!',
    'recipes_error': 'Error: %s',
    'recipes_no_results': 'No se encontraron recetas',
    'recipes_cook_time': 'Tiempo de cocina',
    'recipes_servings': 'Porciones',
    'recipes_difficulty': 'Dificultad',
    'recipes_used': 'Usado',
    'recipes_missing': 'Faltante',
    'recipes_view_recipe': 'Ver receta',

    // Recipe Detail Screen
    'recipe_detail_description': 'Descripción',
    'recipe_detail_cook_time': 'Tiempo de cocina',
    'recipe_detail_difficulty': 'Dificultad',
    'recipe_detail_servings': 'Porciones',
    'recipe_detail_ingredients': 'Ingredientes',
    'recipe_detail_instructions': 'Instrucciones',
    'recipe_detail_no_instructions':
        'No hay instrucciones disponibles para esta receta.',

    // Difficulty & Category Values
    'recipes_diff_easy': 'Fácil',
    'recipes_diff_medium': 'Media',
    'recipes_diff_hard': 'Difícil',
    'recipe_cat_main_course': 'Plato principal',
    'recipe_cat_side_dish': 'Acompañamiento',
    'recipe_cat_dessert': 'Postre',
    'recipe_cat_appetizer': 'Aperitivo',
    'recipe_cat_salad': 'Ensalada',
    'recipe_cat_breakfast': 'Desayuno',
    'recipe_cat_soup': 'Sopa',
    'recipe_cat_beverage': 'Bebida',
    'recipe_cat_snack': 'Tentempié',
    'recipe_cat_general': 'General',
    'recipe_cat_lunch': 'Almuerzo',

    // Profile Screen
    'profile_title': 'Perfil',
    'profile_recent_activity': 'Actividad reciente',
    'profile_items_added': 'Artículos\nAñadidos',
    'profile_recipes_viewed': 'Recetas\nVistas',
    'profile_days_active': 'Días\nActivo',
    'profile_quick_actions': 'Acciones rápidas',
    'profile_actions_available': '2 disponibles',
    'profile_edit_profile': 'Editar perfil',
    'profile_edit_profile_subtitle':
        'Actualiza tu información personal y preferencias',

    'profile_family': 'Familia',
    'profile_family_subtitle': 'Gestionar familia',
    'profile_account': 'Cuenta',
    'profile_sign_out': 'Cerrar sesión',
    'profile_sign_out_subtitle': 'Cerrar sesión de tu cuenta',
    'profile_sign_out_confirm_title': 'Cerrar sesión',
    'profile_sign_out_confirm_message':
        '¿Estás seguro de que quieres cerrar sesión? Necesitarás iniciar sesión nuevamente para acceder a tus datos.',
    'profile_cancel': 'Cancelar',

    // Edit Profile Screen
    'edit_profile_title': 'Editar perfil',
    'edit_profile_subtitle': 'Actualiza tu información personal',
    'edit_profile_personal_info': 'Información personal',
    'edit_profile_full_name': 'Nombre completo',
    'edit_profile_name_required': 'Por favor ingresa tu nombre completo',
    'edit_profile_contact_info': 'Información de contacto',
    'edit_profile_email_address': 'Dirección de correo',
    'edit_profile_email_required': 'Por favor ingresa tu dirección de correo',
    'edit_profile_email_invalid':
        'Por favor ingresa una dirección de correo válida',
    'edit_profile_about': 'Acerca de',
    'edit_profile_bio_optional': 'Biografía (Opcional)',
    'edit_profile_bio_hint':
        'Cuéntanos un poco sobre ti y tus objetivos de reducción de desperdicio de alimentos...',
    'edit_profile_save_changes': 'Guardar',
    'edit_profile_cancel': 'Cancelar',
    'edit_profile_updated_success': '¡Perfil actualizado con éxito!',
    'edit_profile_update_error': 'Error al actualizar perfil: ',

    // Family Members Screen
    'family_members_title': 'Miembros de la familia',
    'family_members_subtitle': 'Gestiona tu familia y ve invitaciones',
    'family_members_no_family': 'Sin familia aún',
    'family_members_no_family_desc':
        'Crea una familia para compartir y gestionar tu despensa con otros.',
    'family_members_create_family': 'Crear familia',
    'family_members_enter_code': 'Ingresar código de invitación',
    'family_members_create_dialog_title': 'Crear familia',
    'family_members_create_dialog_desc':
        'Ingresa un nombre para tu nueva familia para comenzar a compartir tu despensa.',
    'family_members_family_name': 'Nombre de la familia',
    'family_members_name_required': 'Por favor ingresa un nombre de familia',
    'family_members_name_short':
        'El nombre de la familia debe tener al menos 3 caracteres',
    'family_members_cancel': 'Cancelar',
    'family_members_create': 'Crear',
    'family_members_created_success': '¡Familia creada con éxito!',
    'family_members_create_failed': 'Error al crear familia: ',
    'family_members_join_dialog_title': 'Ingresar código de invitación',
    'family_members_join_dialog_desc':
        'Pega el código de invitación enviado a tu correo para unirte a la familia.',
    'family_members_invitation_code': 'Código de invitación',
    'family_members_code_required': 'Por favor ingresa el código',
    'family_members_join': 'Unirse',
    'family_members_joined_success': '¡Te has unido exitosamente a la familia!',
    'family_members_join_failed': 'Error al unirse a la familia: ',
    'family_members_recent_activity': 'Actividad familiar reciente',
    'family_members_members': 'Miembros',
    'family_members_items_added': 'Artículos\nAñadidos',
    'family_members_family_members': 'Miembros de la familia',
    'family_members_new_family': 'Nueva familia',
    'family_members_invite_member': 'Invitar miembro',
    'family_members_invite_dialog_title': 'Invitar miembro de familia',
    'family_members_invite_dialog_desc':
        'Ingresa la dirección de correo de la persona que quieres invitar a tu familia.',
    'family_members_email_address': 'Ingresa dirección de correo',
    'family_members_email_required':
        'Por favor ingresa una dirección de correo',
    'family_members_email_invalid':
        'Por favor ingresa una dirección de correo válida',
    'family_members_send_invite': 'Enviar invitación',
    'family_members_invite_sent': '¡Invitación enviada con éxito!',
    'family_members_invite_failed': 'Error al enviar invitación: ',
    'family_members_remove_dialog_title': 'Eliminar miembro de familia',
    'family_members_remove_dialog_desc':
        '¿Estás seguro de que quieres eliminar a %s de esta familia? Perderá acceso a la despensa compartida y todos los datos familiares.',
    'family_members_remove': 'Eliminar',
    'family_members_removed_success': '%s ha sido eliminado de la familia.',
    'family_members_remove_failed': 'Error al eliminar miembro: ',
    'family_members_choose_family': 'Elegir una familia',
    'family_members_switch_desc':
        'Cambia entre las familias a las que perteneces.',
    'family_members_more_members': '+%s miembros más',
    'family_members_loading': 'Cargando...',
    'family_members_loading_details': 'Cargando detalles de la familia...',
    'family_members_managing_pantry': 'Gestionando la despensa juntos desde %s',
    'family_members_error_loading': 'Error: %s',
    'family_members_no_members_found': 'No se encontraron miembros de familia.',
    'family_members_joined': 'Se unió %s',
    'family_members_you': 'Tú',
    'family_members_pending': 'Pendiente',
    'family_members_sent': 'Enviado %s',
    'family_members_just_now': 'Ahora mismo',
    'family_members_day_ago': 'hace %s día',
    'family_members_days_ago': 'hace %s días',
    'family_members_hour_ago': 'hace %s hora',
    'family_members_hours_ago': 'hace %s horas',
    'family_members_minute_ago': 'hace %s minuto',
    'family_members_minutes_ago': 'hace %s minutos',

    // Family Switcher
    'family_switcher_choose_family': 'Elegir una familia',
    'family_switcher_switch_desc':
        'Cambia entre las familias a las que perteneces.',
  };
}
