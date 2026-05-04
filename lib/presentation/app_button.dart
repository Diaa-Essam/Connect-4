import 'package:flutter/material.dart';

// My Custom Button Styling In One Place
class AppButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  AppButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.white30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
