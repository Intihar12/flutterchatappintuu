import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/allConstants/app_constants.dart';
import 'package:flutterchatapp/allConstants/color_constants.dart';
import 'package:flutterchatapp/allConstants/constants.dart';
import 'package:flutterchatapp/allWidgets/loading_view.dart';
import 'package:flutterchatapp/all_modals/user_chate.dart';
import 'package:flutterchatapp/all_providers/setting_providers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        iconTheme: const IconThemeData(color: ColorConstants.primaryColor),
        title: const Text(
          AppConstants.settingsTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: SettingsPageState(),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({Key? key}) : super(key: key);

  @override
  _SettingsPageStateState createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {
  TextEditingController controllerNickName=TextEditingController();
  TextEditingController controllerAboutMe=TextEditingController();

  String? dialCodeDigit = "+00";

  final TextEditingController _controller = TextEditingController();

  String? id = "";
  String? nickName = "";
  String? aboutMe = "";
  String? photoUrl = "";
  String? phoneNumber = "";

  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode focusedNodeNickname = FocusNode();
  final FocusNode focusedNodeAboutMe = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPrefs(FirestoreConstants.id) ?? "";
      nickName = settingProvider.getPrefs(FirestoreConstants.nickname) ?? "";
      aboutMe = settingProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";
      photoUrl = settingProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
      phoneNumber =
          settingProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
    });

    controllerNickName = TextEditingController(text: nickName);
    controllerAboutMe = TextEditingController(text: aboutMe);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker
        .getImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id!;

    UploadTask uploadTask =
        settingProvider.uploadFile(avatarImageFile!, fileName);

    try {
      TaskSnapshot snapshot = await uploadTask;

      photoUrl = await snapshot.ref.getDownloadURL();

      UserChat updateInfo = UserChat(
          id: id.toString(),
          nickname: nickName.toString(),
          aboutMe: aboutMe.toString(),
          phoneNumber: phoneNumber.toString(),
          photoUrl: photoUrl.toString());
      settingProvider
          .updateDataFireStore(
              FirestoreConstants.pathUserCollection, id!, updateInfo.toJson())
          .then((data) async {
        settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl!);
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
    ;
  }

  void handleUploadData() {
    focusedNodeNickname.unfocus();
    focusedNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;

      if (dialCodeDigit != "+00" && _controller.text != "") {
        phoneNumber = (dialCodeDigit! + _controller.text.toString());
      }
    });
    UserChat updateInfo = UserChat(
        id: id.toString(),
        nickname: nickName!,
        aboutMe: aboutMe.toString(),
        phoneNumber: phoneNumber.toString(),
        photoUrl: photoUrl.toString());
    settingProvider
        .updateDataFireStore(
            FirestoreConstants.pathUserCollection, id!, updateInfo.toJson())
        .then((data) async {
      await settingProvider.setPref(FirestoreConstants.nickname, nickName!);
      await settingProvider.setPref(FirestoreConstants.aboutMe, aboutMe!);
      await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl!);
      await settingProvider.setPref(
          FirestoreConstants.phoneNumber, phoneNumber!);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Update Success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CupertinoButton(
                    onPressed: getImage,
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: avatarImageFile == null
                          ? photoUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(45),
                                  child: Image.network(photoUrl!,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90, errorBuilder:
                                          (context, object, stackTrack) {
                                    return const Icon(
                                      Icons.account_circle,
                                      size: 90,
                                      color: ColorConstants.greyColor,
                                    );
                                  }, loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 90,
                                      height: 90,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.grey,
                                          value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null &&
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              : const Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: ColorConstants.greyColor,
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.file(
                                avatarImageFile!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                      child:  const Text(
                        "Name",
                        style: TextStyle(
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30,right: 30),
                      child:  Theme(
                        data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                        child:  TextField(

                          style: const TextStyle(color: Colors.grey),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:ColorConstants.greyColor2)
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConstants.primaryColor)
                            ),
                            hintText: "whrite your name..",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: ColorConstants.greyColor),

                          ),
                       controller: controllerNickName,
                          onChanged: (value){
                            nickName=value;
                          },
                          focusNode: focusedNodeNickname,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: const Text("About me",style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor
                      ),),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 30,right: 30),
                      child:  Theme(
                        data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                        child:  TextField(

                          style:  TextStyle(color: Colors.grey),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color:ColorConstants.greyColor2)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: ColorConstants.primaryColor)
                            ),
                            hintText: "whrite something about yourself..",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: ColorConstants.greyColor),

                          ),
                          controller: controllerAboutMe,
                          onChanged: (value){
                            aboutMe=value;
                          },
                          focusNode: focusedNodeAboutMe,
                        ),
                      ),
                    ),


                    Container(
                      margin: EdgeInsets.only(left: 10,right: 10,bottom: 5),
                      child: const Text("phone num",style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor
                      ),),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 30,right: 30),
                      child:  Theme(
                        data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                        child:  TextField(
enabled: false,
                          style:  TextStyle(color: Colors.grey),
                          decoration:  InputDecoration(

                            hintText: phoneNumber,
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: Colors.grey),

                          ),

                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 30,right: 30,bottom: 5),
                      child: SizedBox(
                        width: 400,
                        height: 60,

                        child: CountryCodePicker(
                          onChanged: (country){
                            setState(() {
                              dialCodeDigit =country.dialCode!;
                            });
                          },
                          initialSelection: "IT",
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          favorite: ["+1" ,"US", "+92","PK"],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30,right: 30),

                      child:  TextField(

                        style: const TextStyle(color: Colors.grey),
                        decoration:  InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color:ColorConstants.greyColor2)
                          ),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConstants.primaryColor)
                          ),
                          hintText: "phone number",
                       //   contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: ColorConstants.greyColor),
prefix: Padding(
  padding: EdgeInsets.all(4.0),
  child:   Text(dialCodeDigit!,style: TextStyle(color: Colors.grey),),
)
                        ),
                      maxLength: 12,
                      controller: _controller,
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 50,bottom: 50),

                      child: TextButton(
                        onPressed: handleUploadData,
                        child: const Text("Update",style: TextStyle(fontSize: 19,color: Colors.white),

                        ),style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.primaryColor),
                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.fromLTRB(30, 10, 30, 10))
                      ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(child: isLoading ? LoadingView() : SizedBox.shrink())
      ],
    );
  }
}
