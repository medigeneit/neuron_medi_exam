import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkUtils {
  // Check if the device is connected to the internet
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Device is connected to mobile data or Wi-Fi
    }
    return false; // No internet connection
  }

  // Show a snackbar message if there is no internet connection
  static void showNoInternetMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection. Please check your network.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}