import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/provider/authProvider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? employeeId;

  @override
  void initState() {
    super.initState();
    _debugCheckFirestoreData();
  }

  void _debugCheckFirestoreData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    var snapshot = await firestore.collection('Booking').limit(5).get();
    for (var doc in snapshot.docs) {
      print("📌 Data: ${doc.data()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    employeeId = Provider.of<idAllAccountProvider>(context).uid;
    print("employeeId: $employeeId");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Earning", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildEarningsSection(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 1, 1),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.all,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
      
        todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Color(0xFF196231), shape: BoxShape.circle),
        weekendTextStyle: const TextStyle(color: Colors.red),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.redAccent),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = DateUtils.dateOnly(selectedDay);
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildEarningsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _selectedDay != null
                ? "รายได้รวม วันที่: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}"
                : "กรุณาเลือกวัน",
            style:  GoogleFonts.notoSansThai(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FutureBuilder<double>(
              future: (_selectedDay != null && employeeId != null)
                  ? _fetchTotalEarnings(_selectedDay, employeeId)
                  : Future.value(0.0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("❌ Error: ${snapshot.error}");
                  return const Text("เกิดข้อผิดพลาดในการโหลดข้อมูล");
                }
                return Text(
                  "${snapshot.data} บาท",
                  style:  Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<double> _fetchTotalEarnings(DateTime? selectedDate, String? employeeId) async {
    if (selectedDate == null || employeeId == null) {
      print("⚠️ selectedDate หรือ employeeId เป็น null");
      return 0.0;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime startOfDay = DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay = DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    print("📅 Query (UTC): $startTimestamp - $endTimestamp");

    QuerySnapshot querySnapshot = await firestore
        .collection('Employee')
        .doc(employeeId)
        .collection('Booking')
        .where('selectedDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('selectedDate', isLessThanOrEqualTo: endTimestamp)
        .where('status', isEqualTo: 'เสร็จสิ้น')
        .get();

    print("🔎 พบ ${querySnapshot.docs.length} รายการ");

    double totalEarnings = 0;
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double finalPrice = (data['finalPrice'] as num?)?.toDouble() ?? 0.0;
      totalEarnings += finalPrice;
    }

    print("📊 รายได้รวม: $totalEarnings บาท");
    return totalEarnings;
  }
}