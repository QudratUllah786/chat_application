import 'package:flutter/material.dart';

import '../theme/style.dart';
class TextFieldContainer extends StatelessWidget {
  final TextEditingController ?controller;
  final TextInputType ?textInputType;
  final bool ?obscureText;
  final Icon ?prefixIcon;
  final Icon ?suffixIcon;
  final String? hintText;
  const TextFieldContainer({Key? key,
  this.textInputType,
    this.controller,
    this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
     this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color747480.withOpacity(.2),
      ),

      child: TextField(
        controller: controller,
             keyboardType: textInputType ?? TextInputType.text,
             obscureText: obscureText == true?true:false,
             decoration: InputDecoration(
               hintText: hintText,
               prefixIcon: prefixIcon ?? const Icon(Icons.circle),
               suffixIcon: suffixIcon,
               border: InputBorder.none
             ),
      ),


    );
  }
}
