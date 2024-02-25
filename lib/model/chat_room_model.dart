
class ChatRoomModel{
  String? chatRoomID;
  Map<String,dynamic>? participants;
  String? lastMessage;
  DateTime? onCreated;
  List<dynamic>? users;

  ChatRoomModel({this.chatRoomID,this.participants,this.lastMessage,this.onCreated,this.users});

  ChatRoomModel.fromMap(Map<String,dynamic> fromMap){
    chatRoomID = fromMap['chatRoomID'];
    participants= fromMap['participants'];
    lastMessage = fromMap['lastMessage'];
    onCreated = fromMap['onCreated'].toDate();
    users = fromMap['users'];
  }

  Map<String,dynamic> toMap(){
    return {
      "chatRoomID":chatRoomID,
      "participants":participants,
      "lastMessage":lastMessage,
      "onCreated":onCreated,
      "users":users,

    };
  }

}