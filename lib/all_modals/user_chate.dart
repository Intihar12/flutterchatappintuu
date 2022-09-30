import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../allConstants/firestore_constants.dart';

class UserChat{

  String id;
  String nickname;
  String photoUrl;
  String aboutMe;
  String phoneNumber;

  UserChat({required this.id, required this.nickname,required this.aboutMe,required this.phoneNumber,required this.photoUrl});

  Map<String ,String>toJson(){
    return{
      FirestoreConstants.nickname:nickname,
      FirestoreConstants.photoUrl:photoUrl,
      FirestoreConstants.aboutMe:aboutMe,
      FirestoreConstants.phoneNumber:phoneNumber
    };
  }
  factory UserChat.fromDocument(DocumentSnapshot doc){
String aboutMe="";
String nickname="";
String photoUrl="";
String phoneNumber="";

try{
  aboutMe=doc.get(FirestoreConstants.aboutMe);
}catch(e){}

try{
  aboutMe=doc.get(FirestoreConstants.nickname);
}catch(e){}

try{
  aboutMe=doc.get(FirestoreConstants.phoneNumber);
}catch(e){}

try{
  aboutMe=doc.get(FirestoreConstants.photoUrl);
}catch(e){}

return UserChat(id: doc.id, nickname: nickname, aboutMe: aboutMe, phoneNumber: phoneNumber, photoUrl: photoUrl);

  }

}