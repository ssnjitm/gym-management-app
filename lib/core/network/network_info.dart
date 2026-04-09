import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final Connectivity connectivity;
  
  ConnectionCheckerImpl(this.connectivity);
  
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}