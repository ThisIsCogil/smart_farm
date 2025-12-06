☕ Smart Greenhouse Coffee

IoT Monitoring & Control + AI Coffee Leaf Disease Detection + Mobile App

Smart Greenhouse Coffee adalah sistem terpadu berbasis IoT dan AI untuk memonitor kualitas lingkungan rumah kaca kopi, mengontrol perangkat otomatis, serta melakukan deteksi dini penyakit daun kopi menggunakan CNN (ResNet-50). Sistem ini menggabungkan ESP8266/ESP32, MQTT, Apache IoTDB, Supabase, Python Backend, dan Flutter Mobile App.

🚀 Fitur Utama
🌡️ 1. IoT Sensor Monitoring

Sensor: suhu, kelembapan, soil moisture

ESP8266/ESP32 mengirim data ke MQTT (HiveMQ Cloud) setiap 5 detik

Data disimpan ke Apache IoTDB sebagai time-series database

Grafik historis (hour/day/week/month) ditampilkan di aplikasi mobile

🔧 2. Kontrol Perangkat Otomatis & Manual

Perangkat:

Water Pump

Humidifier

Exhaust Fan

Mode:

Auto mode (berbasis threshold)

Manual mode (switch dari Flutter)

Worker Python meng-update state ke topic MQTT greenhouse/coffee/actuators

🌱 3. AI Coffee Leaf Disease Detection (CNN – ResNet50)

Model dilatih dengan dataset daun kopi (Healthy, Rust, Miner, Phoma)

Preprocessing adaptif (segmentation, LAB + CLAHE, morphological ops)

Upload foto via Flutter

Flask API melakukan prediksi & leaf analysis

Hasil disimpan ke Supabase + histori diagnosis

🤖 4. Smart Notes dengan Gemini AI

Setelah prediksi, user dapat meminta penjelasan otomatis berbasis Google Gemini

Menjelaskan penyakit dan rekomendasi perawatan

Tersimpan sebagai notes di Supabase

📱 5. Aplikasi Mobile (Flutter)

Dashboard sensor

Kontrol perangkat (auto/manual)

Kalender tugas

Riwayat diagnosis daun

Realtime notification dari Supabase

Export data ke Excel

🧠 6. Backend Worker & Pipeline

Worker Python untuk MQTT → IoTDB

Worker Python untuk IoTDB → Supabase (hourly/daily stats)

Worker notifikasi otomatis

Flask API untuk AI inference

🏗️ Arsitektur Sistem
[ESP8266 / ESP32] 
       |
       | MQTT Publish (JSON)
       v
[HiveMQ Cloud MQTT Broker]
       |
       v
[Python Workers]
   - iotdb_worker (insert sensor)
   - notif_worker (threshold alert)
   - supabase_worker (aggregations)
       |
       +--> Apache IoTDB (time-series)
       +--> Supabase (Postgres + Storage)
       |
       v
[Flutter Mobile App]
   - Dashboard
   - Control Devices
   - Diagnosis
   - Notifications (Realtime)
   - Calendar

📂 Struktur Folder (Direkomendasikan)
/backend
    /flask_api
    /model
    /workers
    iotdb_config.py
    supabase_config.py

/iot_devices
    esp8266_main.ino
    esp32_cam.ino

/mobile_app
    /lib
        /auth
        /home
            /dashboard
            /widgets
            /controllers
            /models
        /diagnosis
        /notification
        /calendar
    pubspec.yaml

/docs
    architecture.drawio
    erd_supabase.png
    flow_iotdb.png

README.md

🛠️ Teknologi yang Digunakan
Hardware

ESP8266 (Wemos D1 R2 Mini)

ESP32-CAM

Soil moisture sensor, DHT22

Software

Apache IoTDB 2.x — time-series database utama

Supabase (Postgres + Storage + Realtime)

HiveMQ Cloud — MQTT broker

Flask + PyTorch — AI inference API

Python workers — ETL IoTDB & Supabase

Flutter — aplikasi mobile

Gemini API — AI explanation

📡 MQTT Topic Structure
greenhouse/coffee/sensors
greenhouse/coffee/actuators
greenhouse/coffee/alerts


Contoh payload sensor:

{
  "temperature": 27.4,
  "humidity": 88.1,
  "soil_moisture": 52,
  "timestamp": "2025-11-22T06:00:00"
}


Contoh payload actuator:

{
  "fan": true,
  "fan_mode": "auto",
  "pump": false,
  "pump_mode": "manual",
  "humidifier": false,
  "humidifier_mode": "auto"
}

🤖 AI Model – ResNet50

Pretrained ImageNet → fine-tuned untuk 4 kelas

Input size 224×224

Optimizer: Adam

Augmentasi kuat (flip, rotation, color jitter, affine)

Accuracy > 95% (validasi)

📱 Fitur Flutter App
Dashboard

Card sensor realtime

Warna status otomatis (normal/warning/danger)

Device Control

Toggle switch manual

Mode otomatis berdasarkan threshold

Diagnosis

Foto → Crop → Upload → Prediksi

Tampilkan hasil + leaf analysis + Gemini notes

Calendar

Supabase realtime tasks

Notifications

Threshold alert

Device status update

History

Riwayat diagnosis + detail fullscreen

⚙️ Instalasi
1. Clone repository
git clone https://github.com/yourusername/smart-greenhouse-coffee.git
cd smart-greenhouse-coffee

2. Setup Python Backend
cd backend
pip install -r requirements.txt
python flask_api.py

3. Setup IoTDB

Download IoTDB 2.0 → configure → run

4. Setup Supabase

Buat project

Import tabel

Buat bucket leaf-images

5. Setup Flutter
flutter pub get
flutter run

📊 ERD (Supabase)

Tabel utama:

leaf_diagnoses

tasks

notifications

sensor_hourly_stats

sensor_daily_stats

users
