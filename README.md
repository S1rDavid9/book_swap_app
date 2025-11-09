# 📚 BookSwap - Student Book Exchange Platform

![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

A Flutter mobile application that enables students to discover, list, and exchange books with peers. Built with Firebase backend and modern state management using Riverpod.

---

## 🎯 Project Overview

BookSwap solves a common problem for students: expensive textbooks and limited access to reading materials. Instead of buying new books every semester, students can exchange books they've finished with others who need them. The app facilitates the entire process from discovery to completion, with built-in chat for coordination.

### Key Features

- 🔐 **Secure Authentication** - Email/password with verification
- 📖 **Book Management** - List, edit, delete your books with photos
- 🔍 **Smart Discovery** - Browse available books from other students
- 🔄 **Swap System** - Request, accept, reject, and complete book exchanges
- 💬 **Real-time Chat** - Coordinate exchanges directly in-app
- ⚡ **Live Updates** - See changes instantly across all devices
- 📱 **Cross-platform** - Works on Android and iOS

---

## 🏗️ Architecture

### Tech Stack

**Frontend:**
- **Flutter 3.24.5** - UI framework
- **Riverpod 2.6.1** - State management
- **Cached Network Image** - Optimized image loading

**Backend:**
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - Image hosting
- **Firebase App Check** - Security

### Project Structure
```
book_swap/
├── lib/
│   ├── core/
│   │   └── constants/
│   │       └── app_constants.dart          # App-wide constants
│   ├── models/
│   │   ├── book_model.dart                 # Book data structure
│   │   ├── chat_model.dart                 # Chat & message models
│   │   ├── swap_model.dart                 # Swap request model
│   │   └── user_model.dart                 # User profile model
│   ├── providers/
│   │   ├── auth_provider.dart              # Authentication state
│   │   ├── chat_provider.dart              # Chat state
│   │   ├── firestore_provider.dart         # Database queries
│   │   ├── loading_provider.dart           # Loading indicators
│   │   ├── settings_provider.dart          # User preferences
│   │   ├── storage_provider.dart           # File uploads
│   │   └── providers.dart                  # Central export
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── email_verification_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── browse/
│   │   │   ├── book_details_screen.dart
│   │   │   └── browse_screen.dart          # Main navigation hub
│   │   ├── chats/
│   │   │   ├── chat_detail_screen.dart     # Conversation view
│   │   │   └── chats_screen.dart           # Chat list
│   │   ├── my_listings/
│   │   │   ├── add_edit_book_screen.dart
│   │   │   ├── my_listings_screen.dart
│   │   │   └── my_offers_screen.dart       # Swap management
│   │   └── settings/
│   │       └── settings_screen.dart
│   ├── services/
│   │   ├── auth_service.dart               # Firebase Auth wrapper
│   │   ├── chat_service.dart               # Chat operations
│   │   ├── firestore_service.dart          # Database operations
│   │   └── storage_service.dart            # File management
│   ├── widgets/
│   │   └── book_card.dart                  # Reusable book display
│   ├── firebase_options.dart               # Firebase config
│   └── main.dart                           # App entry point
├── android/                                # Android-specific files
├── ios/                                    # iOS-specific files
├── web/                                    # Web support files
├── windows/                                # Windows desktop files
├── linux/                                  # Linux desktop files
├── pubspec.yaml                            # Dependencies
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK:** 3.24.5 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** 3.9.2+ (included with Flutter)
- **Firebase Account:** [Create one free](https://firebase.google.com/)
- **IDE:** VS Code or Android Studio
- **Git:** For version control

### Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/S1rDavid9/book_swap_app.git
cd book_swap_app
cd book_swap
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Firebase Setup

**Create a Firebase Project:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the wizard
3. Enable Google Analytics (optional)

**Enable Firebase Services:**
1. **Authentication:** 
   - Navigate to Authentication → Sign-in method
   - Enable "Email/Password"
2. **Firestore Database:**
   - Navigate to Firestore Database → Create database
   - Start in **test mode** (change rules later)
   - Choose a location closest to your users
3. **Storage:**
   - Navigate to Storage → Get Started
   - Start in **test mode**

**Add Firebase to Your App:**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Generate config files for each platform
- Link your app to Firebase

**Security Rules (Important!):**

After testing, update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Books: anyone can read, owner can write
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Swaps: participants can read/write
    match /swaps/{swapId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || 
         request.auth.uid == resource.data.receiverId);
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.receiverId ||
                       request.auth.uid == resource.data.senderId;
    }
    
    // Chats: participants only
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.user1Id || 
         request.auth.uid == resource.data.user2Id);
    }
    
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

Storage rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_covers/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /profile_pictures/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

#### 4. Run the App

**Check connected devices:**
```bash
flutter devices
```

**Run on your device:**
```bash
# Debug mode
flutter run

# Release mode (faster)
flutter run --release
```

**Platform-specific commands:**
```bash
# Android
flutter run -d android

# iOS (Mac only)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

---

## 📱 Features Walkthrough

### 1. Authentication Flow

**Sign Up:**
1. User enters name, email, and password
2. Firebase creates account
3. Verification email sent automatically
4. User must verify before accessing app

**Email Verification:**
- Auto-checks every 3 seconds for verification
- Manual "Check Now" button available
- Resend email option

**Login:**
- Email/password authentication
- "Forgot Password" flow included
- Persistent session (stays logged in)

**Implementation Highlight:**
```dart
// Auto-check for email verification
Timer.periodic(const Duration(seconds: 3), (timer) async {
  await FirebaseAuth.instance.currentUser?.reload();
  if (user.emailVerified) {
    // Navigate to home screen
  }
});
```

### 2. Book Management

**Adding a Book:**
1. Tap "+" button on My Books tab
2. Upload book cover photo (optional)
3. Enter title and author
4. Select condition (New, Like New, Good, Used)
5. Book appears in your listings and browse feed

**Editing/Deleting:**
- Edit: Update any field, keeps same bookId
- Delete: Removes book and associated image from Storage
- Validation prevents empty fields

**Technical Details:**
- Images uploaded to `book_covers/{userId}/{uuid}.jpg`
- Images compressed to 1024x1024, 85% quality
- Old images deleted on update to save storage

### 3. Browse & Discovery

**Features:**
- Grid view of all available books
- Filters out your own books
- Shows book condition and status badges
- Real-time updates when books are added/removed

**Search Flow:**
```
Firestore Query → StreamProvider → UI Auto-update
```

No manual refresh needed—new books appear instantly!

### 4. Swap System

**Creating a Swap Request:**
1. Browse available books
2. Tap "Swap" on desired book
3. Confirmation dialog
4. Request sent to book owner
5. Book status changes to "Pending"

**Managing Requests (Received):**
- View all incoming requests in "My Offers" → Received
- See requester's profile
- Accept: Opens chat for coordination
- Reject: Book becomes available again

**Managing Requests (Sent):**
- Track your outgoing requests
- Cancel anytime before acceptance
- Chat unlocked after acceptance

**Completing a Swap:**
1. Users coordinate via chat
2. After receiving book, requester taps "I Received the Book"
3. Confirmation dialog
4. Book ownership transfers
5. Book status resets to "Available" under new owner

**State Machine:**
```
┌─────────┐
│ Pending │ ──Accept──→ ┌──────────┐ ──Complete──→ ┌───────────┐
└─────────┘             │ Accepted │                │ Completed │
     │                  └──────────┘                └───────────┘
     │                       │
     └──Reject──→ ┌──────────┐
                  │ Rejected │
                  └──────────┘
```

### 5. Real-time Chat

**Features:**
- One-on-one messaging
- Message timestamps
- Date separators
- Unread indicators
- Auto-scroll to latest message

**When Chat Opens:**
- After accepting a swap request
- Tap "Start Chat" button
- Chat persists for future reference

**Technical Implementation:**
- Chat ID: `{smallerUserId}_{largerUserId}` (ensures uniqueness)
- Messages stored in subcollection
- Last 100 messages loaded
- Real-time listener updates UI instantly

---

## 🔥 Firebase Console Guide

### Monitoring Your App

**Authentication:**
- View registered users
- See email verification status
- Disable problematic accounts

**Firestore Database:**
- Browse collections in real-time
- See document creation timestamps
- Debug data structure issues
- Run manual queries

**Storage:**
- View uploaded images
- Check storage usage
- Download files for debugging

**App Check:**
- Monitor legitimate traffic
- Block unauthorized requests
- View token usage

### Useful Firebase Commands
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# View logs
firebase functions:log

# Local emulator (for testing)
firebase emulators:start
```

---

## 🧪 Testing

### Manual Testing Checklist

**Authentication:**
- [ ] Sign up with valid email
- [ ] Sign up with duplicate email (should fail)
- [ ] Email verification flow works
- [ ] Login with wrong password (should fail)
- [ ] Login with correct credentials
- [ ] Password reset email received
- [ ] Logout works

**Books:**
- [ ] Add book without image
- [ ] Add book with image
- [ ] Edit book details
- [ ] Delete book (check Storage for cleanup)
- [ ] Browse shows other users' books only

**Swaps:**
- [ ] Request swap (book status changes to Pending)
- [ ] Accept swap (book status changes to Swapped, chat opens)
- [ ] Reject swap (book status returns to Available)
- [ ] Complete swap (book ownership transfers)
- [ ] Cancel pending swap

**Chat:**
- [ ] Send message
- [ ] Receive message (test with two devices)
- [ ] Messages persist after closing app
- [ ] Chat list shows latest message
- [ ] Unread indicator works

### Running Tests
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

---

## 🐛 Troubleshooting

### Common Issues

**"Firebase not initialized" error:**
```bash
# Solution: Reconfigure Firebase
flutterfire configure
```

**Images not uploading:**
- Check Storage rules allow writes for authenticated users
- Verify internet connection
- Check file size (must be < 5MB)

**Chats not updating:**
- Verify Firestore rules allow reads on messages collection
- Check that chatId format is correct
- Ensure user is authenticated

**Build errors after `flutter pub get`:**
```bash
# Clean build cache
flutter clean
flutter pub get
flutter run
```

**Android build fails:**
```bash
# Check Gradle version in android/gradle/wrapper/gradle-wrapper.properties
# Should be 8.12 or higher

# Rebuild
cd android
./gradlew clean
cd ..
flutter run
```

**iOS build fails (Mac only):**
```bash
# Update CocoaPods
cd ios
pod install
pod update
cd ..
flutter run
```

---

## 🎨 Customization

### Changing App Colors

Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF1A237E),  // Primary color
  secondary: const Color(0xFFFFB300),  // Accent color
),
```

---

## 📊 Performance Optimization

### Current Optimizations

✅ **Image Caching:** Using `cached_network_image` to cache book covers  
✅ **Query Limits:** Browse screen limits to 100 books  
✅ **Lazy Loading:** Messages load last 100 only  
✅ **Stream Disposal:** Riverpod auto-disposes unused streams  
✅ **Image Compression:** Uploads compressed to 1024x1024px  

### Future Improvements

- [ ] Implement pagination for book listings
- [ ] Add local database (Hive/SQLite) for offline mode
- [ ] Optimize Firestore queries with composite indexes
- [ ] Implement image thumbnail generation
- [ ] Add analytics to track user behavior

---

## 🔐 Security Considerations

### Current Security Measures

- ✅ Email verification required before app access
- ✅ Firestore rules restrict data access
- ✅ Storage rules prevent unauthorized uploads
- ✅ Passwords never stored in plaintext (Firebase handles hashing)
- ✅ API keys in firebase_options.dart are safe (public)

### Best Practices Implemented

1. **Principle of Least Privilege:** Users can only modify their own data
2. **Input Validation:** Forms validate before submission
3. **Error Handling:** Never expose Firebase error details to users
4. **Rate Limiting:** Firebase automatically rate-limits auth attempts

### What to Add for Production

- [ ] Enable App Check to prevent API abuse
- [ ] Add reCAPTCHA for auth flows
- [ ] Implement rate limiting for swap requests
- [ ] Add content moderation for book titles/images
- [ ] Enable two-factor authentication

---

## 🌍 Deployment

### Building Release APK (Android)
```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Building for iOS (Mac only)
```bash
# Build for App Store
flutter build ios --release

# Open Xcode for submission
open ios/Runner.xcworkspace
```

### Web Deployment
```bash
# Build web version
flutter build web

# Deploy to Firebase Hosting
firebase init hosting
firebase deploy
```

---

## 📝 License

This project is licensed under the MIT License - see below for details:
```
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 Author

**Akachi David Nwanze** 