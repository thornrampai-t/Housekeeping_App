import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingService {
  // ฟังก์ชันแปลงพิกัด (latitude, longitude) เป็นที่อยู่
  static Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    const String apiKey = 'AIzaSyAtiVZyXeDK7CGXAbooOJojX4jBZEMHPIw'; // ใส่ API Key ของคุณที่นี่
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final address = data['results'][0]['formatted_address'];
        return address ?? 'ไม่พบข้อมูลที่อยู่';
      } else {
        return 'ไม่พบที่อยู่';
      }
    } else {
      return 'ไม่สามารถแปลงที่อยู่ได้';
    }
  }

  
  
}