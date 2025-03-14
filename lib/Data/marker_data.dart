import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerData {
  final LatLng position;
  final String title;

  MarkerData({required this.position, required this.title});
}

List<MarkerData> markers_list = [
  MarkerData(
    position: LatLng(13.7563, 100.5018), // พิกัดกรุงเทพฯ
    title: 'บ้านของฉัน',
  ),
  MarkerData(
    position: LatLng(13.7455, 100.5400), // พิกัดสำนักงาน
    title: 'สำนักงาน',
  ),
  MarkerData(
    position: LatLng(13.7300, 100.5100), // พิกัดร้านกาแฟ
    title: 'ร้านกาแฟโปรด',
  ),
];
