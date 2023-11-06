import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rewild/core/utils/resource_change_notifier.dart';

class InternetConnectionCheckerImpl implements InternetConnectionChecker {
  const InternetConnectionCheckerImpl();
  @override
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Internet connection is available
    } else {
      return false; // No internet connection
    }
  }
}
