🌿 Smart Greenhouse Coffee

IoT Monitoring, Device Automation, and AI Coffee Leaf Disease Detection
Built using Flutter • Python • IoTDB • Supabase • MQTT • ESP8266/ESP32

<p align="center"> <img src="https://raw.githubusercontent.com/github/explore/main/topics/iot/iot.png" width="110" /> <img src="https://raw.githubusercontent.com/github/explore/main/topics/flutter/flutter.png" width="110" /> <img src="https://raw.githubusercontent.com/github/explore/main/topics/python/python.png" width="110" /> </p>
<p align="center"> <img src="https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter&style=for-the-badge"/> <img src="https://img.shields.io/badge/Python-3.10-yellow?logo=python&style=for-the-badge"/> <img src="https://img.shields.io/badge/Supabase-Database-3FCF8E?logo=supabase&style=for-the-badge"/> <img src="https://img.shields.io/badge/Apache-IoTDB-red?logo=apache&style=for-the-badge"/> <img src="https://img.shields.io/badge/MQTT-HiveMQ-orange?logo=mqtt&style=for-the-badge"/> </p>
✨ Overview

Smart Greenhouse Coffee adalah sistem cerdas berbasis IoT + AI + Mobile App untuk memonitor kondisi rumah kaca kopi, melakukan kontrol otomatis, serta mendeteksi penyakit daun kopi menggunakan model ResNet50.

Sistem ini menggabungkan:

IoT Sensor → MQTT → IoTDB

Python Workers → Supabase

AI Detection (Flask + PyTorch)

Flutter Mobile App (Dashboard, Control, Diagnosis, Calendar)

Gemini AI untuk memberikan rekomendasi perawatan

🏗️ System Architecture
flowchart TD

A[ESP8266 / ESP32] -->|Sensor Data| B((MQTT Broker<br>HiveMQ Cloud))
B --> C[Python Workers]
C -->|Insert Time-series| D[Apache IoTDB]
C -->|Aggregations & Notes| E[Supabase]
F[Flutter App] -->|Realtime Devices & Stats| E
F -->|Upload Image| G[Flask AI API (PyTorch)]
G -->|Prediction + Leaf Analysis| F
F -->|Ask AI| H[Google Gemini]

🔥 Key Features
📡 IoT Monitoring

Data suhu, kelembapan, soil moisture setiap 5 detik

Realtime dashboard

Grafik Hour/Day/Week/Month

🔧 Device Automation

Pump, Fan, Humidifier

Mode otomatis & manual

Publish ke topic MQTT: greenhouse/coffee/actuators

🤖 AI Coffee Leaf Detection

ResNet50 (Healthy, Rust, Miner, Phoma)

Preprocessing: segmentation, LAB+CLAHE, morphology

Output:

class

probabilities

leaf analysis (% brown/green/background)

🧠 Gemini AI Notes

Penjelasan penyakit otomatis

Rekomendasi perawatan

Tersimpan sebagai “notes” di Supabase

📱 Flutter App

UI modern

Realtime notifications

Calendar with tasks

Diagnosis history + detail fullscreen

🧩 Tech Stack
Layer	Technology
Frontend	Flutter 3.27
AI Backend	Flask • PyTorch • OpenCV
Database	Apache IoTDB (sensor) • Supabase Postgres (user/data)
Messaging	HiveMQ MQTT Broker
Workers	Python (MQTT → IoTDB, IoTDB → Supabase, Notifications)
Cloud Storage	Supabase Storage (images)
AI Text	Google Gemini
📂 Project Structure (Aesthetic)
smart-greenhouse-coffee
│
├── backend/
│   ├── flask_api/
│   ├── workers/
│   ├── model/
│   └── requirements.txt
│
├── mobile_app/
│   ├── lib/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── diagnosis/
│   │   ├── notification/
│   │   └── calendar/
│   └── pubspec.yaml
│
├── iot_devices/
│   ├── esp8266_main.ino
│   └── esp32_cam.ino
│
└── docs/
    ├── erd_supabase.png
    ├── architecture.drawio
    └── flow_iotdb.png

🧪 MQTT Payload Example
Sensors
{
  "temperature": 27.4,
  "humidity": 88.1,
  "soil_moisture": 52,
  "timestamp": "2025-11-22T06:00:00"
}

Actuators
{
  "fan": true,
  "fan_mode": "auto",
  "pump": false,
  "pump_mode": "manual",
  "humidifier": false,
  "humidifier_mode": "auto"
}

🤖 AI Model (ResNet50)

Pretrained ImageNet → fine-tuning 4 kelas

Optimizer: Adam

Input: 224 × 224

Augmentasi kuat:

Horizontal/Vertical flip

Rotation

Color jitter

Affine transform

Output:

Prediksi kelas

Probabilitas

Leaf segmentation analysis

🚀 Installation
1. Clone Repo
git clone https://github.com/yourusername/smart-greenhouse-coffee.git
cd smart-greenhouse-coffee

2. Backend
cd backend
pip install -r requirements.txt
python app.py

3. Flutter App
flutter pub get
flutter run

4. IoTDB

Download IoTDB 2.0

Start server

Buat storage group + timeseries

5. Supabase

Import tabel

Buat bucket leaf-images
