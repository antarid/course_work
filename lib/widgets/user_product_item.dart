import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  Product product;

  UserProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => EditProductScreen(product),
                  ),
                );
              },
            ),
            Consumer<Products>(
              child: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              builder: (ctx, products, child) => IconButton(
                icon: child,
                onPressed: () {
                  products.removeProduct(product.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
