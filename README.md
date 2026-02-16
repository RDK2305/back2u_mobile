# 🎯 Back2U - Lost & Found Mobile App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-4.7.3-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active-success)

*A comprehensive Flutter application for reporting, tracking, and recovering lost and found items on campus*

[Features](#-features) • [Tech Stack](#-tech-stack) • [Installation](#-installation) • [Project Structure](#-project-structure) • [Team](#-team)

</div>

---

## 📱 Overview

**Back2U** is a modern, feature-rich Flutter mobile application designed to help students and community members report and find lost items on campus. With an intuitive interface, real-time item tracking, and smart search capabilities, Back2U makes it easy to reunite people with their belongings.

The app is built with cutting-edge Flutter technologies and provides a seamless experience across iOS, Android, Web, Linux, macOS, and Windows platforms.

---

## ✨ Features

### 🔐 **Authentication & Security**
- Email/Password-based user registration and login
- JWT token-based authentication
- Secure credential storage
- Session management with automatic token refresh
- Role-based user profiles (Student, Staff, Admin)

### 📝 **Lost Item Reporting**
- Comprehensive form for reporting lost items
- Real-time location capture with GPS integration
- Image attachment from camera or gallery
- Item categorization (Wallet, Phone, Keys, ID, Clothing, Bag, Textbooks, Electronics, Other)
- Detailed distinguishing features documentation
- Campus-specific item tracking
- Date and time tracking

### 🔍 **Found Item Browsing**
- Browse all reported found items
- Advanced filtering and search functionality
- Campus-specific filtering
- Category-based browsing
- Responsive list and grid views
- Item detail modal with full information

### 👤 **User Profile & Management**
- Comprehensive user profile with editable fields
- Personal item tracking (My Items)
- Profile picture support
- Program/Major information
- Campus assignment management
- Edit and update profile information

### ⚙️ **Settings & Preferences**
- Dark mode / Light mode theme toggle
- Push notification preferences
- Privacy policy and terms of service
- App information and version tracking
- Cache management
- Settings persistence across sessions

### 🎨 **Design & UI**
- Beautiful Material Design 3 interface
- Full dark/light theme support
- Smooth animations and transitions
- Responsive design for all screen sizes
- Custom form validation with error messages
- Loading states and progress indicators
- Toast notifications and snackbars

### 📱 **Cross-Platform Support**
- iOS native support
- Android native support
- Web application support
- Linux support
- macOS support
- Windows support

---

## 🛠️ Tech Stack

### **Frontend**
- **Framework**: Flutter 3.10+
- **State Management**: GetX 4.7.3
- **Networking**: Dio 5.3.0
- **Local Storage**: SharedPreferences 2.2.2
- **Image Handling**: Image Picker 1.0.4, Cached Network Image 3.3.0
- **Location Services**: Geolocator 10.0.0, Permission Handler 11.4.0
- **Typography**: Google Fonts 6.1.0
- **Design System**: Material Design 3

### **Backend**
- **API Base URL**: https://back2u-h67h.onrender.com
- **Authentication**: JWT Tokens
- **Database**: MySQL
- **Server**: Node.js/Express

### **Development Tools**
- **IDE**: VS Code / Android Studio
- **Version Control**: Git & GitHub
- **Build System**: Flutter CLI

---

## 📦 Installation

### **Prerequisites**
- Flutter SDK 3.10 or higher
- Dart 3.0 or higher
- Git
- Android SDK (for Android development)
- Xcode (for iOS development)
- Node.js (for backend - if running locally)

### **Step 1: Clone the Repository**
```bash
git clone https://github.com/RDK2305/back2u_mobile.git
cd back2u
```

### **Step 2: Install Dependencies**
```bash
flutter pub get
```

### **Step 3: Set Up Environment Variables**
Create a `.env` file in the project root (optional):
```env
API_BASE_URL=https://back2u-h67h.onrender.com
IMAGE_BASE_URL=https://back2u-h67h.onrender.com/uploads/
```

### **Step 4: Run the Application**

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web:**
```bash
flutter run -d web
```

**For Windows:**
```bash
flutter run -d windows
```

**For macOS:**
```bash
flutter run -d macos
```

**For Linux:**
```bash
flutter run -d linux
```

---

## 📁 Project Structure

```
back2u/
├── lib/
│   ├── main.dart                          # Application entry point
│   ├── config/
│   │   ├── app_config.dart               # App configuration
│   │   ├── theme.dart                    # Material Design 3 theme
│   │   ├── routes.dart                   # GetX routing configuration
│   │   └── constants.dart                # Global constants
│   ├── models/
│   │   ├── user.dart                     # User data model
│   │   └── item.dart                     # Lost/Found item model
│   ├── providers/
│   │   ├── auth_provider.dart            # Authentication state management
│   │   ├── item_provider.dart            # Item CRUD operations
│   │   └── theme_provider.dart           # Theme preference management
│   ├── services/
│   │   ├── api_service.dart              # HTTP client and API methods
│   │   ├── auth_service.dart             # Authentication logic
│   │   ├── database_service.dart         # Local database operations
│   │   └── storage_service.dart          # Shared preferences wrapper
│   ├── screens/
│   │   ├── splash_screen.dart            # App splash/loading screen
│   │   ├── home_screen.dart              # Home/dashboard screen
│   │   ├── auth/
│   │   │   ├── login_screen.dart         # User login
│   │   │   └── register_screen.dart      # User registration
│   │   ├── report_lost_item_screen.dart  # Report lost item form
│   │   ├── public_found_items_screen.dart # Browse found items
│   │   ├── my_items_screen.dart          # User's reported items
│   │   ├── profile_screen.dart           # User profile management
│   │   ├── settings_screen.dart          # App settings
│   │   ├── privacy_policy_screen.dart    # Privacy policy
│   │   └── terms_of_service_screen.dart  # Terms of service
│   ├── widgets/
│   │   └── safe_network_image.dart       # Cached network image widget
│   └── images/                            # App assets and icons
├── android/                              # Android platform files
├── ios/                                  # iOS platform files
├── web/                                  # Web platform files
├── linux/                                # Linux platform files
├── macos/                                # macOS platform files
├── windows/                              # Windows platform files
├── pubspec.yaml                          # Project dependencies
└── analysis_options.yaml                 # Dart linting rules
```

---

## 🚀 Key Features Implementation

### **Authentication Flow**
1. User registers with email and password
2. JWT token issued and securely stored
3. Token auto-refreshed on app startup
4. Protected API endpoints with token validation

### **Item Reporting Workflow**
1. User selects "Report Lost/Found Item"
2. Fills form with item details and images
3. Optionally captures GPS location
4. Submits to backend API
5. Item appears in public listings
6. User can track and update status

### **Real-time Updates**
- Items list updates when new items are reported
- User can filter by category, campus, or status
- Pull-to-refresh functionality
- Automatic image caching for faster loading

### **Theme Management**
- Toggle between dark and light modes
- Theme preference persisted across sessions
- All screens automatically adapt to theme
- Material Design 3 color system

---

## 🔄 State Management (GetX)

### **Providers Use Cases:**

**AuthProvider**
- User login/registration
- Token management
- User state persistence
- Logout functionality

**ItemProvider**
- CRUD operations for items
- Item filtering and search
- Local item list management
- Error handling and loading states

**ThemeProvider**
- Dark/light mode toggle
- Theme preference persistence
- Theme state observation

---

## 🎨 UI/UX Highlights

### **Modern Design System**
- Material Design 3 compliance
- Consistent color palette
- Custom typography with Google Fonts
- Smooth animations and transitions

### **Responsive Layout**
- Works on phones (mobile-first)
- Tablet optimized layouts
- Web responsive design
- Desktop support

### **Accessible Design**
- Text contrast compliance
- Touch target sizes (48x48dp minimum)
- Semantic HTML for web
- Clear form labels and hints

---

## 📡 API Integration

### **Base URL**
```
https://back2u-h67h.onrender.com
```

### **Key Endpoints**
- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `GET /items` - Fetch all items (with filters)
- `POST /items/lost` - Report lost item
- `POST /items/found` - Report found item
- `PUT /items/:id` - Update item
- `DELETE /items/:id` - Delete item
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile

---

## 🧪 Testing

### **Manual Testing Checklist**
- [ ] User registration flow
- [ ] User login flow
- [ ] Report lost item with image
- [ ] Report found item
- [ ] Browse items with filters
- [ ] View my items
- [ ] Update profile
- [ ] Toggle dark/light mode
- [ ] Read privacy policy
- [ ] Read terms of service

### **Test Accounts**
```
Email: test@back2u.com
Password: Test@1234

Email: student@back2u.com
Password: Student@1234
```

---

## 🤝 Team

### **Development Team**

| Role | Name | Email | GitHub |
|------|------|-------|--------|
| **Team Lead / Full Stack** | Rudraksh Kharadi | rudrakshkharadi53@gmail.com | [@RDK2305](https://github.com/RDK2305) |
| **Database / Documentation** | Bishal Paudel | bishalSharma24112002@gmail.com | [@bishal-sharma](https://github.com) |
| **Frontend Developer** | Gagan Singh | gs9814870091@gmail.com | [@gagan-singh](https://github.com) |
| **Backend / Database** | Gurjant Singh | gssandhu911@gmail.com | [@gurjant-singh](https://github.com) |

---

## 🔗 Important Links

- **GitHub Repository**: [RDK2305/back2u_mobile](https://github.com/RDK2305/back2u_mobile)
- **API Backend**: [back2u-h67h.onrender.com](https://back2u-h67h.onrender.com)
- **Flutter Documentation**: [flutter.dev](https://flutter.dev)
- **GetX Documentation**: [getx.pub](https://pub.dev/packages/get)

---

## 📋 Requirements & Dependencies

### **Core Dependencies**
```yaml
flutter:
  sdk: flutter

# State Management
get: ^4.6.6

# HTTP & API
dio: ^5.3.0

# Storage & Security
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0

# File & Image Handling
image_picker: ^1.0.4
cached_network_image: ^3.3.0

# Location Services
geolocator: ^10.0.0
permission_handler: ^11.4.0

# UI & Design
google_fonts: ^6.1.0
cupertino_icons: ^1.0.8
```

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🐛 Bug Reports & Features

Found a bug or have a feature request? Please create an issue on GitHub:

- [Report Bug](https://github.com/RDK2305/back2u_mobile/issues/new?labels=bug)
- [Request Feature](https://github.com/RDK2305/back2u_mobile/issues/new?labels=enhancement)

---

## 🎓 Academic Information

**Course**: Capstone Project / Final Year Project  
**University**: [Your University Name]  
**Semester**: [Your Semester]  
**Submission Date**: February 2026  

---

## 📞 Support & Contact

For questions or support, reach out to:
- **Team Lead**: Rudraksh Kharadi (rudrakshkharadi53@gmail.com)
- **Project Channel**: [Discord/Slack Channel Link]

---

<div align="center">

### Made with ❤️ by the Back2U Team

**Leave a ⭐ if you like this project!**

</div>
