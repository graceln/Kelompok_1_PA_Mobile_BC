import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountEditPage extends StatefulWidget {
  @override
  _AccountEditPageState createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load data pengguna saat inisialisasi halaman
  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Ambil data pengguna dari Firestore berdasarkan UID
    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.uid)
        .get();

    // Setel nilai controller sesuai dengan data pengguna
    setState(() {
      _nameController.text = userData.data()?['name'] ?? '';
      _addressController.text = userData.data()?['address'] ?? '';
    });
  }

  
  // Metode untuk memilih gambar dari galeri
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Metode untuk mengunggah gambar profil ke Firebase Storage
  Future<String> _uploadImage() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now()}.png');
    UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  // Metode untuk menyimpan perubahan pada profil
  void _saveChanges(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;

  // Ambil URL gambar profil yang tersimpan di Firestore
  DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(user?.uid)
      .get();

  String storedImageUrl = userData.data()?['profileImageUrl'] ?? '';

  try {
    // Cek apakah gambar profil telah berubah
    bool isImageChanged = _image != null && _image!.path != storedImageUrl;

    // Update data pengguna di Firestore hanya jika ada perubahan pada gambar
    if (isImageChanged) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'name': _nameController.text,
        'address': _addressController.text,
        'profileImageUrl': await _uploadImage(),
        // Tambahkan atribut lainnya sesuai kebutuhan
      });
    } else {
      // Jika tidak ada perubahan pada gambar, hanya update data pengguna lainnya
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'name': _nameController.text,
        'address': _addressController.text,
        // Tambahkan atribut lainnya sesuai kebutuhan
      });
    }

    // Tampilkan notifikasi bahwa perubahan telah disimpan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data berhasil disimpan!'),
      ),
    );
  } catch (e) {
    print('Error saving changes: $e');
    // Tampilkan notifikasi bahwa terjadi kesalahan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan data. Silahkan coba lagi.'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _getImage();
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : Icon(Icons.add_a_photo, size: 40),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveChanges(context);
                  }
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
