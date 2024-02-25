import 'package:chatapplication/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

  class FirebaseHelper{
  static Future<UserModel?> getUserModelByID(String id) async{
    UserModel? userModel;
   DocumentSnapshot snapshot =  await FirebaseFirestore.instance.collection('users').doc(id).get();

   if(snapshot.data() != null){
     userModel = UserModel.fromMap(snapshot.data() as Map<String,dynamic>);

   }

   return userModel;


  }
}