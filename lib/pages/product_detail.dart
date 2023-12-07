// Import paket-paket yang diperlukan
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';

// Kelas untuk halaman detail produk
class ProductDetailPage extends StatefulWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Variabel untuk menyimpan nilai opsi pengguna
  String hotColdValue = 'Hot';
  String cupSizeValue = 'M';
  bool lessIceValue = false;
  bool lessSugarValue = false;
  int quantity = 1; // Kuantitas pesanan
  double subTotalHarga = 0; // Total harga berdasarkan kuantitas
  bool isFavorite = false;

  late User? currentUser; // Tambahkan variabel currentUser

  @override
  void initState() {
    super.initState();
    // Ambil instance pengguna saat ini saat objek dibuat
    currentUser = FirebaseAuth.instance.currentUser;
    checkFavoriteStatus();
  }

  // Fungsi untuk memeriksa apakah produk sudah ada di daftar favorit
  void checkFavoriteStatus() async {
    if (currentUser != null) {
      String userId = currentUser!.uid;
      bool favoriteStatus =
          await checkIfFavorite(userId, widget.product.productId);
      setState(() {
        isFavorite = favoriteStatus;
      });
    }
  }

  // Fungsi untuk memperbarui status favorit dan menampilkan snackbar
  Future<void> updateFavoriteStatus() async {
    if (currentUser != null) {
      String userId = currentUser!.uid;
      bool favoriteStatus =
          await checkIfFavorite(userId, widget.product.productId);

      setState(() {
        isFavorite = favoriteStatus;
      });

      showSnackbar(
          isFavorite ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit');
    }
  }

  // void _toggleFavorite() {
  //   setState(() {
  //     isFavorite = !isFavorite;
  //   });

  //   // Pastikan currentUser tidak null sebelum mengambil UID
  //   if (currentUser != null) {
  //     String userId = currentUser!.uid;

  //     // Panggil metode untuk menambah atau menghapus dari daftar favorit
  //     if (isFavorite) {
  //       FirestoreService().addToFavorites(userId, widget.product.id);
  //     } else {
  //       FirestoreService().removeFromFavorites(userId, widget.product.id);
  //     }

  //     // Tampilkan snackbar atau lakukan tindakan lain sesuai kebutuhan
  //     showSnackbar(
  //         isFavorite ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit');
  //   } else {
  //     // Handle jika currentUser null (mungkin pengguna belum login)
  //     showSnackbar('Pengguna belum login');
  //   }
  // }

  // Fungsi untuk menampilkan snackbar
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fungsi untuk menghitung total harga berdasarkan kuantitas
    void calculateSubTotalHarga() {
      double hargaProduk = widget.product.price;

      // Harga tambahan jika ukuran cangkir yang dipilih adalah L
      double tambahanHargaCangkirL = cupSizeValue == 'L' ? 3000 : 0;
      subTotalHarga = (hargaProduk + tambahanHargaCangkirL);

      subTotalHarga = subTotalHarga * quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.product.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit
                    .contain, // Sesuaikan dengan pilihan yang diinginkan (contain, cover, dsb.)
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.product.price)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Opsi Hot/Cold
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hot/Cold:',
                    style: TextStyle(fontSize: 18),
                  ),
                  DropdownButton<String>(
                    value: hotColdValue,
                    onChanged: (value) {
                      setState(() {
                        hotColdValue = value!;
                      });
                    },
                    items: ['Hot', 'Cold']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Opsi Tambahan (Less Ice, Less Sugar)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Options:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8.0),
                  CheckboxListTile(
                    value: lessIceValue,
                    onChanged: (value) {
                      setState(() {
                        lessIceValue = value!;
                      });
                    },
                    title: Text('Less Ice'),
                  ),
                  CheckboxListTile(
                    value: lessSugarValue,
                    onChanged: (value) {
                      setState(() {
                        lessSugarValue = value!;
                      });
                    },
                    title: Text('Less Sugar'),
                  ),
                ],
              ),

              // Opsi Ukuran Gelas (M dan L)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cup Size:',
                    style: TextStyle(fontSize: 18),
                  ),
                  // SizedBox(width: 250.0),
                  DropdownButton<String>(
                    value: cupSizeValue,
                    onChanged: (value) {
                      setState(() {
                        cupSizeValue = value!;
                        calculateSubTotalHarga();
                      });
                    },
                    items: ['M', 'L']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Kuantitas dan tombol tambah/kurang
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 0) {
                              quantity--;
                              calculateSubTotalHarga();
                            }
                          });
                        },
                      ),
                      Text(
                        '$quantity',
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            calculateSubTotalHarga();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              Divider(),
              // Total Harga
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Harga :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(subTotalHarga)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Fungsi untuk menyimpan data favorit ke Firestore
                      void addToFavorite() async {
                        if (currentUser != null) {
                          String userId = currentUser!.uid;

                          // Periksa apakah produk sudah ada di daftar favorit
                          bool alreadyFavorite = await checkIfFavorite(
                              userId, widget.product.productId);

                          if (alreadyFavorite) {
                            // Produk sudah ada di daftar favorit, lakukan aksi hapus favorit
                            await removeFromFavorite(
                                userId, widget.product.productId);
                          } else {
                            // Produk belum ada di daftar favorit, lakukan aksi tambah favorit
                            await addToFavorites(
                                userId, widget.product.productId);
                          }

                          // Perbarui status favorit dan tampilkan snackbar
                          await updateFavoriteStatus();
                        } else {
                          // Pengguna tidak login, beri tanggapan atau arahkan ke halaman login
                          showSnackbar('Silakan login terlebih dahulu.');
                        }
                      }

                      // Panggil fungsi untuk menyimpan data favorit
                      addToFavorite();
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite
                          ? Colors.red
                          : null, // Warna ikon terisi jika sudah favorit
                    ),
                    label: Text(
                      isFavorite ? 'Remove from Favorite' : 'Add to Favorite',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Fungsi untuk menyimpan data pemesanan ke Firestore
                      void placeOrder() async {
                        // Ambil informasi pengguna yang sedang login
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          String userId = user.uid;

                          // Persiapkan data pemesanan
                          Map<String, dynamic> cartData = {
                            'productName': widget.product.name,
                            'cupSize': cupSizeValue,
                            'hotCold': hotColdValue,
                            'lessIce': lessIceValue,
                            'lessSugar': lessSugarValue,
                            'quantity': quantity,
                            'subTotalPrice': subTotalHarga,
                            // tambahkan data pesanan lainnya sesuai kebutuhan
                          };

                          // Simpan data pemesanan ke dalam koleksi orderHistory
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('cart')
                              .add(cartData)
                              .then((_) {
                            // Tampilkan snackbar jika berhasil menambahkan ke keranjang
                            showSnackbar('Berhasil menambahkan ke keranjang');
                          }).catchError((error) {
                            // Tampilkan snackbar jika terjadi error
                            showSnackbar('Error: $error');
                          });
                        } else {
                          // Pengguna tidak login, beri tanggapan atau arahkan ke halaman login
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Silakan login terlebih dahulu.'),
                            ),
                          );
                          // Tambahkan navigasi ke halaman login jika diperlukan
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        }
                      }

                      // Panggil fungsi untuk menyimpan data pemesanan
                      placeOrder();
                    },
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> checkIfFavorite(String userId, String productId) async {
    DocumentSnapshot favoriteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite')
        .doc(productId)
        .get();

    return favoriteDoc.exists;
  }

  Future<void> addToFavorites(String userId, String productId) async {
    Map<String, dynamic> favoriteData = {
      'productId': widget.product.productId,
      'name': widget.product.name,
      'description': widget.product.description,
      'price': widget.product.price,
      'imageUrl': widget.product.imageUrl,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite')
        .doc(productId)
        .set(favoriteData);
  }

  Future<void> removeFromFavorite(String userId, String productId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorite')
        .doc(productId)
        .delete();
  }
}
