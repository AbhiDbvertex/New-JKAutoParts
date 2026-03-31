import 'package:flutter/material.dart';
import '../../users/customer/customer_rating_screen.dart';
import '../Modelss/order_history_model.dart';
import '../Services/Api_Service.dart';
// import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: FutureBuilder<List<OrderHistory>>(
        future: _apiService.orderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return orderHistoryShimmer(context);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:  Color(0xFFC4C0F6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Purple header
                        Container(
                          padding: EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:  Color(0xFFC4C0F6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('#${order.orderId} ${order.paymentMethod}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  order.status == 'Delivered'? GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> CustomerRatingScreen(productId: order.items[0].productId,)));
                                      print("Abhi:- print orderId :- ${order.id}");
                                    },
                                    child: Container(
                                      height: height*0.035,
                                      width: width*0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.blue.shade700
                                      ),
                                        child: Center(child: Text("Add Review",style: TextStyle(color: Colors.white),))
                                    ),
                                  ) : SizedBox(),
                                ],
                              ),
                              // Text(order.createdAt.toLocal().toString().split(' ')[0], style: TextStyle(color: Colors.white)),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt.toLocal()),
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text('Total ₹${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                              SizedBox(height: 4),
                              Text('Shipping Amount ${order.courierCharge.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                              if (order.status != 'pending')
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    width: 210,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: order.status == 'Delivered' ? Colors.green.shade700 : order.status == 'Cancelled' ? Colors.red : Colors.orange.shade400 ,
                                      ),
                                      child: Center(child: Text('Status: ${order.status}', style: TextStyle(color: Colors.white)))),
                                ),
                            ],
                          ),
                        ),
                        // Items list
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            // color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              ...order.items.map((item) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          item.productImages[0] ?? 'https://placehold.co/80x80', // Placeholder or actual URL
                                          // "https://img.freepik.com/free-photo/various-work-tools-worktop_1170-1505.jpg?semt=ais_hybrid&w=740&q=80",
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text('Quantity: ${item.units}'),
                                            Text('Price: ${item.sellingPrice.toStringAsFixed(2)}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),

                            ],
                          ),),

                        // Optional: Add status or tracking info
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget orderHistoryShimmer(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              child: Column(
                children: [
                  Container(
                    height: height * 0.15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 14, width: width * 0.4, color: Colors.white),
                            SizedBox(height: 6),
                            Container(height: 12, width: width * 0.3, color: Colors.white),
                            SizedBox(height: 6),
                            Container(height: 12, width: width * 0.25, color: Colors.white),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}