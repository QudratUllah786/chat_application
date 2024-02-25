import 'package:chatapplication/model/firebase_helper.dart';
import 'package:chatapplication/model/user_model.dart';
import 'package:chatapplication/pages/homepage.dart';
import 'package:chatapplication/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

var uuid = const Uuid();


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
   UserModel? userModel= await  FirebaseHelper.getUserModelByID(user.uid);
 if(userModel != null){
   runApp(MyAppLogged(
       userModel: userModel,
       firebaseUser: user
   ));
 }
 else{
   runApp(const MyApp());
 }
      /// logged in
    }
    else{
      runApp(const MyApp());
    }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:   const LoginPage(),
    );
  }
}


class MyAppLogged extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLogged({super.key, required this.userModel, required this.firebaseUser});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:HomePage(
        firebaseUser: firebaseUser,
        userModel: userModel,
      ),
    );
  }
}

