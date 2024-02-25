class UserModel{
  String? uid;
  String? fullName;
  String? email;
  String? profilePicture;

  UserModel({this.uid, this.email, this.fullName, this.profilePicture});

  UserModel.fromMap(Map<String,dynamic> map){
    uid = map['uid'];
    fullName = map['fullName'];
    email = map['email'];
    profilePicture = map['profilePicture'];


  }

 Map<String,dynamic> toMap(){
   return {
     "uid":uid,
     "fullName":fullName,
     "email":email,
     "profilePicture":profilePicture,
   };

 }
}