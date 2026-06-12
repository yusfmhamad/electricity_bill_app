# ⚡ Electricity Bill Estimator App

A Flutter Android application for estimating monthly electricity bills based on TNB (Tenaga Nasional Berhad) tiered tariff rates.

## 📱 Features

- **Electricity Bill Calculation** using tiered block pricing
- **Month Selection** via dropdown (January – December)
- **Unit Input** with validation (1 – 1000 kWh)
- **Rebate Slider** (0% – 5%)
- **Local SQLite Database** to store and retrieve records
- **List View** showing Month and Final Cost
- **Detail View** with full info + Edit & Delete
- **About Page** with student info, instructions, and GitHub link
- **Custom Theme**: Deep blue color scheme, custom icons, styled title bar

## 🧮 Tariff Calculation

| Block | Units | Rate |
|-------|-------|------|
| Block 1 | 1 – 200 kWh | 21.8 sen/kWh |
| Block 2 | 201 – 300 kWh | 33.4 sen/kWh |
| Block 3 | 301 – 600 kWh | 51.6 sen/kWh |
| Block 4 | 601 – 1000 kWh | 54.6 sen/kWh |

**Final Cost = Total Charges − (Total Charges × Rebate%)**

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yusfmhamad/electricity_bill_app.git
   cd electricity-bill-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build signed APK** (for submission)
   ```bash
   flutter build apk --release
   ```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── bill_record.dart         # Data model
├── database/
│   └── database_helper.dart     # SQLite operations
├── utils/
│   ├── electricity_calculator.dart  # Calculation logic
│   └── app_theme.dart           # Colors & theme
└── screens/
    ├── calculator_screen.dart   # Main screen
    ├── history_screen.dart      # List view screen
    ├── detail_screen.dart       # Detail/Edit/Delete screen
    └── about_screen.dart        # About page
```

## 📦 Dependencies

```yaml
sqflite: ^2.3.0          # Local database
path: ^1.8.3             # Path utilities
intl: ^0.18.1            # Currency formatting
url_launcher: ^6.2.4     # Open URLs
```

## 🎓 Assignment Info

- **Course**: Mobile Technology
- **Assignment**: Individual Assignment (20%)
- **Student**: [Yusf mhamad]
- **Student ID**: [QIU23-0384]

## ©️ Copyright

© 2026 Yusf Mhamad. All rights reserved.
