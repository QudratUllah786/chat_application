import 'dart:developer';

import 'package:chatapplication/global/widget/custom_button.dart';
import 'package:chatapplication/model/chat_room_model.dart';
import 'package:chatapplication/model/user_model.dart';
import 'package:chatapplication/pages/chatroom_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/theme/style.dart';
import '../main.dart';
class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

   const SearchScreen({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  /// function that returns chatRoomModel use to check is there any chatRoom exits of not

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async{
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('chatrooms').where('participants.${widget.userModel.uid}',isEqualTo: true).
    where('participants.${targetUser.uid}',isEqualTo: true).get();
    if(snapshot.docs.isNotEmpty){
      log('chatroom already exists');
      /// fetch existing document
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(docData as Map<String,dynamic>);
      chatRoom = existingChatRoom;
    }
    else{
      log('chatroom not created');
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomID: uuid.v1(),
        lastMessage: '',
        onCreated: DateTime.now(),
        participants: {
          widget.userModel.uid.toString():true,
          targetUser.uid.toString():true,
        },
        users: [widget.userModel.uid.toString(),targetUser.uid.toString()]
      );
      await FirebaseFirestore.instance.collection('chatrooms').doc(newChatRoom.chatRoomID).set(newChatRoom.toMap());
      log('new chatRoom created');
      chatRoom = newChatRoom;
      /// create new one
    }
    return chatRoom;
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('search',style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child:  Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Email'
              ),
              controller: searchController,
            ),
            const SizedBox(height: 40,),
            CustomButton(
              onTap: (){
                setState((){});
              },
              title: 'Search',
            ),

            /// list of all users
           StreamBuilder(
               stream: FirebaseFirestore.instance.collection('users').
               where('email', isEqualTo: searchController.text).where('email',isNotEqualTo: widget.userModel.email).snapshots(),
               builder: (context,snapshot){
             if(snapshot.connectionState == ConnectionState.active){
               if(snapshot.hasData){
                 QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;

                 if(querySnapshot.docs.isNotEmpty){
                   Map<String,dynamic> userMap = querySnapshot.docs[0].data() as Map<String,dynamic>;
                   log('image:${userMap['profilePicture'].toString()}');
                   UserModel searchedUser = UserModel.fromMap(userMap);

                   String image = searchedUser.profilePicture?? '';

                   log('image:$image');
                   log('name:${searchedUser.fullName.toString()}');
                   log('email:${searchedUser.email.toString()}');

                   return ListTile(
                     onTap: () async{
                       ChatRoomModel? chatRoomModel = await getChatRoomModel(
                         searchedUser
                       );
                       if(chatRoomModel != null){
                         Navigator.pop(context);
                       Navigator.push(context, MaterialPageRoute(
                           builder: (context)=>  ChatRoomPage(
                         targetUser: searchedUser,
                         firebaseUser: widget.firebaseUser,
                         userModel: widget.userModel,
                         chatRoom: chatRoomModel,
                       )));

                       }

                     },
                     leading: CircleAvatar(
                       backgroundImage: NetworkImage(searchedUser.profilePicture.toString()),
                     ),
                     title: Text(searchedUser.fullName.toString()),

                     subtitle: Text(searchedUser.email.toString()),
                     trailing: IconButton(onPressed: () async {
                       await getChatRoomModel(searchedUser);



                     }, icon: const Icon(Icons.navigate_next)),
                   );
                 }
                 else{
                   return const Text('No result found');
                 }

               }else if(snapshot.hasError){
                 const Text('an error occured');
               }else{
                 const Text('No results found');
               }

             }
             else {
               return const Center(
                 child: CircularProgressIndicator(),
               );
             }
             return const SizedBox();
               }),
          ],
        ),
      )
    );
  }
}
