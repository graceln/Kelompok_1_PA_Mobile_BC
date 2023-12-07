import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pa_mobile/admin_pages/admin_home_page.dart';
import 'package:pa_mobile/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_services.dart';
import 'firebase_options.dart';
import 'pages/introduction_page.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> isFirstOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstOpen = prefs.getBool('first_open') ?? true;
    return firstOpen;
  }

  Future<void> setNotFirstOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('first_open', false);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        // Ensure that Firebase is initialized before checking the user state
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FutureBuilder<bool>(
              // Check if the app is opened for the first time
              future: isFirstOpen(),
              builder: (context, firstOpenSnapshot) {
                if (firstOpenSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  bool isFirstOpen = firstOpenSnapshot.data ?? true;

                  if (isFirstOpen) {
                    // Jika aplikasi pertama kali dibuka, tampilkan IntroductionPage
                    setNotFirstOpen(); // Setelah ditampilkan, tandai bahwa aplikasi sudah pernah dibuka
                    return IntroductionPage();
                  } else {
                    // Jika bukan aplikasi pertama kali dibuka, tampilkan halaman berdasarkan status otentikasi pengguna
                    return StreamBuilder<User?>(
                      stream: _authService.authStateChanges,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          String userId = snapshot.data!.uid;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              } else {
                                String userRole = userSnapshot.data!['role'];

                                // Berdasarkan peran pengguna, rutekan ke halaman yang sesuai
                                print(
                                    'UserRole: $userRole'); // Tambahkan ini untuk debugging

                                return userRole == 'admin'
                                    ? AdminBottomNav()
                                    : UserBottomNav();
                              }
                            },
                          );
                        } else {
                          return IntroductionPage();
                        }
                      },
                    );
                  }
                }
              },
            );
          } else {
            // You can display a loading indicator here if needed
            return CircularProgressIndicator();
          }
        },
      ),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
