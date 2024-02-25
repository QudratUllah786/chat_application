import 'dart:developer';
import 'dart:io';

import 'package:chatapplication/global/common/common.dart';
import 'package:chatapplication/model/ui_helper.dart';
import 'package:chatapplication/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../global/custom_text_field/textfield_container.dart';
import '../global/string/string.dart';
import '../global/widget/custom_button.dart';
import '../model/user_model.dart';

class ProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser; /// firebase auth user

  const ProfilePage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController profileController = TextEditingController();

  File? image;

  void pickImage(ImageSource source) async{
 XFile? file =    await ImagePicker().pickImage(source: source);

 if(file != null ){
   cropImage(file);
 }


  }

  void cropImage(XFile crop)async{



    final croppedFile = await ImageCropper().cropImage(
        sourcePath: crop.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY:1),
      compressQuality: 20
    );
    if(croppedFile != null){
      setState((){
        image = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                      title: const Text('Upload Profile Picture'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Select From Gallery'),
                            leading: const Icon(Icons.image),
                            onTap: (){
                              pickImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },

                          ),
                          ListTile(
                            title: const Text('Take a Photo'),
                            leading: const Icon(Icons.camera),
                            onTap: (){
                              pickImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  backgroundImage: image != null?  FileImage(image!):null,
                  radius: 60,
                  child: image == null?
                  const Icon(Icons.person,size: 60,color: Colors.white,):null
                ),
              ),

              const SizedBox(height: 50,),

              TextFieldContainer(
                controller:profileController,
                hintText: 'Full name',
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
              ),
              const SizedBox(height: 10),

               CustomButton(
                title: Strings.signUp,
                onTap: (){
                  if(profileController.text.isEmpty || image == null){
                    toast('please provide all the data');
                    return;
                  }
                  uploadData();
                },
              )

            ],
          ),
        ),

      ),
    );
  }

  void uploadData() async{
   // final metadata = SettableMetadata(contentType: "image/jpeg");
    UIHelper.showLoadingDialog(context, 'processing ...');
    UploadTask uploadTask =  FirebaseStorage.instance
        .ref("profilePictures")
        .child(widget.userModel.uid.toString())
        .putFile(image!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL(); /// it will give us the url of image
      log('imageUrl:${imageUrl.toString()}');
    String fullName = profileController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.profilePicture = imageUrl;
   await FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).
   set(widget.userModel.toMap()).then((value) {
     Navigator.popUntil(context, (route) => route.isFirst);
     toast('data uploaded');
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
       return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
     }));
   }).onError((error, stackTrace) {
     Navigator.pop(context);
     UIHelper.showAlertDialog(context, 'Error in uploading', error.toString());
   });


  }
}
