import 'package:flutter/material.dart'; // Import package untuk Flutter Material Design
import 'package:pa_mobile/pages/home_page.dart'; // Import halaman home_page.dart


void main() { // Fungsi utama yang dipanggil saat aplikasi dimulai
  runApp(const MyApp());  // Menjalankan aplikasi dengan widget utama MyApp
}

class MyApp extends StatelessWidget { // Kelas MyApp yang merupakan turunan dari StatelessWidget
  const MyApp({super.key}); // Konstruktor kelas MyApp

  @override // Metode build untuk membangun antarmuka pengguna
  Widget build(BuildContext context) {
    return MaterialApp( // Mengembalikan widget MaterialApp sebagai antarmuka utama
      debugShowCheckedModeBanner: false, // Menyembunyikan banner debug di sudut kanan atas
      home: HomePage(),  // Menetapkan halaman utama aplikasi sebagai HomePage()
      theme: ThemeData(brightness: Brightness.dark), // Menetapkan tema aplikasi dengan brightness dark
    );
  }
}
