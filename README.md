# Eat Soon 🥗

A mobile app designed to help reduce food waste by scanning products and tracking their expiration dates. Built with Flutter, Firebase, and Google ML Kit.

## 📱 Overview

Eat Soon helps users manage their food inventory by automatically detecting product information and expiration dates through advanced scanning technology. The app provides timely notifications to prevent food waste and suggests recipes based on items nearing expiration.

## ✨ Key Features

### 🔍 Smart Scanning
- **Dual Detection System**: Combines OCR for expiration date recognition and barcode scanning for product identification
- **Camera Integration**: Real-time camera preview with scanning overlay
- **Manual Entry**: Fallback option for products that can't be automatically detected
- **Learning System**: Saves manually entered products to improve future suggestions

### 📦 Inventory Management
- **Smart Organization**: Automatically sorts items by expiration date
- **Advanced Filtering**: Filter by "Expiring Soon", "Today", or "Expired"
- **Easy Management**: Edit, delete, and batch operations on inventory items
- **Category System**: Organize products by categories for better management

### 🔔 Smart Notifications
- **Proactive Alerts**: Get notified about products expiring today or in 2 days
- **Customizable Settings**: Configure notification preferences and quiet hours
- **Weekly Summaries**: Receive inventory overview notifications

### 🍳 Recipe Suggestions
- **Waste Prevention**: Get recipe suggestions based on items nearing expiration
- **External API Integration**: Powered by Spoonacular/Edamam APIs
- **Dietary Preferences**: Filter recipes based on your dietary needs

### 🔐 Secure Authentication
- **Firebase Auth**: Secure email/password authentication
- **Profile Management**: Manage your account and preferences
- **Data Sync**: Your inventory syncs across all your devices

## 🛠 Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Provider + GetX**: State management
- **Material Design 3**: Modern UI components

### Backend & Services
- **Firebase Firestore**: Real-time database
- **Firebase Auth**: User authentication
- **Firebase Storage**: Image storage
- **Firebase Cloud Messaging**: Push notifications
- **Firebase Analytics**: Usage analytics

### AI & Recognition
- **Google ML Kit**: Text recognition (OCR)
- **ML Kit Barcode Scanning**: Product identification
- **OpenFoodFacts API**: Product database lookup

### External APIs
- **Spoonacular/Edamam**: Recipe suggestions
- **Custom Learning System**: Product recognition improvement

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase account
- Physical device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/eat_soon.git
   cd eat_soon
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication, Firestore, Storage, and Cloud Messaging
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Configure API Keys**
   - Get API keys for OpenFoodFacts and recipe services
   - Add them to your environment configuration

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/           # App theming and design system
│   ├── utils/           # Utility functions and constants
│   └── router/          # Navigation and routing
├── features/
│   ├── auth/            # Authentication screens and logic
│   ├── home/            # Home screen and dashboard
│   ├── scanner/         # Product scanning functionality
│   ├── inventory/       # Inventory management
│   ├── notifications/   # Notification handling
│   ├── recipes/         # Recipe suggestions
│   └── shell/           # App shell and navigation
└── main.dart           # App entry point
```

## 🎯 Current Implementation Status

### ✅ Completed Features
- **Project Setup**: Flutter project with Firebase integration
- **Authentication System**: Login, signup, and profile management
- **App Shell**: Bottom navigation with custom design
- **Home Screen**: Dashboard with quick actions and recent activity
- **Scanner Interface**: Camera integration with scanning UI
- **Confirmation Screen**: Product details form with validation
- **Navigation System**: Seamless navigation between screens

### 🚧 In Progress
- **OCR Implementation**: Google ML Kit text recognition integration
- **Barcode Scanning**: ML Kit barcode detection
- **Inventory Management**: CRUD operations for products
- **Database Integration**: Firestore data models and services

### 📋 Upcoming Features
- **Push Notifications**: FCM integration with Cloud Functions
- **Recipe Suggestions**: External API integration
- **Advanced Filtering**: Enhanced inventory management
- **Analytics**: Usage tracking and insights

## 🎨 Design System

The app follows a consistent design system with:
- **Primary Colors**: Green (#10B981) for success, Orange (#F97316) for warnings
- **Typography**: Nunito for headers, Inter for body text
- **Spacing**: Consistent 20px horizontal padding throughout
- **Components**: Custom-designed, minimalist UI elements

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Supported Platforms

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenFoodFacts**: For providing comprehensive product database
- **Google ML Kit**: For powerful on-device machine learning capabilities
- **Firebase**: For robust backend infrastructure
- **Flutter Team**: For the amazing cross-platform framework

## 📞 Support

For support, email support@eatsoon.app or join our community Discord server.

## 🗺 Roadmap

### Phase 1 (Current) - Foundation
- ✅ Basic app structure and authentication
- ✅ Scanner interface and confirmation screen
- 🚧 Core scanning functionality

### Phase 2 - Core Features
- 📋 Complete inventory management
- 📋 Push notifications system
- 📋 Basic recipe suggestions

### Phase 3 - Advanced Features
- 📋 Advanced analytics and insights
- 📋 Social features and sharing
- 📋 Offline functionality

### Phase 4 - Enhancement
- 📋 AI-powered suggestions
- 📋 Community features
- 📋 Advanced integrations

---

**Made with ❤️ to reduce food waste and create a more sustainable future.**
