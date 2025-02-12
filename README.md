# Nurture

## 📌 About
Nurture is an innovative application designed to help users analyze soil quality using an Arduino-integrated hardware system with a soil sensor. By simply inserting the sensor into the soil, the device scans for nutrient levels, and the Nurture app translates the raw data into user-friendly insights.

This Flutter-based application provides real-time analysis, historical tracking, and personalized recommendations to help users make informed agricultural decisions. Additionally, it supports extensibility, allowing users to integrate additional apps and tools as needed.

## 🔥 Features
- **Arduino-Integrated Soil Scanning**: Reads soil nutrient data through connected hardware.
- **User-Friendly Interface**: Designed for simplicity and ease of use.
- **Data Translation**: Converts raw sensor readings into understandable insights.
- **Customizable & Extensible**: Users can add new functionalities via external apps.
- **Database Support**: Stores scanned data with full CRUD (Create, Read, Update, Delete) functionality.
- **History & Recommendations**: Saves previous results and provides actionable suggestions.
- **Cross-Platform Compatibility**: Built with Flutter, ensuring smooth performance on Android and iOS.

## 🚀 Getting Started
### Prerequisites
- **Hardware**:
  - Arduino Uno (or compatible board)
  - Soil Sensor
  - HC-05 Bluetooth Module (for communication)
- **Software**:
  - Flutter SDK
  - Arduino IDE
  - Dependencies:
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      flutter_bluetooth_serial: ^0.4.0
      permission_handler: ^11.0.0
      sqflite: ^2.3.0
    ```

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Nurture.git
   cd Nurture
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Connect the Arduino and upload the necessary code via the Arduino IDE.
4. Run the Flutter application:
   ```bash
   flutter run
   ```

## 📡 Hardware Integration
1. Connect the soil sensor to the Arduino following the wiring instructions.
2. Ensure the HC-05 Bluetooth module is correctly configured.
3. Upload the Arduino sketch that reads sensor data and sends it via Bluetooth.

## 📂 Database & Storage
- Uses SQLite for offline storage.
- Allows users to save and manage scan history with CRUD operations.
- Stores recommendations based on soil data.

## 🛠 Future Improvements
- Integration with cloud storage for remote access.
- Machine learning-based recommendations for better accuracy.
- Multi-language support.

## 🤝 Contribution
Contributions are welcome! Feel free to fork the project and submit pull requests.

## 📄 License
This project is licensed under the MIT License.

---
Developed with ❤️ using Flutter & Arduino.

