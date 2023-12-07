import 'package:cloud_firestore/cloud_firestore.dart';

import 'favorite_page.dart';
import 'home_page.dart';

class FirestoreService {
  // Metode untuk menambahkan produk ke daftar favorit pengguna
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .set({'isFavorite': true});
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Metode untuk menghapus produk dari daftar favorit pengguna
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getFavoriteProducts(String userId) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      QuerySnapshot favoritesSnapshot =
          await userDocRef.collection('favorites').get();

      List<String> productIds = favoritesSnapshot.docs
          .map((doc) => doc['productId'] as String)
          .toList();

      QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('productId', whereIn: productIds)
          .get();

      List<Product> favoriteProducts = productsSnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return favoriteProducts;
    } catch (error) {
      print('Error getting favorite products: $error');
      throw error;
    }
  }
}
