<div align="center">
  
  # 🚨 SUAR (Sistem Peringatan Dini & Evakuasi Bencana)
  
  **Aplikasi mitigasi bencana *offline-first* dengan integrasi AI Triage, rute evakuasi cerdas, dan komunikasi Mesh (P2P).**

  ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
  ![Riverpod](https://img.shields.io/badge/Riverpod-blue?style=for-the-badge)
  ![Gemini AI](https://img.shields.io/badge/Gemini%20AI-Flash%201.5-orange?style=for-the-badge)

</div>

---

## 📖 Tentang SUAR

**SUAR** hadir untuk menjembatani titik kritis antara terjadinya bencana alam (gempa bumi & tsunami) dengan tindakan penyelamatan diri. Ketika infrastruktur telekomunikasi lumpuh pasca-bencana, SUAR tetap beroperasi sebagai "kompas penyelamat" berkat arsitektur *Offline-First* yang tangguh.

Aplikasi ini menggabungkan data seismik waktu-nyata, analisis spasial risiko bencana, dan Kecerdasan Buatan (AI) untuk memberikan instruksi keselamatan yang dipersonalisasi sesuai lokasi presisi pengguna.

## ✨ Fitur Utama

### 🧠 1. AI Triage EWS (Early Warning System)
Menarik data gempa bumi langsung dari **BMKG** dan menganalisis posisi pengguna terhadap peta risiko tsunami **InaRISK BNPB**. Mesin **Google Gemini 1.5 Flash** kemudian menghasilkan keputusan *Triage* (Evakuasi vs. Berlindung) dan panduan darurat secara instan.

### 🗺️ 2. Smart Offline Evacuation (Hybrid Snapping)
Sistem pemetaan yang revolusioner untuk evakuasi tanpa internet:
* **Geofence Caching:** Otomatis mengunduh peta (*map tiles*) radius 3KM di latar belakang saat pengguna terdeteksi memasuki Zona Merah InaRISK.
* **Hybrid Routing Algorithm:** Mencari dataran tinggi terdekat (>5 meter) yang aman dari tsunami menggunakan algoritma 8-arah mata angin, memvalidasi elevasi via OpenRouteService (ORS), dan men-*snap* rute ke jalur khusus pejalan kaki (`foot-walking`).
* **Offline Fallback:** Menyimpan rute evakuasi ke memori internal (`SharedPreferences`) untuk langsung ditampilkan saat koneksi terputus.

### 📡 3. Mesh Network Chat *(Segera Hadir)*
*Status: Dalam Tahap Pengembangan (WIP)*
* Komunikasi P2P (*Peer-to-Peer*) menggunakan modul Bluetooth/Wi-Fi Direct.
* *Public Channel* untuk broadcast darurat dan *Direct Message* untuk mencari anggota keluarga tanpa memerlukan sinyal BTS/Internet.

---

## 🏗️ Arsitektur & Tech Stack

* **Framework:** Flutter (SDK ^3.10.4)
* **State Management:** Riverpod (`flutter_riverpod`)
* **Routing:** GoRouter
* **Maps & GIS:** * `flutter_map` & `latlong2`
    * `flutter_map_tile_caching` (FMTC ObjectBox Backend)
    * OpenRouteService (Directions, Snap, & Elevation API)
* **AI Integration:** `google_generative_ai`
* **Network & Hardware:** `dio`, `geolocator`, `connectivity_plus`

---

## 🚀 Memulai (Getting Started)

### Prasyarat
Pastikan Anda telah menginstal Flutter SDK dan Dart di perangkat Anda.

### Instalasi

1. **Kloning Repositori**
   ```bash
   git clone [https://github.com/username-anda/suar_app.git](https://github.com/username-anda/suar_app.git)
   cd suar_app
   ```

2. **Unduh Dependencies**

    ```Bash
    flutter pub get
    ```

3. **Pengaturan Environment Variables (.env)**
    Buat sebuah file bernama .env di root directory (sejajar dengan pubspec.yaml) dan masukkan API Key Anda:

    ```Cuplikan kode
    # .env
    GEMINI_API_KEY=masukkan_api_key_google_gemini_anda_di_sini
    ORS_API_KEY=masukkan_api_key_open_route_service_anda_di_sini
    ```

4. **Jalankan Aplikasi**
    ```Bash
    flutter run
    ```

## 📂 Struktur Direktori Utama

    Proyek ini menggunakan arsitektur berbasis fitur (Feature-First Architecture):

    ```Plaintext
    lib/
    ├── core/
    │   ├── router/           # Konfigurasi GoRouter
    │   └── theme/            # Desain sistem, warna, dan tipografi
    ├── features/
    │   ├── ews_ai/           # Logika integrasi BMKG, InaRISK, dan Gemini AI Triage
    │   ├── map_evacuation/   # Sistem Peta, Algoritma Hybrid Snapping, dan Caching
    │   ├── mesh_chat/        # [WIP] Modul komunikasi P2P
    │   └── onboarding/       # Izin akses dan identitas perangkat
    └── main.dart             # Entry point aplikasi
    ```

## 🛠️ Panel Developer (Skenario Pengujian)
    Untuk mempermudah presentasi atau pengujian tanpa harus menunggu bencana asli terjadi, SUAR dilengkapi dengan EWS Simulator.
    Akses fitur ini melalui ikon 🐛 (Bug) di AppBar Home Screen untuk menjalankan:

    Simulasi Gempa Tsunami + Masuk Zona Merah.

    Simulasi Gempa Ringan Darat.

    Simulasi pengunduhan Map Cache dan rute offline secara paksa.

    <div align="center">
    <i>Dibuat dengan dedikasi untuk memperkuat resiliensi masyarakat Indonesia menghadapi bencana alam.</i>
    </div>