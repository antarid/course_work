import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class Auth with ChangeNotifier {
  static const sharedPrefsKey = 'authData';
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(sharedPrefsKey)) return false;

    final extractedAuthData =
        json.decode(prefs.getString(sharedPrefsKey)) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedAuthData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) return false;
    _token = extractedAuthData['token'];
    _userId = extractedAuthData['userId'];
    _expiryDate = expiryDate;
    _autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> authenticate(
    String email,
    String password,
    AuthMode authMode,
  ) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:${authMode == AuthMode.Signup ? 'signUp' : 'signInWithPassword'}?key=AIzaSyB3rxwQ2hbaXwvLgVZWZUYA1v05AxsSxtQ';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final authData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString(sharedPrefsKey, authData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(sharedPrefsKey);
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
