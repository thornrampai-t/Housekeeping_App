import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionManagementPage extends StatefulWidget {
  const PromotionManagementPage({super.key});

  @override
  State<PromotionManagementPage> createState() =>
      _PromotionManagementPageState();
}

class _PromotionManagementPageState extends State<PromotionManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedPromotionType = "Fixed";

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showPromotionDialog({
    String? promoId,
    String? title,
    String? discount,
    String? startDate,
    String? endDate,
    String? promotionType,
  }) {
    final TextEditingController titleController = TextEditingController(
      text: title ?? "",
    );
    final TextEditingController startDateController = TextEditingController(
      text: startDate ?? "",
    );
    final TextEditingController endDateController = TextEditingController(
      text: endDate ?? "",
    );
    final TextEditingController discountController = TextEditingController(
      text: discount ?? "",
    );
    String? selectedPromotionType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(promoId == null ? "เพิ่มโปรโมชั่น" : "แก้ไขโปรโมชั่น"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "ชื่อโปรโมชั่น"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: discountController,
                  decoration: const InputDecoration(labelText: "จำนวน"),
                ),
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "วันที่เริ่ม",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDate(context, startDateController),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "วันที่สิ้นสุด",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDate(context, endDateController),
                ),
                const SizedBox(height: 8),
                // เพิ่ม DropdownButton สำหรับเลือกประเภทโปรโมชั่น
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Set the border radius here
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedPromotionType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPromotionType = newValue;
                      });
                    },
                    items:
                        <String>[
                          'Fixed',
                          'Percent',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    decoration: const InputDecoration(
                      labelText: "ประเภทโปรโมชั่น",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    startDateController.text.isNotEmpty &&
                    endDateController.text.isNotEmpty) {
                  // แปลงวันที่ startDate และ endDate เป็น DateTime
                  DateTime startDateTime = DateFormat(
                    "d/M/yyyy",
                  ).parse(startDateController.text);
                  DateTime endDateTime = DateFormat(
                    "d/M/yyyy",
                  ).parse(endDateController.text);

                  Timestamp startTimestamp = Timestamp.fromDate(startDateTime);
                  Timestamp endTimestamp = Timestamp.fromDate(endDateTime);

                  if (promoId == null) {
                    await _firestore.collection("Promotions").add({
                      'title': titleController.text,
                      'discount': discountController.text,
                      'startDate': startTimestamp,
                      'endDate': endTimestamp,
                      'promotionType': selectedPromotionType,
                    });
                  } else {
                    await _firestore
                        .collection("Promotions")
                        .doc(promoId)
                        .update({
                          'title': titleController.text,
                          'discount': discountController.text,
                          'startDate': startTimestamp,
                          'endDate': endTimestamp,
                          'promotionType': selectedPromotionType,
                        });
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(promoId == null ? "เพิ่ม" : "บันทึก"),
            ),
          ],
        );
      },
    );
  }

  void _deletePromotion(String promoId) async {
    await _firestore.collection("Promotions").doc(promoId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "จัดการโปรโมชั่น",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("Promotions").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("ยังไม่มีโปรโมชั่น"));
                  }

                  final promotions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: promotions.length,
                    itemBuilder: (context, index) {
                      final promo = promotions[index];
                      final promoData = promo.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            promoData['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "วันที่ ${_formatDate(promoData['startDate'])} - ${_formatDate(promoData['endDate'])}",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed:
                                    () => _showPromotionDialog(
                                      promoId: promo.id,
                                      title: promoData['title'],
                                      startDate: promoData['startDate'],
                                      endDate: promoData['endDate'],
                                      promotionType: promoData['promotionType'],
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deletePromotion(promo.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showPromotionDialog(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "เพิ่มโปรโมชั่น",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 70),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      // Convert the Timestamp to DateTime
      DateTime dateTime = date.toDate();
      return DateFormat(
        'dd/MM/yyyy',
      ).format(dateTime); // Custom format: Day/Month/Year
    } else if (date is String) {
      // If the date is already a String, just return it
      return date;
    } else {
      // If the date is of another type or null, return a default value
      return 'Invalid date';
    }
  }
}
