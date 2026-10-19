# 🍔 Foodie - Food Delivery & Ordering App

A modern, full-featured food ordering and delivery Flutter application powered by Firebase, featuring an intuitive customer experience and a dedicated admin management system.

---

## ✨ Features

### 👤 Customer Experience
- **Authentication**: Email/Password authentication powered by Firebase Auth.
- **Dynamic Food Catalog**: Browse food items by category with rich details, pricing, and descriptions.
- **Cart Management**: Add/remove items, update quantities, and calculate totals in real-time.
- **Checkout Flow**: Seamless ordering process.
- **Dark & Light Mode**: Seamless theme switching with persistent settings.
- **Push & Local Notifications**: Order alerts and status updates using Firebase Cloud Messaging (FCM) and Local Notifications.

### 🛠️ Admin Dashboard
- **Admin Management**: Dedicated administrative view to manage food catalog items.
- **Live User Cart Monitoring**: View active user carts and ordering activity.
- **Catalog Management**: Add, update, and manage available food items and stock.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend & Database**:
  - [Firebase Core](https://firebase.google.com/)
  - [Firebase Authentication](https://firebase.google.com/docs/auth)
  - [Cloud Firestore](https://firebase.google.com/docs/firestore)
  - [Firebase Cloud Messaging (FCM)](https://firebase.google.com/docs/cloud-messaging)
- **Local Storage & Notifications**:
  - `shared_preferences`
  - `flutter_local_notifications`

---

## 📁 Project Structure

```text
lib/
├── firebase_options.dart   # Firebase configuration
├── main.dart               # App entrypoint & theme setup
├── models/                 # Data models (FoodItem, CartItem)
├── services/               # Services (AuthService, FirestoreService, NotificationService)
├── viewmodels/             # MVVM ViewModels (Cart, Catalog, Theme, Admin, Auth)
└── views/                  # UI screens
    ├── admin/              # Admin dashboard & management views
    ├── auth/               # Login, register, and welcome views
    ├── cart/               # Cart screen
    ├── checkout/           # Checkout flow
    ├── home/               # Home screen & food list
    └── profile/            # User profile & preferences
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- An active Firebase project configured

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Rifan108/foodie.git
   cd foodie
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure your Firebase credentials (`google-services.json` for Android / `GoogleService-Info.plist` for iOS) are properly set up.

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📄 License
This project is for educational and personal use.
