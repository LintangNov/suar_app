# Product Requirements Document
## SUAR — Sistem Ubiquitous Adaptif Respons

**Versi:** 1.0.0  
**Tanggal:** Maret 2026  
**Tim:** Dev A · Dev B  
**Status:** Draft  
**Platform:** Android (Flutter)  
**Konteks:** IDCamp Dicoding Challenge 2026 — *Small Apps for Big Preparedness*

---

## 1. Overview

### 1.1 Problem Statement

Indonesia menduduki peringkat kedua negara paling rawan bencana di dunia dengan skor kerentanan 43,5%. Saat bencana terjadi, dua hal paling kritis yang dialami korban adalah:

1. **Komunikasi putus** — sinyal seluler dan internet mati, tidak bisa menghubungi siapapun
2. **Disorientasi** — tidak tahu harus kemana, tidak ada panduan evakuasi yang bisa diakses tanpa internet

Solusi yang ada saat ini (WhatsApp, Google Maps, aplikasi BMKG) semuanya bergantung penuh pada koneksi internet — menjadikannya tidak berguna justru saat paling dibutuhkan.

### 1.2 Solution

SUAR adalah aplikasi mobile Android yang dirancang khusus untuk tetap berfungsi penuh saat sinyal dan internet mati. SUAR menggabungkan dua teknologi utama:

- **Offline Mesh Chat** — komunikasi peer-to-peer langsung antar HP menggunakan Bluetooth dan WiFi Direct tanpa infrastruktur apapun
- **JIT Offline Map + EWS** — peta dan rute evakuasi yang diunduh otomatis saat peringatan dini terpicu, selagi sinyal masih ada

### 1.3 Tagline

> *Tetap Menyala Saat Segalanya Padam*

### 1.4 Target Pengguna

Warga masyarakat Indonesia yang tinggal atau berada di daerah rawan bencana alam — terutama zona tsunami, banjir bandang, dan erupsi gunung berapi.

---

## 2. Goals & Success Metrics

### 2.1 Goals

| # | Goal |
|---|---|
| G1 | Pengguna dapat berkomunikasi dengan orang di sekitarnya tanpa internet |
| G2 | Pengguna dapat menavigasi ke titik kumpul evakuasi saat internet mati |
| G3 | Pengguna mendapat peringatan dini bencana dan instruksi tindakan yang jelas |
| G4 | Aplikasi tetap berjalan di background tanpa bisa di-kill oleh OS |

### 2.2 Success Metrics (MVP)

| Metrik | Target |
|---|---|
| Waktu discovery peer pertama | < 10 detik |
| Waktu download JIT map (4G) | < 30 detik |
| Pesan terkirim via 3 hop | Berhasil dalam demo |
| App tidak di-kill setelah 30 menit background | ✅ |
| Navigasi berjalan tanpa internet | ✅ |

---

## 3. Fitur

### 3.1 Feature 1 — Offline Mesh Chat

#### Deskripsi
Pengguna dapat berkomunikasi dengan siapapun yang ada di sekitar mereka menggunakan jaringan peer-to-peer yang dibentuk dari HP-HP yang memiliki SUAR. Tidak memerlukan internet, tower seluler, atau infrastruktur apapun.

#### Sub-fitur

**F1.1 Auto Device Discovery**
- App secara otomatis melakukan scan HP sekitar yang memiliki SUAR
- Tidak perlu pairing manual seperti Bluetooth biasa
- Daftar peer muncul otomatis di UI dengan nama dan hop count
- Discovery berjalan terus di background selama app aktif

**F1.2 Message Routing (Hop)**
- Pesan dapat diteruskan otomatis dari HP ke HP (relay)
- Pengguna tidak perlu mengetahui berapa hop pesan mereka
- Peer yang menjadi relay tidak mendapat notifikasi
- TTL (Time To Live) default = 5 hop untuk mencegah loop
- Path tracking untuk menghindari pesan melewati node yang sama

**F1.3 Public Channel**
- Satu channel bersama yang bisa dilihat semua orang di mesh
- Mirip walkie-talkie group — cocok untuk sebar info darurat
- Pesan tampil dengan nama pengirim + warna avatar unik
- Tidak ada moderasi — semua pesan tampil secara real-time

**F1.4 Direct Message**
- Chat private 1-on-1 dengan peer tertentu
- Cari peer berdasarkan nama lengkap
- Notifikasi lokal saat ada pesan masuk

**F1.5 Background Service**
- App tetap berjalan saat ditutup via foreground service
- Notifikasi permanen di status bar (tidak bisa di-swipe)
- Android tidak bisa kill app selama foreground service aktif
- WorkManager sebagai safety net — restart otomatis dalam 15 menit jika ter-kill
- Battery optimization whitelist diminta saat onboarding

#### User Stories

| ID | Story |
|---|---|
| US-01 | Sebagai korban bencana, saya ingin melihat siapa saja yang ada di sekitar saya, agar bisa berkomunikasi tanpa internet |
| US-02 | Sebagai korban, saya ingin mengirim pesan ke seseorang yang tidak terhubung langsung dengan HP saya, agar pesan tetap bisa sampai via relay |
| US-03 | Sebagai korban, saya ingin membaca pesan dari semua orang di channel publik, agar bisa mendapat informasi situasi terkini |
| US-04 | Sebagai korban, saya ingin mencari anggota keluarga berdasarkan nama, agar bisa menghubungi mereka langsung |

---

### 3.2 Feature 2 — JIT Offline Map + EWS

#### Deskripsi
Sistem peringatan dini berbasis BMKG API yang secara otomatis mengunduh peta area sekitar pengguna dan rute evakuasi ke titik kumpul, selagi sinyal masih tersedia — sehingga ketika internet benar-benar mati, navigasi tetap bisa digunakan.

#### Sub-fitur

**F2.1 Early Warning System (EWS)**
- Polling BMKG API setiap 1 menit selagi internet tersedia
- Endpoint yang dipantau:
  - `autogempa.json` — gempa terkini real-time
  - `gempaberpotensi.json` — gempa berpotensi tsunami
- Trigger alert jika: magnitude ≥ 6.0 ATAU berpotensi tsunami
- Notifikasi push langsung ke pengguna
- Full screen alert takeover dengan data lengkap

**F2.2 AI Disaster Advisor (Rule-based)**
- Menganalisis data bencana + kondisi pengguna (elevasi, jarak dari episentrum)
- Output: rekomendasi tindakan yang jelas dan spesifik
- Tidak memerlukan internet — berjalan sepenuhnya offline
- Referensi protokol BNPB + BMKG per jenis bencana

| Jenis Bencana | Kondisi | Rekomendasi AI |
|---|---|---|
| Tsunami | Elevasi < 10m, jarak pantai < 5km | EVAKUASI SEGERA — tuju dataran tinggi |
| Banjir bandang | Lokasi di cekungan, curah hujan ekstrem | WASPADA — naik ke lantai atas |
| Erupsi gunung | Dalam radius bahaya PVMBG | EVAKUASI — jauhi arah angin |
| Gempa tektonik | Saat guncangan | SHELTER IN PLACE — Drop, Cover, Hold |
| Angin puting beliung | Terdeteksi di area | SHELTER IN PLACE — masuk gedung |

**F2.3 JIT Map Download**
- Saat EWS terpicu, app otomatis mengunduh peta tiles area sekitar pengguna
- Radius unduhan: 3–5 km dari posisi GPS pengguna
- Zoom level: 14–17 (detail tingkat jalan kaki)
- Estimasi ukuran: 8–15 MB per area
- Estimasi waktu unduh: < 30 detik (4G), < 60 detik (3G)
- Diunduh paralel dengan generate rute

**F2.4 Offline Route Generation**
- Saat EWS terpicu, app generate rute ke titik kumpul via OpenRouteService API
- Rute disimpan sebagai polyline koordinat ke SQLite
- Saat offline, flutter_map menggambar rute dari data lokal
- GPS tetap berfungsi (satelit, bukan internet)

**F2.5 Navigasi Evakuasi Offline**
- Tampil posisi pengguna real-time di peta offline
- Overlay rute evakuasi (polyline warna oranye #DE7356)
- Info navigasi: nama titik kumpul, jarak tersisa, estimasi waktu
- Off-route detection: warning jika melenceng > 50m dari rute
- Auto recalculate saat keluar jalur
- Bearing arrow menunjuk arah tujuan

**F2.6 Data Titik Kumpul Evakuasi**
Sumber data (prioritas):
1. InaRISK BNPB API — titik kumpul resmi (diunduh saat install)
2. OpenStreetMap — sekolah negeri, masjid besar, kantor kelurahan
3. Hardcode fallback — area demo (Yogyakarta)

#### User Stories

| ID | Story |
|---|---|
| US-05 | Sebagai pengguna, saya ingin mendapat peringatan bencana otomatis, agar bisa bersiap sebelum situasi memburuk |
| US-06 | Sebagai korban, saya ingin tahu harus melakukan apa saat bencana terjadi, agar tidak panik dan membuat keputusan salah |
| US-07 | Sebagai korban yang perlu evakuasi, saya ingin melihat rute ke titik kumpul di HP saya meski internet mati, agar bisa selamat sampai tujuan |
| US-08 | Sebagai korban dalam perjalanan evakuasi, saya ingin tahu kalau saya salah jalur, agar bisa segera kembali ke rute yang benar |

---

## 4. Non-Functional Requirements

| Kategori | Requirement |
|---|---|
| **Offline-first** | Semua fitur inti berfungsi tanpa internet |
| **Performance** | Discovery peer < 10 detik, map render < 2 detik dari cache |
| **Background** | App tidak ter-kill setelah 30 menit background |
| **Storage** | Ukuran install < 35 MB, cache tiles < 20 MB per area |
| **Battery** | Konsumsi background service < 5% per jam |
| **Compatibility** | Android 8.0 (API 26) ke atas |
| **Permission** | Graceful degradation jika permission ditolak — tampilkan pesan jelas |
| **Data** | Kredit "Data: BMKG" wajib tampil di UI (syarat resmi BMKG) |

---

## 5. Out of Scope (MVP)

Fitur-fitur berikut **tidak** dikerjakan untuk MVP:

- iOS support
- Voice note / pesan suara
- Foto dalam chat
- Peta seluruh Indonesia pre-downloaded
- Posko darurat real-time (data tidak tersedia sebelum bencana)
- Account / login system
- Crowdsourced situational AI (fitur lanjutan pasca MVP)
- Multi-language (English)

---

## 6. Tech Stack

### Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # state management
  go_router: ^14.6.3            # routing
  nearby_connections: ^4.3.0    # mesh P2P core
  flutter_background_service: ^5.0.0  # foreground service
  flutter_local_notifications: ^18.0.0
  battery_optimization_android: ^1.0.0
  flutter_map: ^8.2.2           # peta offline
  flutter_map_tile_caching: ^10.1.1
  geolocator: ^14.0.2           # GPS
  latlong2: ^0.9.1
  dio: ^5.9.2                   # HTTP client
  sqflite: ^2.4.2               # local database
  path: ^1.9.1
  path_provider: ^2.1.5
  google_generative_ai: ^0.4.7  # AI online (EWS notif)
  connectivity_plus: ^6.1.0
  permission_handler: ^11.3.0
  device_info_plus: ^10.1.0
  shared_preferences: ^2.3.0

dev_dependencies:
  flutter_lints: ^6.0.0
  build_runner: ^2.12.2
```

### External APIs

| API | Kegunaan | Autentikasi | Biaya |
|---|---|---|---|
| BMKG Open API | EWS data gempa & tsunami | Tidak perlu | Gratis |
| OpenRouteService | Generate rute evakuasi | API Key | Gratis (tier free) |
| OpenStreetMap | Source tiles peta | Tidak perlu | Gratis |
| InaRISK BNPB | Titik kumpul resmi | Tidak perlu | Gratis |
| Google Generative AI | Generate teks notifikasi EWS | API Key | Gratis (tier free) |

### Arsitektur Folder

```
lib/
├── core/
│   ├── mesh/
│   │   ├── mesh_service.dart
│   │   ├── message_router.dart
│   │   ├── device_discovery.dart
│   │   └── peer_manager.dart
│   ├── models/
│   │   ├── mesh_message.dart
│   │   ├── peer_device.dart
│   │   ├── user_profile.dart
│   │   └── evacuation_point.dart
│   ├── services/
│   │   ├── background_service.dart
│   │   ├── bmkg_service.dart
│   │   ├── map_cache_service.dart
│   │   ├── evacuation_router.dart
│   │   ├── local_db_service.dart
│   │   └── ai_advisor_service.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── channel/
│   ├── chat/
│   └── map/
└── shared/
    └── widgets/
```
#### Feature
```
features/
└── chat/
    ├── chat_screen.dart       # screen utama
    ├── chat_provider.dart     # riverpod provider
    └── widgets/
        ├── message_bubble.dart
        └── chat_input_bar.dart
```
---

## 7. Screens

| Screen | Deskripsi |
|---|---|
| Onboarding | Input nama, keterangan opsional, request permissions |
| Home | Status mesh, tombol masuk ke Chat / Peta, EWS banner |
| Public Channel | Chat group lokal, semua peer di mesh |
| Direct Message List | Daftar peer, cari berdasarkan nama |
| Direct Message Chat | Chat 1-on-1 dengan peer |
| EWS Alert | Full screen alert, data bencana, rekomendasi AI, CTA rute |
| Offline Map | Peta tiles, posisi user, overlay rute, info navigasi |
| Profil | Edit nama dan keterangan |

---

## 8. Pembagian Kerja

### Dev A — Mesh Engine + Backend

| Branch | Scope |
|---|---|
| `feature/app-setup` | pubspec, folder structure, theme, go_router |
| `feature/local-database` | SQLite schema: messages, peers, routes, evacuation points |
| `feature/mesh-service` | nearby_connections: advertise + discover |
| `feature/message-router` | Hop logic, TTL, path tracking, routing |
| `feature/background-service` | Foreground service, WorkManager, battery opt |
| `feature/bmkg-service` | Polling BMKG API, parsing, EWS trigger |
| `feature/map-cache-service` | FMTC tile download, OpenRouteService, simpan rute |

### Dev B — UI & Features

| Branch | Scope |
|---|---|
| `feature/permissions` | Request dan handle semua permissions |
| `feature/onboarding` | Onboarding flow UI |
| `feature/public-channel` | Public channel screen |
| `feature/direct-message` | DM list + chat screen |
| `feature/offline-map` | flutter_map render, polyline overlay, navigasi UI |
| `feature/ews-warning-ui` | EWS banner, full screen alert, AI rekomendasi UI |

### Interface Contract (Parallel Development)

Dev B menggunakan mock service selama Dev A belum selesai:

```dart
abstract class IMeshService {
  Stream<List<PeerDevice>> get nearbyPeers;
  Stream<MeshMessage> get incomingMessages;
  Future<void> startMesh(String username);
  Future<void> sendMessage(String toId, String content);
  void stopMesh();
}

abstract class IBmkgService {
  Stream<BmkgAlert?> get ewsAlerts;
  Future<void> startPolling();
  void stopPolling();
}
```

---

## 9. Timeline

| Minggu | Dev A | Dev B |
|---|---|---|
| 1 | app-setup + local-database + mesh-service | app-setup + permissions + onboarding |
| 2 | message-router + background-service | public-channel + direct-message |
| 3 | bmkg-service + map-cache-service | offline-map + ews-warning-ui |
| 4 | Integrasi + bug fix | Polish UI + integrasi |
| 5+ | Testing 3-4 HP fisik + submit | Testing + submit |

**Deadline submission:** 31 Maret 2026

---

## 10. Risiko & Mitigasi

| Risiko | Probabilitas | Mitigasi |
|---|---|---|
| nearby_connections tidak stabil di beberapa device | Sedang | Test awal di beberapa HP, fallback ke BLE saja |
| BMKG API berubah / down | Rendah | Cache response terakhir, fallback ke data offline |
| Flutter background service di-kill MIUI / One UI | Tinggi | Panduan whitelist per manufacturer di onboarding |
| Tiles map tidak cukup detail | Rendah | Zoom level 14-17 sudah mencakup detail jalan kaki |
| OpenRouteService API limit tercapai | Rendah | Free tier 2000 req/hari, cukup untuk demo |

---

## 11. Kriteria Penilaian IDCamp

| Kriteria | Bobot | Strategi SUAR |
|---|---|---|
| Kesesuaian tema | 30% | Disaster preparedness + AI + solusi digital darurat |
| Manfaat untuk Indonesia | 25% | Langsung menyasar 270 juta penduduk di negara rawan bencana #2 dunia |
| Desain & kemudahan penggunaan | 25% | UI panic-friendly, aksi kritis max 2 tap, font besar |
| Inovasi & kebaruan | 20% | Kombinasi offline mesh + JIT map belum ada di market |
| Bonus: real-time data | +nilai | BMKG API aktif saat online |
| Bonus: publicly accessible | +nilai | Target upload ke Play Store |

---

*SUAR — Tetap Menyala Saat Segalanya Padam*  
*IDCamp Dicoding Challenge 2026 · Tim Dev A & Dev B*
