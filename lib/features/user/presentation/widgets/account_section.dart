// lib/widgets/accountWidgets/account_section.dart
import 'package:flutter/material.dart';

class AccountSection extends StatelessWidget {
  final String title;

  const AccountSection({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 13, 27, 42),
          fontSize: 18,
          fontFamily: 'Custom',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}