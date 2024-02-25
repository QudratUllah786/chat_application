import 'dart:developer';

import 'package:chatapplication/model/ui_helper.dart';
import 'package:chatapplication/model/user_model.dart';
import 'package:chatapplication/pages/homepage.dart';
import 'package:chatapplication/pages/sign_up_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../global/common/common.dart';
import '../global/custom_text_field/textfield_container.dart';
import '../global/string/string.dart';
import '../global/theme/style.dart';
import '../global/widget/custom_button.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
   _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(Strings.login,style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.green
            ),),
            const Divider(),

            const SizedBox(height: 10,),
            TextFieldContainer(
              controller: _emailController,
              hintText: Strings.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 20,),
            TextFieldContainer(
              controller: _passwordController,
              hintText: Strings.password,
              prefixIcon: const Icon(Icons.lock_outline),
              obscureText: true,
            ),

            InkWell(
              onTap: (){
            //    Navigator.of(context).pushNamed(PageConst.forgotPage );
              },
              child: const Align
                (
                alignment: Alignment.topRight,
                child: Text(
                  Strings.forgotPassword, style: TextStyle(
                  color: greenColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                ),
              ),
            ),

            const SizedBox(height: 20,),

            CustomButton(
              onTap: () async {
               await _submitLogin(context);
              },
              title: Strings.login,
            ),
            const SizedBox(height: 20,),

            Row(
              children: [
                const Text(Strings.dontAccount,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ), ),
                const SizedBox(width: 5,),
                InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpScreen()));
                     /* Navigator.pushNamedAndRemoveUntil(context,
                          PageConst.registrationPage, (route) => false);*/
                    },
                    child: const Text(Strings.register,style: TextStyle(
                      color: greenColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ), )),
              ],
            ),

            const SizedBox(height: 10,),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 50,
                height: 50,
                decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.2),
                          offset: const Offset(1.0, 1.0),
                          spreadRadius: 1,
                          blurRadius: 1
                      )
                    ]

                ),

                child: const Icon(FontAwesomeIcons.google,color: Colors.white,),
              ),
            )



          ],
        ),
      ),
    );
  }


  Future<void> _submitLogin(BuildContext context) async {
    if(_emailController.text.isEmpty){
      toast('please enter email');
      return;
    }
    if(!_emailController.text.contains('@')){
      toast('please enter valid email');
      return;
    }
    if(_passwordController.text.isEmpty){
      toast('please enter password');
      return;
    }
    if(_passwordController.text.length <7){
      toast('please enter password more than 7 digits');
      return;
    }
    else{
     await login(_emailController.text.trim(), _passwordController.text.trim());
     _emailController.clear();
     _passwordController.clear();

    }

  }

  Future<void> login(String email, String password) async{

    UserCredential? credential;
    UIHelper.showLoadingDialog(context, 'Logging In ...');

    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
    }on FirebaseAuthException catch(e){
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, 'Error', e.message.toString());
      log(e.message.toString());
  //    toast(e.code.toString());
    }
    if(credential != null){
     String uid = credential.user!.uid;

     DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
     UserModel userModel = UserModel.fromMap(snapshot.data() as Map<String,dynamic>);
     Navigator.pop(context);
     toast('login successfully');
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
     return  HomePage(userModel: userModel, firebaseUser: credential!.user!);
     }));
    }





}


}
