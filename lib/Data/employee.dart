class Employee {
  String employeeId; // รหัสพนักงาน
  String name; // ชื่อพนักงาน
  String phoneNumber; // หมายเลขโทรศัพท์
  String email; // อีเมล
  String position; // ตำแหน่งงาน
  String department; 
  String password; 
  String photo; 
  String typeacc; // typeacc = employee
  DateTime hireDate; // วันที่เริ่มงาน
  double salary; // เงินเดือน defalut = 0
  bool isActive; // สถานะการทำงาน (active หรือไม่)

  Employee({
    required this.employeeId,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.position,
    required this.department,
    required this.password,
    required this.photo,
    required this.typeacc,
    required this.hireDate,
    required this.salary,
    required this.isActive,
  });
}