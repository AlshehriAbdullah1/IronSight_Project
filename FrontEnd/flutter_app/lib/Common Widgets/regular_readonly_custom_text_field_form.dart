import 'package:flutter/material.dart';

class ReadOnlyCustomTextFormField extends StatelessWidget {
  final String text;
  final IconData prefixIcon;

  const ReadOnlyCustomTextFormField({
    Key? key,
    required this.text,
    required this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Material(
      elevation: 10,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: screenWidth * 0.6,
        child: TextFormField(
          readOnly: true,
          initialValue: text,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon),
            contentPadding: const EdgeInsets.only(left: 10),
            filled: true,
            fillColor:const Color.fromRGBO(36, 36, 36, 1),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}