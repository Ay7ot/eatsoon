# Localization Implementation Plan

This document outlines how we will add **Spanish (es-ES)** (and future languages) to the Eat Soon Flutter app using GetXʼs built-in localisation system.

---
## 1️⃣ Technical Stack
- **GetX Translations** → no new dependencies, hot-reload friendly.
- **Key notation** → snake_case such as `login_title`, `inventory`, etc.
- **Locale codes** → `en_US` (default), `es_ES`.

---
## 2️⃣ High-Level Steps
| # | Task |
|---|------|
|1|Create `lib/l10n/app_translations.dart` with `AppTranslations` class (see sample code below).|
|2|Update `GetMaterialApp` in `lib/main.dart` → set `translations`, `locale`, and `fallbackLocale`.|
|3|Replace every hard-coded string with the corresponding key + `.tr` / `.trArgs()` helper.|
|4|Add language switcher UI in settings (call `Get.updateLocale`).|
|5|QA pass on both English & Spanish, check RTL safety for future languages.|

---
## 3️⃣ Sample `AppTranslations` Skeleton
```dart
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'login_title': 'Login',
      // …
    },
    'es_ES': {
      'login_title': 'Iniciar sesión',
      // …
    },
  };
}
```

---
## 4️⃣ Screen File Checklist
Use the table below to track localisation progress. Mark **✅** when all visible strings inside the file have been converted to keys and added to `AppTranslations`.

| Screen file | Status |
|-------------|--------|
| lib/features/auth/presentation/screens/login_screen.dart | ✅ |
| lib/features/auth/presentation/screens/signup_screen.dart | ✅ |
| lib/features/family/presentation/screens/family_members_screen.dart | ✅ |
| lib/features/family/presentation/widgets/family_switcher.dart | ✅ |
| lib/features/home/presentation/screens/home_screen.dart | ✅ |
| lib/features/inventory/presentation/screens/edit_item_screen.dart | ✅ |
| lib/features/inventory/presentation/screens/inventory_screen.dart | ✅ |
| lib/features/profile/presentation/screens/edit_profile_screen.dart | ✅ |
| lib/features/profile/presentation/screens/profile_screen.dart | ✅ |
| lib/features/recipes/presentation/screens/recipe_detail_screen.dart | ✅ |
| lib/features/recipes/presentation/screens/recipes_screen.dart | ✅ |
| lib/features/scanner/presentation/screens/confirmation_screen.dart | ✅ |
| lib/features/scanner/presentation/screens/scan_screen.dart | ✅ |
| lib/features/splash/splash_screen.dart | ⬜ |

_Add more files here if discovered later (e.g., dialogs, widgets containing standalone screens)._

---
## 5️⃣ String Discovery Tips
1. Grep for single-quoted & double-quoted literals in each screen.
2. Don't forget SnackBars, Dialog titles, button labels, and validator messages.
3. Shared widgets (e.g., `RecentActivity`, custom textfields) will also need keys – track them in a separate widget table if large.

---
## 6️⃣ Acceptance Criteria
- Switching device/system locale or calling `Get.updateLocale(const Locale('es', 'ES'))` updates **all** strings.
- No missing key falls back to raw key string.
- Plural forms handled with `.plural()` or `.trArgs()`.
- Build & tests pass.

---
_Once all boxes are checked, Spanish localisation is complete. Further languages can reuse the same flow by adding new locale maps in `AppTranslations`._
