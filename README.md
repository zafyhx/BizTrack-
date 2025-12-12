# 🛒 BIZTRACK — Point of Sales & Manajemen Stok UMKM

BizTrack adalah aplikasi Point of Sales (POS) dan manajemen inventaris berbasis Android yang dikembangkan untuk memenuhi tugas mata kuliah **Pengembangan Perangkat Lunak Bergerak**.
Aplikasi ini dibangun dengan pendekatan **Mobile-First** menggunakan **Flutter** dan **Firebase**, dirancang untuk membantu UMKM mengatasi ketidaksesuaian stok, pencatatan manual, dan proses transaksi yang tidak efisien melalui antarmuka modern serta sinkronisasi real-time.

---

## 📚 Daftar Isi

* Tentang Proyek
* Fitur Utama
* Teknologi yang Digunakan
* Developer

---

## 💡 Tentang Proyek

BizTrack merupakan ekosistem digital yang menghubungkan aktivitas kasir (front-end) dengan manajemen gudang (back-end).
Aplikasi ini menerapkan prinsip **Defensive Programming** untuk memastikan validasi stok sebelum transaksi diproses.

**Fokus pengembangan meliputi:**

* Implementasi arsitektur **MVVM & Clean Architecture**
* **Sinkronisasi Data Real-time** menggunakan Firestore
* **Manajemen Stok Otomatis** dengan Atomic Batch Writes
* **Autentikasi Aman** serta validasi input
* **UI Modern & Responsif** menggunakan Grid Layout

---

## 🚀 Fitur Utama

| Kategori   | Fitur              | Status | Deskripsi                                                     |
| ---------- | ------------------ | ------ | ------------------------------------------------------------- |
| Auth       | Registrasi & Login | ✅      | Autentikasi Firebase dengan validasi form & error handling    |
| Inventaris | CRUD Produk        | ✅      | Tambah, edit, hapus produk dengan foto dan harga              |
| Inventaris | Real-time Sync     | ✅      | Stok otomatis terupdate tanpa refresh manual                  |
| Kasir      | Transaksi Cart     | ✅      | Keranjang transaksi & perhitungan Grand Total otomatis        |
| Kasir      | Validasi Stok      | ✅      | Mencegah transaksi jika stok barang habis                     |
| Kasir      | Batch Writes       | ✅      | Pengurangan stok & pencatatan riwayat dilakukan secara atomic |
| UI/UX      | Filter & Search    | ✅      | Pencarian instan & filter kategori                            |
| UI/UX      | Visual Menu        | ✅      | Tampilan grid responsif dengan indikator stok                 |

---

## 💻 Teknologi yang Digunakan

### Frontend Framework

* **Flutter** — Framework cross-platform untuk membangun UI responsif
* **Dart** — Bahasa pemrograman utama untuk Flutter
* **Material Design** — Sistem desain UI yang konsisten dan modern

### State Management

* **Provider (v6.1.1)** — Pengelolaan state menggunakan ChangeNotifier

### Backend & Database (Firebase)

* **Firebase** — Backend as a Service (BaaS)
* **Firebase Authentication (v6.1.2)** — Sistem login dan autentikasi
* **Cloud Firestore (v6.1.0)** — Database NoSQL realtime dengan data sync otomatis
* **Firebase Core (v4.2.1)** — Inisialisasi dan integrasi layanan Firebase

### UI, Icons, & Typography

* **Google Fonts (v6.1.0)** — Font modern dari Google
* **Cupertino Icons** — Library ikon bergaya iOS
* **Intl (v0.20.2)** — Internationalization & number/date formatting

---

## 👨‍💻 Developer

Tim Mahasiswa PTIK UNS (Angkatan 2023):

* **Bagus Satyo Nugroho (K3523022)** — Lead Architect & Backend Engineer
* **Aditya Sheva Pratama (K3523004)** — UI/UX Designer & Frontend Developer
* **Albert Indra Wiguna (K3523008)** — Quality Assurance & Database Administrator
