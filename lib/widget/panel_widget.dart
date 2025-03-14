import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/Data/marker_data.dart';
import 'package:project/function/map.dart';
import 'package:project/page/user/detailbooking.dart';

class PanelWidget extends StatefulWidget {
  final List<MarkerData> markers; // รายการสถานที่ที่บันทึกไว้
  String? selectedPosition; // สถานที่ที่ถูกเลือกในปัจจุบัน
  final void Function(String, LatLng) onSelectLocation;

  PanelWidget({
    super.key,
    required this.markers,
    this.selectedPosition,
    required this.onSelectLocation,
  });

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  int? selectedIndex;
  String? selectedAddress;

  // ฟังก์ชันเพื่อตรวจสอบตำแหน่งที่เลือกสุดท้าย
  String? get finalSelectedAddress {
    if (widget.selectedPosition != null) {
      return widget.selectedPosition; // ใช้ตำแหน่งจากการปักหมุด
    }
    return selectedAddress; // ใช้ที่อยู่จากการเลือก radio
  }

  // เอาไว้ รีซีต สี radio เมื่อเปลี่ยนไปเลือกตน.บน
  @override
  void didUpdateWidget(covariant PanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPosition != null &&
        widget.selectedPosition != oldWidget.selectedPosition) {
      // รีเซ็ตค่าการเลือก Radio หากเปลี่ยนตำแหน่งจากแผนที่
      setState(() {
        selectedIndex = null;
        selectedAddress = widget.selectedPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDragHandle(),
              const SizedBox(height: 5),
              const Text(
                'ตำแหน่งที่บันทึก:',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.markers.length,
                  itemBuilder: (context, index) {
                    final marker = widget.markers[index];
                    return FutureBuilder<String>(
                      future: GeocodingService.getAddressFromLatLng(
                        marker.position.latitude,
                        marker.position.longitude,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'ไม่สามารถแปลงที่อยู่ได้: ${snapshot.error}',
                          );
                        }
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: Radio<int>(
                              value: index,
                              activeColor: Colors.green[700],
                              groupValue: selectedIndex,
                              onChanged: (int? value) {
                                setState(() {
                                  selectedIndex = value;
                                  final marker = widget.markers[value ?? 0];
                                  selectedAddress =
                                      snapshot.data ?? "ไม่พบข้อมูลที่อยู่";
                                  widget.onSelectLocation(
                                    selectedAddress ?? "",
                                    marker.position,
                                  );
                                });
                              },
                            ),
                            title: Text(
                              marker.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'ที่อยู่: ${snapshot.data ?? "ไม่พบข้อมูลที่อยู่"}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: ElevatedButton(
            onPressed: () {
              final address = finalSelectedAddress;
              print('ที่อยู่ที่เลือก: $address');
              if (address != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailBookingPage(address: address),
                  ),
                );
              } else {
                // ถ้ายังไม่ได้เลือกที่อยู่
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('กรุณาเลือกตำแหน่ง')));
              }
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Icon(
              Icons.navigate_next_sharp,
              size: 35,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDragHandle() => Center(
    child: Container(
      width: 36,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
