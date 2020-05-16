import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      body: FutureBuilder(
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            else
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => RefreshIndicator(
                  onRefresh: orderData.fetchOrders,
                  child: ListView.builder(
                    itemBuilder: (ctx, index) =>
                        OrderItem(orderData.orders[index]),
                    itemCount: orderData.orders.length,
                  ),
                ),
              );
          },
          future: Provider.of<Orders>(context, listen: false).fetchOrders()),
      drawer: AppDrawer(),
    );
  }
}
