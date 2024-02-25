 import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;
  String? messageID;

  MessageModel({
    this.text,
    this.createdOn,
    this.seen,
    this.sender,
    this.messageID
 });

  MessageModel.fromMap(Map<String,dynamic> fromMap){
    sender = fromMap['sender'];
    text = fromMap['text'];
    seen = fromMap['seen'];
    createdOn = (fromMap['createdOn'] as Timestamp).toDate();
    messageID = fromMap['messageID'];
  }
  Map<String,dynamic> toMap(){
    return {
      'sender':sender,
      'text':text,
      'seen':seen,
      'createdOn':createdOn,
      'messageID':messageID,
    };
  }

 }