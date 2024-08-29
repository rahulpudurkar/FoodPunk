import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:food_delivery_app/models/user_model.dart';
import 'package:food_delivery_app/resourese/auth_methods.dart';
import 'package:food_delivery_app/resourese/firebase_helper.dart';
import 'package:food_delivery_app/screens/homepage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:split_view/split_view.dart';
import '../utils/universal_variables.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseHelper firebaseHelper = new FirebaseHelper();
  late UserModel userModel;
  bool loading = false;
  @override
  void initState() {
    setState(() {
      loading=true;
    });
    retrieveUserData();
    super.initState();
  }

  Future<void> retrieveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    Map<dynamic, dynamic> userData = await firebaseHelper.getUserData(user!.uid);
    setState(() {
     userModel = new UserModel.fromMap(userData);
      textNameController.text = userData['name'];
      textEmailController.text  = userData['email'];
      textPhoneController.text = userData['phone'];
      textAddressController.text = userData['address'];
      // _photoUrl = userData['photoUrl'];
      loading = false;
    });
  }

  TextEditingController textNameController = TextEditingController();
  TextEditingController textAddressController = TextEditingController();
  TextEditingController textPhoneController = TextEditingController();
  TextEditingController textEmailController = TextEditingController();

  late XFile? file;
  bool uploading=false;

  captureImageWithCamera(BuildContext context) async{
    Navigator.pop(context);
    XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.camera,maxHeight: 680,maxWidth: 970);
    setState(() {
      this.file = imageFile!;
      compressImagePhoto();
      controlUploadSave();
    });
  }

  imageFromGarlley(BuildContext context) async{
    Navigator.pop(context);
    XFile? imageFile =await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = imageFile!;
      compressImagePhoto();
      controlUploadSave();
    });
  }

  takeImage(mContext){
    return showDialog(
      context: mContext,
      builder:(context){
        return SimpleDialog(
          title: Text("New Profile Image",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Capture Image with Camera",style: TextStyle(color: Colors.black),),
              onPressed: null,
            ),
            SimpleDialogOption(
              child: Text("Image From Garlley",style: TextStyle(color: Colors.black),),
              onPressed: imageFromGarlley(mContext),
            ),
            SimpleDialogOption(
              child: Text("Cancel",style: TextStyle(color: Colors.black),),
              onPressed:()=> Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  compressImagePhoto() async{
    final directory=await getTemporaryDirectory();
    final  path=directory.path;
    XFile? compressfile = await FlutterImageCompress.compressAndGetFile(
      file!.path, '$path/img_${userModel.uid}.jpg',
      quality: 88,
    );
    setState(() {
      file = compressfile!;
    });
  }

  controlUploadSave()async{
    setState(() {
      uploading=true;
    });
    // await compressImagePhoto();
    String? downloadUri=await uploadFileToStorage(file!);

    updatePhotoUrl(userModel.uid, downloadUri!);


    setState(() {
      file=null;
      uploading=false;
    });
  }

  Future<void> updatePhotoUrl(String userId, String newPhotoUrl) async {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('Users').child(userId);

      await userRef.update({'photoUrl': newPhotoUrl});
      print('Photo URL updated successfully');
    } catch (e) {
      print('Error updating photo URL: $e');
      // Handle error as needed
    }
  }


  Future<String?> uploadFileToStorage(XFile xfile) async {
    try {
      String fileName = basename(xfile.path);

      Reference storageReference =
      FirebaseStorage.instance.ref().child('images/${userModel.uid}');

      UploadTask uploadTask = storageReference.putFile(File(xfile.path));

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      setState(() {
       userModel.photoUrl = downloadURL;
      });
      return downloadURL;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Future<void> updateInfo(BuildContext context)  async {
    UserModel newUserModel = UserModel(
      uid: userModel.uid,
      email: userModel.email,
      photoUrl: userModel.photoUrl,
      address: textAddressController.text,
      name: textNameController.text,
      phone: textPhoneController.text,
    );

    try {
      await FirebaseDatabase.instance.ref()
          .child("Users")
          .child(newUserModel.uid)
          .set(newUserModel.toMap(newUserModel));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      ScaffoldMessenger.of(context!).showSnackBar( SnackBar(
        content: Text('User Info Updated'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo logic if needed
          },
        ),
      ),);
    } catch (error) {
      print("Error updating user info: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body:
      loading ? CircularProgressIndicator() :
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (_userData.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Center(
                        child: GestureDetector(
                          onTap: ()=> takeImage(context),
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(userModel.photoUrl),
                          ),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (name) {
                          },
                          controller: textNameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (email) {
                            // return registerPageBloc.validateEmail(email ?? '');
                          },
                          controller: textEmailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (phone) {
                            // return registerPageBloc.validateEmail(email ?? '');
                          },
                          controller: textPhoneController,
                          decoration: InputDecoration(
                            labelText: "Phone",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (address) {
                            // return registerPageBloc.validateEmail(email ?? '');
                          },
                          controller: textAddressController,
                          decoration: InputDecoration(
                            labelText: "Address",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.14,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(UniversalVariables.orangeColor),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                          ),
                          onPressed: () => {
                            updateInfo(context)
                          },
                          child: Text(
                            "Update Info",
                            style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: UniversalVariables.whiteColor),
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              // if (_userData.isEmpty)
              //   Center(
              //     child: CircularProgressIndicator(),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}

