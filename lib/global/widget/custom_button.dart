import 'package:flutter/material.dart';

import '../theme/style.dart';
class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title;
  const CustomButton({Key? key,this.title,this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 44,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: greenColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          title!,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }
}