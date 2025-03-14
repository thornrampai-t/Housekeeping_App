class ChangeDuration {
  // เมธอด formatDuration สำหรับแปลง Duration เป็นข้อความ
  String formatDuration(Duration duration) {
    if (duration.inDays >= 30) {
      int months = duration.inDays ~/ 30; // คำนวณจำนวนเดือน
      return '$months เดือน';
    } else if (duration.inDays >= 1) {
      return '${duration.inDays} วัน';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} ชั่วโมง';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} นาที';
    } else {
      return '${duration.inSeconds} วินาที';
    }
  }
}