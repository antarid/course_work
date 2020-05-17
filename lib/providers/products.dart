import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items;
  final String _authToken;
  final String _userId;

  Products(this._authToken, this._userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String productId) =>
      _items.firstWhere((product) => product.id == productId);

  Future<void> removeProduct(String id) async {
    final url =
        'https://udemy-flutter-66e60.firebaseio.com/products/${id}.json?auth=$_authToken';
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    } else
      existingProduct = null;
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final url =
        'https://udemy-flutter-66e60.firebaseio.com/products.json?auth=$_authToken${filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : ""}';
    try {
      final response = await http.get(url);
      final responseObject = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> fetchedProducts = [];
      if (responseObject != null) {
        final favouritesUrl =
            'https://udemy-flutter-66e60.firebaseio.com/userFavourites/$_userId.json?auth=$_authToken';
        final favouritesResponse = await http.get(favouritesUrl);
        final favouritesData =
            json.decode(favouritesResponse.body) as Map<String, dynamic>;
        responseObject.forEach((productId, product) {
          fetchedProducts.add(Product(
            id: productId,
            description: product['description'],
            title: product['title'],
            imageUrl: product['imageUrl'],
            price: product['price'],
            isFavourite: favouritesData == null
                ? false
                : favouritesData[productId] ?? false,
          ));
        });
      }

      _items = fetchedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateOrAddProduct(Product product) async {
    if (product.id != null) {
      final url =
          'https://udemy-flutter-66e60.firebaseio.com/products/${product.id}.json?auth=$_authToken';
      await http.patch(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          },
        ),
      );
      int index = _items.indexWhere((item) => item.id == product.id);
      _items[index] = product;
      notifyListeners();
    } else
      try {
        final url =
            'https://udemy-flutter-66e60.firebaseio.com/products.json?auth=$_authToken';
        final response = await http.post(
          url,
          body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
              'creatorId': _userId,
            },
          ),
        );
        _items.add(Product(
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          title: product.title,
          id: json.decode(response.body)['name'],
        ));
        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
  }
}
