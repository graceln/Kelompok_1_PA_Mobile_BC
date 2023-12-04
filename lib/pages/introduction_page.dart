// Import paket-paket yang diperlukan
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_page.dart';
import '../auth/register_page.dart';

// Kelas IntroductionPage adalah Stateless Widget untuk halaman pengantar
class IntroductionPage extends StatelessWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar perangkat
    final screenWidth = MediaQuery.of(context).size.width;

    // Scaffold adalah struktur dasar halaman dengan AppBar, Drawer, dan sebagainya
    return Scaffold(
      body: Container(
        // Container mengisi seluruh lebar dan tinggi halaman
        height: double.infinity,
        width: double.infinity,
        // Dekorasi latar belakang halaman
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            // Padding untuk memberikan jarak dari atas ke elemen berikutnya
            Padding(
              padding: EdgeInsets.only(top: 150.0),
              child: Image(
                // Menampilkan gambar logo kafe dari asset
                image: AssetImage('images/logocafe.png'),
                width: screenWidth < 600 ? 250 : 250, // Menyesuaikan lebar logo
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Text(
              // Teks sambutan
              "Welcome To Ahay Coffee",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman login ketika tombol "SIGN IN" ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    // Teks pada tombol "SIGN IN"
                    'SIGN IN',
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman registrasi ketika tombol "SIGN UP" ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    // Teks pada tombol "SIGN UP"
                    'SIGN UP',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
