import 'package:chatapplication/global/theme/style.dart';
import 'package:chatapplication/model/chat_room_model.dart';
import 'package:chatapplication/model/firebase_helper.dart';
import 'package:chatapplication/model/user_model.dart';
import 'package:chatapplication/pages/chatroom_page.dart';
import 'package:chatapplication/pages/login_page.dart';
import 'package:chatapplication/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('chat',style: TextStyle(color: Colors.white),),
      actions: [
        IconButton(onPressed: () async{
          await FirebaseAuth.instance.signOut();
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context){
            return const LoginPage();
          }));

        }, icon: const Icon(Icons.logout))
      ],
      centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){

        Navigator.push(context, MaterialPageRoute(builder: (context){
          return SearchScreen(userModel: userModel, firebaseUser: firebaseUser);
        }));

      },
      backgroundColor: primaryColor,child: const Icon(Icons.search,color: textIconColor),
      ),
      body: StreamBuilder(stream: FirebaseFirestore.instance.
      collection('chatrooms').where('users',arrayContains: userModel.uid).orderBy('onCreated',descending: true).snapshots(),
          builder:(context,snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          if(snapshot.hasData){
            QuerySnapshot data = snapshot.data as QuerySnapshot;
            return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (context,index){
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      data.docs[index].data() as Map<String,dynamic>);
                    Map<String,dynamic> participants = chatRoomModel.participants!;
                    List<String> participantsKeys = participants.keys.toList();
                    participantsKeys.remove(userModel.uid);

              return FutureBuilder(future: FirebaseHelper.getUserModelByID(participantsKeys[0]),
                  builder: (context,userData){
                   if(userData.connectionState == ConnectionState.done){
                     if(userData.data != null){
                       UserModel targetUser = userData.data as UserModel;
                       return ListTile(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context){
                             return ChatRoomPage(
                                 targetUser: targetUser,
                                 chatRoom:chatRoomModel,
                                 userModel: userModel,
                                 firebaseUser: firebaseUser
                             );
                           }));
                         },
                       leading: CircleAvatar(
                         backgroundImage: NetworkImage(
                           targetUser.profilePicture.toString()
                         ),
                       ),
                         title: Text(targetUser.fullName.toString()),
                         subtitle:chatRoomModel.lastMessage.toString().isNotEmpty? Text(chatRoomModel.lastMessage.toString()): const Text('Say hi to your new friend',style: TextStyle(color: greenColor),),
                       );
                     }
                     else{
                       return const Text('Noting to show');
                     }
                   }
                   else{
                     return const Center(
                       child: CircularProgressIndicator(),
                     );
                   }
                  });
            });
          }else if(snapshot.hasError){
            return Text(snapshot.hasError.toString());
          }
          else{
            return Container();
          }
        }else{
          return Container();
        }
      }),

    );
  }
}
