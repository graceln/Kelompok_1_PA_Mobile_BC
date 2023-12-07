import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPageAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order')
            .orderBy('orderDate',
                descending:
                    true) // Menambahkan orderBy untuk mengurutkan berdasarkan waktu
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> orderDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderDocs.length,
                  itemBuilder: (context, orderIndex) {
                    var orderItem = orderDocs[orderIndex];
                    String orderId = orderItem.id;
                    String orderStatus = orderItem['orderStatus'];
                    String orderUserId = orderItem['userId'];
                    String orderUserName = orderItem['userName'];
                    Timestamp orderDate = orderItem['orderDate'] as Timestamp;
                    List<dynamic> products = orderItem['products'];

                    Color statusColor = Colors.black;
                    switch (orderStatus) {
                      case 'On Queue':
                        statusColor = Colors.blue;
                        break;
                      case 'Process':
                        statusColor = Colors.yellow;
                        break;
                      case 'Delivery':
                        statusColor = Colors.orange;
                        break;
                      case 'Complete':
                        statusColor = Colors.green;
                        break;
                      case 'Canceled':
                        statusColor = Colors.red;
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: ListTile(
                          title: Text('Order ID: $orderId'),
                          subtitle: Text(
                            '$orderStatus',
                            style: TextStyle(
                              color: statusColor,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Order Details'),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order ID: $orderId',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Order Date: ${orderDate.toDate()}',
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'User ID: ${orderUserId}',
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Username: ${orderUserName}',
                                      ),
                                      Divider(),
                                      SizedBox(height: 10),
                                      for (var product in products)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Product Name: ${product['productName']}'),
                                            Text(
                                                'Cup Size: ${product['cupSize']}'),
                                            Text(
                                                'Hot/Cold: ${product['hotCold']}'),
                                            Text(
                                                'Less Ice: ${product['lessIce']}'),
                                            Text(
                                                'Less Sugar: ${product['lessSugar']}'),
                                            Text(
                                                'Quantity: ${product['quantity']}'),
                                            Divider(),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          trailing: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Update Order Status'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            updateOrderStatus(orderUserId,
                                                orderId, 'On Queue');
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('On Queue'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateOrderStatus(orderUserId,
                                                orderId, 'Process');
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Process'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateOrderStatus(orderUserId,
                                                orderId, 'Delivery');
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Delivery'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateOrderStatus(orderUserId,
                                                orderId, 'Complete');
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Complete'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateOrderStatus(orderUserId,
                                                orderId, 'Canceled');
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Canceled'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text('Update Status'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void updateOrderStatus(String orderUserId, String orderId, String newStatus) {
    // Update status pesanan di koleksi 'order'
    FirebaseFirestore.instance
        .collection('order')
        .doc(orderId)
        .update({'orderStatus': newStatus}).then((_) {
      print('Status pesanan berhasil diperbarui');      

      // Periksa apakah dokumen dengan orderId sudah ada di orderHistory
      FirebaseFirestore.instance
          .collection('users')
          .doc(orderUserId)
          .collection('orderHistory')
          .doc(orderId)
          .get()
          .then((orderHistoryDoc) {
        // Pastikan dokumen sudah ada sebelum melakukan pembaruan
        if (orderHistoryDoc.exists) {
          // Update status pesanan di koleksi '/users/userid/orderHistory/orderid'
          FirebaseFirestore.instance
              .collection('users')
              .doc(orderUserId)
              .collection('orderHistory')
              .doc(orderId)
              .update({'orderStatus': newStatus}).then((_) {
            print('Status pesanan di orderHistory berhasil diperbarui');
          }).catchError((error) {
            print('Error updating order status in orderHistory: $error');
          });
        } else {
          print('Dokumen dengan orderId belum ada di orderHistory');
        }
      }).catchError((error) {
        print('Error checking orderHistory document: $error');
      });
    }).catchError((error) {
      print('Error updating order status: $error');            
    });
  }
}
