import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  // Vérifie si le téléphone est connecté à internet
  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // Ecoute les changements de connexion en temps réel
  static Stream<bool> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged.map(
          (result) => result != ConnectivityResult.none,
        );
  }
}
