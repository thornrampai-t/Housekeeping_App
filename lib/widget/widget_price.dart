import 'package:flutter/material.dart';

class SelectableContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableContainer({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 5),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black)),
            ),
            SizedBox(height: 6),

          ],
        ),
      ),
    );
  }
}
