import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData?  prefixIcon;
  final bool obscureText;
  final Function(String)? onSaved;
  final Function(String)? validator;
  bool? isEditCommunity = false;

  CustomTextFormField({
    Key? key,
    required this.controller,
    this.validator,
    required this.hintText,
    this.prefixIcon,
    required this.onSaved,
    this.isEditCommunity,
    this.obscureText = false,
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
          maxLines: obscureText ? 1 : null,
          controller: controller,
          obscureText: obscureText,
          keyboardType: controller == '_PrizePoolController' ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon),
            contentPadding: const EdgeInsets.only(left: 10, right: 10),
            filled: true,
            fillColor: const Color.fromRGBO(36, 36, 36, 1),
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(112, 112, 112, 1),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: (value) {
            if (validator != null) {
              String? validationResponse = validator!(value!);
              if(isEditCommunity == true){
                return validationResponse;
              }
              return value!.isEmpty ? 'Please enter some text' : validationResponse;
            }
            return value!.isEmpty ? 'Please enter some text' : null;
          },
          onSaved: (newValue) {
            onSaved!(newValue!);
          },
        ),
      ),
    );
  }
}