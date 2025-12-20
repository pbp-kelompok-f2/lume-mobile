# lume-mobile

[![Build Status](https://app.bitrise.io/app/1e46c592-486b-4c10-a6bb-628e70eec4c8/status.svg?token=ZsOjDa31t4uC2u3S1Dha2g&branch=master)](https://app.bitrise.io/app/1e46c592-486b-4c10-a6bb-628e70eec4c8)

Download aplikasi versi terbaru: [Download APK](https://app.bitrise.io/app/1e46c592-486b-4c10-a6bb-628e70eec4c8/installable-artifacts/f3df89183374e4f7/public-install-page/be1f3b03c43cfca408f30107f63fd29a)

Tugas Kelompok PBP F - F02
- Naomyscha Attalie Maza
- Nisrina Fatimah
- Juma Jordan Bimo Simanjuntak
- Raqilla Al-abrar
- Ahmad Keenan Aryasatya Gamal

Deskripsi aplikasi (nama dan fungsi aplikasi)
Lumé Mobile adalah aplikasi mobile Flutter yang menjadi versi on-the-go dari platform wellness & commerce Lumé. Aplikasi ini memungkinkan pengguna untuk:
* Menjelajahi katalog produk (matras, botol minum, activewear, dan aksesoris pilates) langsung dari smartphone.
* Melihat dan memesan kelas pilates (weekly dan daily) dengan tampilan jadwal yang mobile-friendly.
* Mengelola keranjang (cart) dan checkout produk dengan metode pembayaran Cash on Delivery (COD).
* Melihat riwayat transaksi dan booking melalui halaman profil.
Lumé Mobile terhubung langsung dengan web service Django (PWS) yang sudah dibuat pada Proyek Tengah Semester, sehingga semua data produk, cart, dan booking tetap sinkron antara versi web dan mobile.

Daftar modul yang diimplementasikan beserta pembagian kerja per anggota

User & Auth + Profile – Ahmad Keenan Aryasatya Gamal 
* Implementasi halaman Login & Register (form input, validasi, state loading).
* Menyimpan dan mengelola token / session user (misalnya lewat cookie / header).
* Halaman Profile:
    * Menampilkan data user (username, nomor telepon).
    * Menampilkan riwayat transaksi dan riwayat booking yang diambil dari web service Django.
Product Catalog & Product Detail – Raqilla Al-abrar 
* Halaman Product List:
    * Menampilkan daftar produk dari web service (nama, harga, gambar, kategori).
    * Fitur pencarian dan filter kategori.
* Halaman Product Detail:
    * Menampilkan detail lengkap (brand, key_specs, variant, price).
    * Tombol Add to Cart yang memanggil endpoint cart di Django.
Cart Module – Nisrina Fatimah
* Halaman Cart:
    * Menampilkan daftar item cart yang diambil dari API (produk, jumlah, harga per item, line total).
    * Fitur update quantity dan hapus item dari cart.
* Menampilkan subtotal, ongkir tetap (Rp10.000), dan total berdasarkan data JSON dari endpoint cart-summary.
* Tombol Proceed to Checkout yang akan mengarahkan ke halaman checkout Flutter.
Checkout & Order Summary – Naomyscha Attalie Maza
* Halaman Checkout:
    * Form alamat pengiriman (alamat, kota, provinsi, kode pos, negara).
    * Menampilkan ringkasan order (subtotal, ongkir, total) dari API.
* Mengirim data alamat ke endpoint /checkout/api/cart-checkout/ untuk membuat ProductOrder di Django.
* Halaman Order Success:
    * Menampilkan status transaksi berhasil dan Order ID yang dikembalikan dari web service.
Booking Class (Weekly & Daily) – Juma Jordan Bimo Simanjuntak
* Halaman Class List:
    * Menampilkan daftar kelas pilates (weekly & daily) dari web service Django.
* Halaman Class Detail & Booking:
    * Menampilkan detail kelas (judul, instruktur, jadwal, kapasitas).
    * Tombol Book Class yang memanggil endpoint booking Django untuk membuat Booking.
* Halaman Booking Checkout / Confirmation:
    * Memanggil endpoint /checkout/api/booking-checkout/<booking_id>/ untuk mengonfirmasi booking dan mengecek kapasitas.
    * Menampilkan status sukses atau error (kelas penuh) berdasarkan response JSON

Peran atau aktor pengguna aplikasi
1. User (Pengguna)
    * Dapat melihat produk & kelas tanpa login.
    * Setelah login, pengguna dapat:
        * Menambahkan produk ke cart dan mengubah jumlah item.
        * Melakukan checkout produk dengan pembayaran COD.
        * Melakukan booking kelas pilates (weekly & daily).
        * Melihat riwayat transaksi & booking pada halaman profil.
2. Admin
    * Pengelolaan penuh data tetap dilakukan melalui aplikasi web (PWS) dan Django Admin (CRUD produk & kelas, lihat statistik dashboard).
    * Untuk versi Flutter, admin tidak memiliki UI khusus, namun semua data yang muncul di aplikasi mobile berasal dari data yang dikelola admin di PWS.

Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web (PWS)
Integrasi Flutter–Django dilakukan dengan memanfaatkan REST-like web service dari PWS Lumé. Alur besarnya:
1. Autentikasi & Session
    * Flutter mengirim request login ke endpoint autentikasi Django (misalnya /auth/login/ atau sejenis).
    * Jika berhasil, Flutter menyimpan session/token (bergantung implementasi PWS) dan mengirimkannya di request berikutnya (cookies / header).
2. Sinkronisasi Data Produk & Kelas
    * Modul Catalog dan Booking melakukan HTTP GET ke endpoint Django:
        * Contoh: /catalog/api/products/, /bookingkelas/api/sessions/ (disesuaikan dengan implementasi PWS).
    * Response berupa JSON (list produk / list kelas) lalu diparsing di Flutter menjadi model Dart dan ditampilkan di UI.
3. Manajemen Cart
    * Saat user menekan Add to Cart di Flutter, app mengirim POST ke endpoint cart PWS (misalnya /cart/api/add/).
    * Untuk menampilkan isi cart dan ringkasan harga, Flutter memanggil endpoint /checkout/api/cart-summary/:
        * Django menghitung subtotal, shipping (ongkir flat Rp10.000), dan total lalu mengembalikan JSON.
    * Flutter menampilkan data ini di halaman Cart & Checkout.
4. Checkout Produk
    * Di halaman Checkout Flutter, user mengisi form alamat.
    * Flutter mengirim POST ke endpoint /checkout/api/cart-checkout/ berisi:
        * address_line1, address_line2, city, province, postal_code, country, dan notes (opsional).
    * Django:
        * Mengecek item yang dipilih di cart.
        * Mengunci stok product (select_for_update) dan memastikan stok cukup.
        * Membuat ProductOrder & ProductOrderItem, mengurangi stok, dan menghitung total transaksi (termasuk ongkir).
        * Menghapus item yang sudah di-checkout dari cart.
        * Mengirim JSON response berisi success, message, order_id, subtotal, shipping, dan total.
    * Flutter menampilkan halaman Order Success berdasarkan response ini.
5. Checkout Booking Kelas
    * Setelah user membuat booking kelas lewat endpoint booking, Flutter memanggil /checkout/api/booking-checkout/<booking_id>/ dengan metode POST.
    * Django:
        * Mengunci ClassSessions terkait dan mengecek kapasitas (capacity_max vs jumlah booking konfirm).
        * Jika penuh → mengembalikan JSON error dan (opsional) menghapus booking.
        * Jika masih tersedia → membuat BookingOrder & BookingOrderItem, mengupdate capacity_current, dan menghitung total.
        * Mengirim JSON dengan success, message, order_id, subtotal, dan total.
    * Flutter menampilkan status sukses (booking berhasil) atau pesan error (kelas penuh).
6. Riwayat Transaksi & Booking
    * Halaman Profil Flutter memanggil endpoint riwayat (misal /checkout/api/orders/ dan /booking/api/my-bookings/).
    * Data yang sama dapat dilihat di web PWS, sehingga user melihat riwayat yang konsisten antara website dan aplikasi mobile.
Dengan integrasi ini, Lumé Mobile dan Lumé Web berjalan di atas basis data dan web service yang sama, sehingga setiap aksi (checkout, booking, pengelolaan cart) yang dilakukan di Flutter langsung tercermin pada aplikasi web dan sebaliknya.

Link Figma : https://www.figma.com/design/osIH3CEyPlh5W9PMRyY8Hz/Lum%C3%A9?node-id=214-829&t=mxRiPaaFLdEXkckl-1 
