import 'dart:developer';

import 'package:chatapplication/model/chat_room_model.dart';
import 'package:chatapplication/model/message_model.dart';
import 'package:chatapplication/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../global/theme/style.dart';
class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({super.key,
    required this.targetUser,
    required this.chatRoom,
    required this.userModel,
    required this.firebaseUser
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController msgController = TextEditingController();
  void sendMessage() async{
    String msg = msgController.text.trim();
    if(msg != ""){
      MessageModel messageModel = MessageModel(
        text: msg,
        createdOn: DateTime.now(),
        messageID: const Uuid().v1(),
        seen: false,
        sender: widget.userModel.uid
      );

      FirebaseFirestore.instance.collection('chatrooms').
      doc(widget.chatRoom.chatRoomID).collection('messages').
      doc(messageModel.messageID).set(messageModel.toMap());

      widget.chatRoom.lastMessage = msg;
      widget.chatRoom.onCreated = DateTime.now();
      FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatRoom.chatRoomID).set(widget.chatRoom.toMap());
        log(widget.chatRoom.onCreated.toString());
      // FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatRoom.chatRoomID).set(widget.chatRoom.toMap());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUser.profilePicture.toString()),
            ),
            const SizedBox(width: 10,),
            Text(widget.targetUser.fullName.toString(),style: const TextStyle(color: Colors.white),),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(stream: FirebaseFirestore.instance.collection('chatrooms').
            doc(widget.chatRoom.chatRoomID).collection('messages').orderBy('createdOn',descending: true).snapshots(),
                builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.active){
                if(snapshot.hasData){
                  QuerySnapshot dataSnap = snapshot.data as QuerySnapshot;
                  return  ListView.builder(
                    reverse: true,
                    itemCount: dataSnap.docs.length,
                    itemBuilder: (context,index){
                      MessageModel message = MessageModel.fromMap(dataSnap.docs[index].data() as Map<String,dynamic>);
                      return Row(
                        mainAxisAlignment: message.sender == widget.userModel.uid?
                        MainAxisAlignment.end:MainAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: message.sender == widget.userModel.uid?greenColor:const Color(0xff59B4C3)
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: Text(message.text.toString(),style: const TextStyle(
                                color: Colors.white
                              ),)),
                        ],
                      );

                    });
                }else if(snapshot.hasError){
                 return const Text('something went wrong');
                }else{
                 return const Text('Say something');
                }
              }
              else{
               return const Center(
                  child: CircularProgressIndicator(),
                );
              }
                }),
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[200],
            child: Row(
              children: [
                 Flexible(child: TextField(
                  controller: msgController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter message'
                  ),
                )),

                IconButton(onPressed: (){
                  sendMessage();
                  log('message send');
                  msgController.clear();
                }, icon: const Icon(Icons.send))

              ],
            ),
          )

        ],
      ),
    );
  }
}
