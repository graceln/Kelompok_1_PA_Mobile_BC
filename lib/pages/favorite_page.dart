
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';
import 'product_detail.dart';

// Kelas untuk merepresentasikan objek produk
class FavProduct {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  FavProduct({    
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory FavProduct.fromMap(Map<String, dynamic> map) {
    return FavProduct(      
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  FavProduct copyWith({    
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    return FavProduct(    
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class FavoriteProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Favorite Coffee',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FavCoffeeList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Kelas untuk menampilkan daftar produk dalam bentuk GridView
class FavCoffeeList extends StatelessWidget {
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
              return FavCoffeeItem(product: productList[index]);
            },
          );
        }
      },
    );
  }
}

// Kelas untuk merepresentasikan item produk dalam daftar
class FavCoffeeItem extends StatelessWidget {
  final Product product;

  FavCoffeeItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke ProductDetailPage saat produk ditekan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
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

Stream<List<Product>> getProductList() {
  FirebaseAuth auth = FirebaseAuth.instance;

  return FirebaseAuth.instance.authStateChanges().asyncMap(
    (user) async {
      if (user != null) {
        String userId = user.uid;

        // Mengambil data favorit dari koleksi 'favorite' berdasarkan productId
        QuerySnapshot favoriteSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorite')
            .get();

        // Mengonversi snapshot produk menjadi daftar objek Product
        List<Product> favoriteProducts = favoriteSnapshot.docs.map((doc) {
          return Product(
            productId: doc['productId'] as String,
            name: doc['name'] as String,
            description: doc['description'] as String,
            imageUrl: doc['imageUrl'] as String,
            price: (doc['price'] as num).toDouble(),
          );
        }).toList();

        return favoriteProducts;
      } else {
        // User belum login, return daftar produk kosong atau lakukan sesuatu yang sesuai
        return [];
      }
    },
  );
}