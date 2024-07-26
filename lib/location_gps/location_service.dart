import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra nếu dịch vụ vị trí đã được bật
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Dịch vụ vị trí không được bật, yêu cầu người dùng bật nó
      throw Exception('Dịch vụ vị trí bị tắt');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Quyền truy cập bị từ chối vĩnh viễn, xử lý phù hợp.
      throw Exception(
          'Quyền truy cập vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu quyền.');
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  // Phương thức trả về tương lai của vị trí hiện tại
  Future<LatLng?> getCurrentPositionFuture() async {
    try {
      return await getCurrentLocation();
    } catch (e) {
      // print('Lỗi khi lấy vị trí: $e');
      return null;
    }
  }
}
