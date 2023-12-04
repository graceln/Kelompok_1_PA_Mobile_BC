import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import halaman-halaman terkait
import 'admin_order_page.dart';
import 'product_option.dart';
import '../admin_pages/setting_admin_page.dart';

// Model untuk representasi produk
class Product {
  final String name; // Nama produk
  final String description; // Deskripsi produk
  final double price; // Harga produk
  final String imageUrl; // URL gambar produk

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Konstruktor untuk mengonversi dokumen Firestore menjadi objek Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'],
    );
  }
}

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Find Your Best Coffee',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Spacer(), // Menambahkan spacer agar tombol My Cart berada di sebelah kanan
            // ElevatedButton(
            //   onPressed: () {
            //     // Dapatkan UserID saat aplikasi dimulai
            //     User? user = FirebaseAuth.instance.currentUser;
            //     if (user != null) {
            //       String userId = user.uid;
            //       print('UserID: $userId');
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => CartPage(
            //             userId: userId,
            //           ),
            //         ),
            //       );
            //     } else {
            //       print('Pengguna belum login');
            //     }
            //   },
            //   child: Text("My Cart"),
            // ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CoffeeList(),
      ),
    );
  }
}



// Kelas untuk menampilkan daftar produk dalam bentuk GridView
class CoffeeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: getProductList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Product> productList = snapshot.data ?? [];
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return CoffeeItem(product: productList[index]);
            },
          );
        }
      },
    );
  }
}

// Kelas untuk merepresentasikan item produk dalam daftar
class CoffeeItem extends StatelessWidget {
  final Product product;

  CoffeeItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   // Navigasi ke ProductDetailPage saat produk ditekan
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => ProductDetailPage(product: product),
      //     ),
      //   );
      // },
      child: Card(
        // Mengganti Container dengan Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2, // Anda bisa menyesuaikan nilai elevasi sesuai kebutuhan
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.imageUrl,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 1.0),
                  Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(product.price)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Metode untuk mengambil data produk dari Firestore
Stream<List<Product>> getProductList() {
  return FirebaseFirestore.instance.collection('products').snapshots().map(
    (snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    },
  );
}

class AdminBottomNav extends StatefulWidget {
  @override
  _AdminBottomNavState createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int _currentIndex = 0;
  int _savedIndex = 0;
  final List<Widget> _children = [
    AdminHomePage(), // Home Page
    OrderPageAdmin(), // Favorite Page
    ProductOptionPage(), //Input Page
    AdminSettingsPage(), // Settings Page
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // index halaman
        onTap: (index) {
          setState(() {
            _savedIndex = _currentIndex; // Simpan indeks saat ini sebelum berpindah
            onTabTapped(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Icon untuk navigation Home
            label: 'Home', // Nama navigation
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.shopping_cart_rounded), // Icon untuk navigation Product
            label: 'Order', // Nama navigation
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document), // Icon untuk navigation Product
            label: 'Data', // Nama navigation
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Icon untuk navigation Settings
            label: 'Settings', // nama navigation
          ),
        ],
        backgroundColor: Colors.grey[900], // Warna background bottom navigation bar
        selectedItemColor: Color(0xFFE57734), // Warna ikon yang dipilih
        unselectedItemColor: Colors.grey, // Warna ikon yang belum dipilih
      ),
    );
  }
}
