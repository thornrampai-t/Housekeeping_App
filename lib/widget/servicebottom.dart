import 'package:flutter/material.dart';
import 'package:project/page/Customer/servicetype.dart';

Widget serviceButton(BuildContext context,String label, String assetPath) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServicePage(selectPosition: label),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            // backgroundColor: Colors.green[300],
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Image.asset(assetPath, width: 45, height: 35),
        ),
        SizedBox(height: 5),
        Text(label,style: Theme.of(context).textTheme.titleMedium?.copyWith(
          
        ),),
      ],
    );
  }