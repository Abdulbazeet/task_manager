import 'package:flutter/material.dart';

Widget textField({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
  required bool obscureText,
  required TextEditingController controller,
  Widget? suffixIcon,
  void Function(String)? onChanged,
  Key? key,
}) {
  return Column(
    crossAxisAlignment: .start,
    children: [
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: .bold, fontSize: 12),
      ),
      SizedBox(height: 5),
      TextField(
        key: key,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.black),
        obscureText: obscureText,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          hintText: hint,
          suffixIcon: suffixIcon,
          hintStyle: Theme.of(context).textTheme.bodySmall,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 0, color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 0, color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 0, color: Colors.transparent),
          ),
        ),
      ),
      SizedBox(height: 30),
    ],
  );
}
