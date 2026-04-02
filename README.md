# 📱 School Caller App  

🚀 Smart Incoming Call Identifier for Schools  


## ✨ Overview  

**School Caller App** is a Flutter-based mobile application that detects incoming calls and identifies whether the caller belongs to a registered school.

When a matching number is detected, the app shows:

- 🏫 School Name  
- 🖼️ App Logo  
- 🔔 Instant Notification  

---

## 🏷️ Badges  

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)  
![Dart](https://img.shields.io/badge/Dart-2.x-blue?logo=dart)  
![Platform](https://img.shields.io/badge/Platform-Android-green)  
![Status](https://img.shields.io/badge/Status-Active-success)  

---

## 🚀 Features  

- Detect incoming calls in real-time  
- Match caller number with saved number  
- Display school name instantly  
- Show notification with app branding  
- Lightweight and fast  

---

## 🛠️ Tech Stack  

| Technology        | Usage                |
|------------------|----------------------|
| Flutter          | UI Development       |
| Dart             | Programming Language |
| Android Services | Call Detection       |
| Notifications    | Alerts               |

---

## ⚙️ Installation  

```bash
# Clone repository
git clone https://github.com/SheetalKhakal/my-school-app.git

# Navigate to project
cd my-school-app

# Install dependencies
flutter pub get

# Run app
flutter run

⚠️ Important Notes
•	Works only on Android devices 
•	Requires runtime permissions 
•	Background service must be enabled 
•	iOS does NOT support call detection 
________________________________________

⚠  Android Limitations
Due to Android security updates (Android 14+):
•	Overlay (SYSTEM_ALERT_WINDOW) is restricted during incoming calls 
•	Apps cannot directly open full-screen UI automatically 
•	Only full-screen notifications are supported 
________________________________________

💡 Why This Limitation Exists
Google enforces these restrictions to:
•	Prevent malicious overlays 
•	Avoid phishing attacks 
•	Protect default phone app experience 
________________________________________

👨💻 Author
Sheetal Khakal
Flutter Developer
