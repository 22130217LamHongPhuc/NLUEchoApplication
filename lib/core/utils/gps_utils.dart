import 'dart:math';

class GPSUtils {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // Trả về đơn vị Mét
  }

  static bool isWithinRange(double distance) {
    return distance <= 20.0; // Khoảng cách 20m theo yêu cầu dự án
  }
}