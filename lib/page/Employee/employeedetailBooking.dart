import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project/function/map.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service/firestore.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class EmployeeDetailBooking extends StatefulWidget {
  final String customerId;
  final String bookingId;
  final String address;

  const EmployeeDetailBooking({
    super.key,
    required this.customerId,
    required this.bookingId,
    required this.address,
  });

  @override
  State<EmployeeDetailBooking> createState() => _EmployeeDetailBookingState();
}

class _EmployeeDetailBookingState extends State<EmployeeDetailBooking> {
  FirestoreService firestoreService = FirestoreService();
  GoogleMapController? mapController;

  LatLng? position; // ใช้ `null` ได้
  List<File>? _imagesBefore;
  List<File>? _imagesAfter;
  String? _fileName;
  bool _isLoading = false; // ใช้เพื่อแสดงสถานะการโหลดข้อมูล
  final ImagePicker _picker = ImagePicker();
  List<String> _imageUrlsBefore = []; // ตัวแป
  List<String> _imageUrlsAfter = []; // ตัวแป

  @override
  void initState() {
    super.initState();
    fetchLatLng();
  }

  Future<void> fetchLatLng() async {
    final data = await GeocodingService.convertAddressToLatLng(widget.address);
    if (data != null) {
      double latValue = data['latitude'] ?? 0.0;
      double longValue = data['longitude'] ?? 0.0;
      print(latValue);
      setState(() {
        position = LatLng(latValue, longValue);
      });

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(position!));
      }
    }
  }

  Map<String, dynamic> getBookingDetails(double price) {
    String hours = '';
    String size = '';

    // ตรวจสอบราคาและแสดงข้อมูลที่เหลือ
    if (price == 500.0) {
      hours = '2 ชั่วโมง';
      size = 'สูงสุด 35m² หรือ 2 ห้อง';
    } else if (price == 750.0) {
      hours = '3 ชั่วโมง';
      size = 'สูงสุด 35-55m² หรือ 3 ห้อง';
    } else if (price == 950.0) {
      hours = '4 ชั่วโมง';
      size = 'สูงสุด 55-100m² หรือ 4 ห้อง';
    }

    // คืนค่าเป็น Map ที่ประกอบด้วยข้อมูลที่เหลือ
    return {'price': price, 'hours': hours, 'size': size};
  }

  // ฟังก์ชันเลือกภาพจากโทรศัพท์
  Future<void> _pickImagesBefore() async {
    final List<XFile>? pictures = await _picker.pickMultiImage();
    if (pictures != null && pictures.isNotEmpty) {
      List<File> imageFiles = [];
      for (var picture in pictures) {
        imageFiles.add(File(picture.path));
        print("File size: ${File(picture.path).lengthSync()} bytes");
      }

      setState(() {
        _imagesBefore = imageFiles;
        _isLoading = true; // กำหนดสถานะเป็นกำลังโหลดเมื่อเริ่มการอัปโหลด
      });
    }
  }

  Future<void> _pickImagesAfter() async {
    final List<XFile>? pictures = await _picker.pickMultiImage();
    if (pictures != null && pictures.isNotEmpty) {
      List<File> imageFiles = [];
      for (var picture in pictures) {
        imageFiles.add(File(picture.path));
        print("File size: ${File(picture.path).lengthSync()} bytes");
      }

      setState(() {
        _imagesAfter = imageFiles;
        _isLoading = true; // กำหนดสถานะเป็นกำลังโหลดเมื่อเริ่มการอัปโหลด
      });
    }
  }

  Future<void> _uploadImagesToFirebase(
    BuildContext context,
    String employeeId,
    List<File> imageBeforeFiles,
    List<File> imageAfterFiles,
    String bookingId,
  ) async {
    try {
      List<String> downloadUrlsBefore = [];
      List<String> downloadUrlsAfter = [];

      // อัปโหลด imageBefore
      for (int i = 0; i < imageBeforeFiles.length; i++) {
        String fileExtension = path.extension(
          imageBeforeFiles[i].path,
        ); // ดึงนามสกุลไฟล์เดิม
        String fileNameBefore =
            'before_${i}$fileExtension'; // ใช้นามสกุลไฟล์ต้นฉบับ
        String filePathBefore = 'employee/$bookingId/$fileNameBefore';
        print('Uploading file to path: $filePathBefore');

        Reference storageRef = FirebaseStorage.instance.ref().child(
          filePathBefore,
        );
        await storageRef.putFile(imageBeforeFiles[i]);

        String downloadUrl = await storageRef.getDownloadURL();
        downloadUrlsBefore.add(downloadUrl);
      }

      // อัปโหลด imageAfter
      for (int i = 0; i < imageAfterFiles.length; i++) {
        String fileExtension = path.extension(
          imageAfterFiles[i].path,
        ); // ดึงนามสกุลไฟล์เดิม
        String fileNameAfter =
            'after_${i}$fileExtension'; // ใช้นามสกุลไฟล์ต้นฉบับ
        String filePathAfter = 'employee/$bookingId/$fileNameAfter';
        print('Uploading file to path: $filePathAfter');

        Reference storageRef = FirebaseStorage.instance.ref().child(
          filePathAfter,
        );
        await storageRef.putFile(imageAfterFiles[i]);

        String downloadUrl = await storageRef.getDownloadURL();
        downloadUrlsAfter.add(downloadUrl);
      }

      // อัปเดต Firestore
      await FirebaseFirestore.instance
          .collection('Employee')
          .doc(employeeId)
          .collection('Booking')
          .doc(bookingId)
          .set({
            'confirmPhotoBefore': downloadUrlsBefore,
            'confirmPhotoAfter': downloadUrlsAfter,
            'status': 'เสร็จสิ้น', // หรือค่าที่ต้องการ
          }, SetOptions(merge: true));
      Navigator.pop(context);

      setState(() {
        _imageUrlsBefore = downloadUrlsBefore;
        _imageUrlsAfter = downloadUrlsAfter;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error uploading images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = Provider.of<idAllAccountProvider>(context).uid;
    return Scaffold(
      appBar: AppBar( backgroundColor: Theme.of(context).appBarTheme.backgroundColor,),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 15),
            child: Text(
              'รายละเอียด',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: StreamBuilder<String>(
                  stream: firestoreService.getUserNameStream(
                    widget.customerId,
                  ), // Call the function with the docId
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while waiting for data
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData) {
                      return Text('ไม่พบข้อมูล'); // If no data is found
                    }

                    // If data is found, display the username
                    return Text(
                      'คุณ ${snapshot.data}',
                      style: GoogleFonts.notoSansThai(fontSize: 16),
                    );
                  },
                ),
              ),

              StreamBuilder<String>(
                stream: firestoreService.getUserPhoneNumStream(
                  widget.customerId,
                ), // Call the function with the docId
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading indicator while waiting for data
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return Text('ไม่พบข้อมูล'); // If no data is found
                  }

                  // If data is found, display the username
                  return Text(
                    ', เบอร์ติดต่อ ${snapshot.data}',
                    style: GoogleFonts.notoSansThai(fontSize: 16),
                  );
                },
              ),
            ],
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getBookingDetailsStream(
              employeeId,
              widget.bookingId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                ); // แสดง Loading ขณะรอข้อมูล
              }

              if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('ไม่พบข้อมูลการจอง'));
              }

              // ถ้ามีข้อมูล
              var bookingData = snapshot.data!.data() as Map<String, dynamic>;

              var selectedDate = bookingData['selectedDate'];
              if (selectedDate is Timestamp) {
                selectedDate = selectedDate.toDate();
              }

              // เปลี่ยน format ของวันที่
              String formattedDate = DateFormat(
                'EEE, dd MMM yyyy h:mm a',
              ).format(selectedDate);
              var detail = bookingData['detail'];
              var finalPrice = bookingData['finalPrice'];
              var bookingDetails = getBookingDetails(finalPrice);
              var detailsroom =
                  "${bookingDetails['hours']},${bookingDetails['size']}";
              return Padding(
                padding: const EdgeInsets.only(left: 14, right: 4, top: 3),
                child: Text(
                  'วันที่$formattedDate,ขนาดที่จอง$detailsroom,ราคา$finalPrice',
                style: GoogleFonts.notoSansThai(fontSize: 16),),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              height: 180,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      position ??
                      LatLng(13.736717, 100.523186), // ค่าเริ่มต้น (Bangkok)
                  zoom: 15,
                ),
                markers:
                    position != null
                        ? {
                          Marker(
                            markerId: MarkerId("selected_location"),
                            position: position!,
                          ),
                        }
                        : {},
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 15),
            child: Text(
              'หมายเหตุ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SizedBox(height: 3),
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getBookingDetailsStream(
              employeeId,
              widget.bookingId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                ); // แสดง Loading ขณะรอข้อมูล
              }

              if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('ไม่พบข้อมูลการจอง'));
              }

              // ถ้ามีข้อมูล
              var bookingData = snapshot.data!.data() as Map<String, dynamic>;

              var detail = bookingData['detail'];

              return Padding(
                padding: const EdgeInsets.only(left: 14, right: 4, top: 3),
                child: Text(detail,style: GoogleFonts.notoSansThai(fontSize: 16),)
              );
            },
          ),
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 15),
            child: Text(
              'Before',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pickImagesBefore(); // เมื่อคลิกที่ Container ให้เลือกภาพ
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, top: 2),
                  child: Container(
                    width: 80, // กำหนดขนาดของ Container
                    height: 80,
                    decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20), // กรอบมน
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ), // ขอบของกรอบ
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // กรอบมนที่รูปภาพ
                        child: Image.asset(
                          'assets/images/add-image.png',
                          fit: BoxFit.cover, // ให้รูปปรับขนาดตามพื้นที่
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10), // ช่องว่างระหว่าง Container และรูปที่เลือก
              _imagesBefore != null && _imagesBefore!.isNotEmpty
                  ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _imagesBefore!.map((imageFile) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    imageFile,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  )
                  : Container(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 15),
            child: Text(
              'After',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pickImagesAfter(); // เมื่อคลิกที่ Container ให้เลือกภาพ
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, top: 2),
                  child: Container(
                    width: 80, // กำหนดขนาดของ Container
                    height: 80,
                    decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20), // กรอบมน
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ), // ขอบของกรอบ
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // กรอบมนที่รูปภาพ
                        child: Image.asset(
                          'assets/images/add-image.png',
                          fit: BoxFit.cover, // ให้รูปปรับขนาดตามพื้นที่
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10), // ช่องว่างระหว่าง Container และรูปที่เลือก
              _imagesAfter != null && _imagesAfter!.isNotEmpty
                  ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // เลื่อนในแนวนอน
                      child: Row(
                        children:
                            _imagesAfter!.map((imageFile) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    imageFile,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  )
                  : Container(), // หากไม่มีรูปภาพให้แสดงอะไร
            ],
          ),
          SizedBox(height: 5),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(320, 50),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: () async {
                if (_imagesBefore != null &&
                    _imagesBefore!.isNotEmpty &&
                    _imagesAfter != null &&
                    _imagesAfter!.isNotEmpty) {
                  setState(() {
                    _isLoading = true; // ตั้งค่าสถานะการโหลด
                  });

                  try {
                    // เรียกใช้ฟังก์ชันอัปโหลดภาพ
                    await _uploadImagesToFirebase(
                      context,
                      employeeId, // รับค่า employeeId จาก provider หรือสถานะที่มีอยู่
                      _imagesBefore!, // ภาพก่อน
                      _imagesAfter!, // ภาพหลัง
                      widget.bookingId, // ใช้ bookingId จาก widget
                    );
                  } catch (e) {
                    setState(() {
                      _isLoading = false; // ถ้ามีข้อผิดพลาดให้ปิดสถานะการโหลด
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เกิดข้อผิดพลาดในการอัปโหลดภาพ: $e'),
                      ),
                    );
                  }
                } else {
                  // ถ้าไม่มีภาพทั้งก่อนและหลัง
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('กรุณาเลือกภาพก่อนและหลังเพื่อบันทึก'),
                    ),
                  );
                }
              },
              child: Text(
                'เสร็จสิน',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
