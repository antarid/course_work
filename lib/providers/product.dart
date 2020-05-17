import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String authToken, String userId) async {
    final url =
        'https://udemy-flutter-66e60.firebaseio.com/userFavourites/$userId/$id.json?auth=$authToken';
    isFavourite = !isFavourite;
    notifyListeners();
    final response = await http.put(url,
        body: json.encode(
          isFavourite,
        ));

    if (response.statusCode >= 400) {
      isFavourite = !isFavourite;
      notifyListeners();
    }
  }
}
