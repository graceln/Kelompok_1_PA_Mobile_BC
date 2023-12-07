import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  final String userId;

  CartPage({required this.userId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Page'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('cart')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Cart is empty'),
            );
          }

          // Inisialisasi total harga
          double totalHarga = 0;

          // Menyimpan produk yang dipilih
          List<Map<String, dynamic>> selectedProducts = [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var cartItem = snapshot.data!.docs[index];

                    // Mendapatkan nilai dari Firestore
                    String productName = cartItem['productName'];
                    String cupSize = cartItem['cupSize'];
                    String hotCold = cartItem['hotCold'];
                    bool lessIce = cartItem['lessIce'];
                    bool lessSugar = cartItem['lessSugar'];
                    int quantity = cartItem['quantity'];
                    double subTotalPrice = cartItem['subTotalPrice'];

                    // Menambahkan subtotal ke total harga
                    totalHarga += subTotalPrice;

                    // Menambahkan produk ke dalam daftar yang dipilih
                    selectedProducts.add({
                      'productName': productName,
                      'cupSize': cupSize,
                      'hotCold': hotCold,
                      'lessIce': lessIce,
                      'lessSugar': lessSugar,
                      'quantity': quantity,
                      'subTotalPrice': subTotalPrice,
                    });

                    // Membuat widget untuk menampilkan detail produk
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(productName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cup Size: $cupSize'),
                            Text('Hot/Cold: $hotCold'),
                            Text('Less Ice: ${lessIce ? 'Yes' : 'No'}'),
                            Text('Less Sugar: ${lessSugar ? 'Yes' : 'No'}'),
                            Text('Quantity: $quantity'),
                            Text(
                                'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(subTotalPrice)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeProductFromCart(cartItem.reference);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Menambahkan tombol untuk melakukan pemesanan
              ElevatedButton(
                onPressed: () {
                  _placeOrder(selectedProducts, totalHarga);
                },
                child: Text('Order All'),
              ),
              SizedBox(height: 10)
            ],
          );
        },
      ),
    );
  }

  // Fungsi untuk menghapus satu produk dari cart
  Future<void> _removeProductFromCart(
      DocumentReference cartItemReference) async {
    try {
      // Tampilkan dialog konfirmasi
      bool deleteConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content: Text(
                'Apakah Anda yakin ingin menghapus produk ini dari keranjang?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Batal menghapus
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Konfirmasi menghapus
                },
                child: Text('Hapus'),
              ),
            ],
          );
        },
      );

      // Hapus produk jika pengguna konfirmasi
      if (deleteConfirmed == true) {
        await cartItemReference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk berhasil dihapus dari keranjang'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk. Silakan coba lagi.'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error removing product: $error');
    }
  }

  // Fungsi untuk menempatkan pesanan
  void _placeOrder(List<Map<String, dynamic>> selectedProducts, double totalHarga) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;
    String orderId = generateOrderId(); // Fungsi untuk menghasilkan orderId yang unik

    try {
      // Ambil nama pengguna dari koleksi /users
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      String userName = userDoc['name'];

      // Simpan data produk yang dipilih ke koleksi order
      await FirebaseFirestore.instance.collection('order').doc(orderId).set({
        'userId': userId,
        'userName': userName,
        'products': selectedProducts,
        'totalHarga': totalHarga,
        'orderDate': DateTime.now(),
        'orderStatus': 'On Queue',
      });

      // Simpan data produk yang dipilih ke koleksi /users/userid/orderHistory
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('orderHistory').doc(orderId).set({
        'products': selectedProducts,
        'totalHarga': totalHarga,
        'orderDate': DateTime.now(),
        'orderStatus': 'On Queue',
      });

      // Hapus semua produk dari cart
      await _clearCart(userId);

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan berhasil! Silakan cek halaman order secara berkala'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // Tampilkan snackbar gagal jika terjadi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan. Silakan coba lagi.'),
          duration: Duration(seconds: 2),
        ),
      );
      print('Error placing order: $error');
    }
  }
}

// Fungsi untuk menghasilkan orderId yang unik
String generateOrderId() {
  // Implementasi fungsi ini tergantung pada kebutuhan aplikasi Anda
  // Anda dapat menggunakan timestamp, random number, atau kombinasi keduanya
  // Contoh sederhana: return 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
  return 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
}




  // Fungsi untuk menghapus semua produk dari cart
  Future<void> _clearCart(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
