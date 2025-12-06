# 🌿 Smart Greenhouse Coffee  
**IoT Monitoring • Device Automation • AI Leaf Disease Detection • Flutter App**

---

## 🔥 Overview  
Smart Greenhouse Coffee adalah sistem lengkap untuk:

- Monitoring suhu, kelembapan, dan soil moisture secara realtime  
- Kontrol otomatis & manual (pump, fan, humidifier)  
- Deteksi penyakit daun kopi menggunakan **AI (ResNet50)**  
- Penyimpanan data time-series menggunakan **Apache IoTDB**  
- Penyimpanan user, histori, gambar, dan diagnosis menggunakan **Supabase**  
- Aplikasi mobile berbasis **Flutter**  
- Penjelasan penyakit otomatis memakai **Google Gemini AI**

Semua komponen terintegrasi dalam pipeline modern dan scalable.

---

## 🧠 Fitur Utama

### 📡 IoT Monitoring  
- ESP8266/ESP32 mengirim data ke MQTT setiap 5 detik  
- Worker Python memasukkan data ke IoTDB  
- Flutter menampilkan grafik Hour/Day/Week/Month  

### 🔧 Kontrol Perangkat  
- Pump, Fan, Humidifier  
- Mode **Auto** (berdasarkan threshold)  
- Mode **Manual** (switch dari Flutter)  
- Publish actuator ke topic MQTT:  
  `greenhouse/coffee/actuators`

### 🤖 AI Coffee Leaf Disease Detection  
- Model ResNet50 (4 kelas): Healthy, Rust, Miner, Phoma  
- Preprocessing adaptif (segmentation, LAB+CLAHE, morphology)  
- Flask API mengembalikan:
  - kelas penyakit  
  - probabilitas  
  - leaf analysis (% green, brown, background)

### 🧠 Gemini Notes  
- Menjelaskan penyakit & memberi rekomendasi perawatan  
- Tersimpan sebagai notes di Supabase  

### 📱 Flutter App Features  
- Dashboard sensor realtime  
- Device control  
- Calendar tasks  
- Diagnosis history (list & fullscreen)  
- Realtime notifications  
- Export grafik ke Excel  

---
