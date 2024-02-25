import 'dart:developer';

import 'package:chatapplication/model/user_model.dart';
import 'package:chatapplication/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/common/common.dart';
import '../global/custom_text_field/textfield_container.dart';
import '../global/string/string.dart';
import '../global/theme/style.dart';
import '../global/widget/custom_button.dart';
import '../model/ui_helper.dart';


class SignUpScreen extends StatelessWidget {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _againPasswordController = TextEditingController();

  SignUpScreen({Key? key}) : super(key: key);

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyWidget(context),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              Strings.signUp,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            TextFieldContainer(
              controller: _userNameController,
              hintText: Strings.userName,
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldContainer(
              controller: _emailController,
              hintText: Strings.email,
              prefixIcon: const Icon(Icons.mail),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.5,
                  child: const Divider()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFieldContainer(
              controller: _passwordController,
              hintText: Strings.password,
              prefixIcon: const Icon(Icons.lock),
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFieldContainer(
              controller: _againPasswordController,
              hintText: Strings.passwordAgain,
              prefixIcon: const Icon(Icons.lock),
              obscureText: true,
            ),
            InkWell(
              onTap: () {
                //    Navigator.of(context).pushNamed(PageConst.forgotPage);
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: Text(
                  Strings.forgotPassword,
                  style: TextStyle(
                    color: greenColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButton(
              onTap: () {
                submitSignUp(context);
              },
              title: Strings.register,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text(
                  Strings.doAccount,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      /*          Navigator.pushNamedAndRemoveUntil(
                          context, PageConst.loginPage, (route) => false);*/
                    },
                    child: const Text(
                      Strings.login,
                      style: TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Strings.byClick,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorC1C1C1),
                ),
                Text(
                  Strings.privacy,
                  style: TextStyle(
                      color: greenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Strings.and,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorC1C1C1),
                ),
                Text(
                  Strings.terms,
                  style: TextStyle(
                      color: greenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  Strings.ofUse,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorC1C1C1),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> submitSignUp(BuildContext context) async {
    if (_userNameController.text.isEmpty) {
      toast('enter username');
      return;
    }
    if (_emailController.text.isEmpty) {
      toast('enter email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      toast('enter password');
      return;
    }
    if (_passwordController.text != _againPasswordController.text) {
      toast('password not match');
      return;
    }

   await signup(_emailController.text.trim(), _passwordController.text.trim(),context);



  }

  /// signup method/function

  Future<void> signup(String email, String password,BuildContext context) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, 'Sign Up ...');
    try{
    credential =  await  FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password);
    } on FirebaseAuthException catch (e){
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, 'Error',e.message.toString());
     // toast(e.code.toString());
    }
    if(credential != null){
      String uid = credential.user!.uid;
      UserModel userModel = UserModel(
        uid: uid,
        email: email,
        fullName: "",
        profilePicture: ""
      );
 await  FirebaseFirestore.instance.collection('users').doc(uid).set(
     userModel.toMap()
   ).then((value) {
     log('new user created');
     Navigator.popUntil(context, (route) => route.isFirst);
     Navigator.pushReplacement(context , MaterialPageRoute(builder: (context){
       return ProfilePage(userModel: userModel, firebaseUser: credential!.user!);
     }));
   });
    }
  }
}