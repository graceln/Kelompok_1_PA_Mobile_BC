import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product(
      {required this.name,
      required this.description,
      required this.price,
      required this.imageUrl});
}

class ProductInputPage extends StatefulWidget {
  @override
  _ProductInputPageState createState() => _ProductInputPageState();
}

class _ProductInputPageState extends State<ProductInputPage> {
  File? _image;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage() async {
    if (_image == null) {
      // Handle case when no image is selected
      return Future.error('No image selected');
    }

    // Mendapatkan nama file dari path gambar
    String fileName = _image!.path.split('/').last;

    // Menggunakan nama file asli untuk Firebase Storage
    Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$fileName');

    // Menggunakan putFile untuk mengunggah gambar
    UploadTask uploadTask = storageReference.putFile(_image!);

    // Menunggu hingga proses unggah selesai
    await uploadTask.whenComplete(() => null);

    // Mengambil URL unduhan setelah selesai
    return await storageReference.getDownloadURL();
  }

  Future<void> _addProduct() async {
    try {
      String imageUrl = await _uploadImage();

      // Buat objek Product
      Product newProduct = Product(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
      );

      // Simpan ke Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': newProduct.name,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      });

      // Tampilkan pemberitahuan berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kosongkan kembali field
      setState(() {
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _image = null;
      });
    } catch (error) {
      // Tangani error dan tampilkan pemberitahuan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(            
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Product Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Product Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Product Price',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addProduct();
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
