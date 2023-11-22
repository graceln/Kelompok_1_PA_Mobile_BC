import 'package:flutter/material.dart'; // Import package untuk Flutter Material Design
import 'package:google_fonts/google_fonts.dart';  // Import package untuk Google Fonts
import 'package:pa_mobile/coffee/coffee_list.dart'; // Import file coffee_list.dart yang berisi daftar kopi

class HomePage extends StatefulWidget { // Kelas HomePage yang merupakan StatefulWidget
  const HomePage({Key? key}) : super(key: key); // Konstruktor HomePage

  @override  // Override metode createState untuk membuat state
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> { // Kelas _HomePageState yang merupakan State dari HomePage
  @override
  Widget build(BuildContext context) {

     // Mendapatkan lebar dan tinggi layar menggunakan MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold( // Scaffold sebagai kerangka utama
      backgroundColor: Colors.grey[900],  // Warna latar belakang Scaffold
      // BottomNavigationBar untuk navigasi bawah
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        selectedIconTheme: IconThemeData(color: Color(0xFFE57734)),
        unselectedIconTheme: IconThemeData(color: Colors.white),
      ),
      // Tubuh utama aplikasi
      body: Column(
        children: [
          // Bagian atas dengan judul
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.05, right: screenWidth * 0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom teks dengan judul
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Find the best ",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 56,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Coffee for you",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 56,
                      ),
                    ),
                  ],
                ),
                // Ikon favorit di sebelah kanan judul
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.14, top: screenHeight * 0.01),
                  child: Icon(Icons.favorite),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0), // Spasi vertikal
          // Bagian tengah dengan daftar kopi
          Expanded(
            child: ListView(
               // Menggunakan widget CoffeeList sebanyak yang diinginkan
              children: [
                CoffeeList(),
                CoffeeList(),
                CoffeeList(),
                CoffeeList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
