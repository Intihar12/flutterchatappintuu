
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../allConstants/firestore_constants.dart';
import '../all_modals/user_chate.dart';

enum Status{
 uninitialized,
 authenticated,
 authenticating,
 authenticateError,
 authenticateCanceled
}

class AuthProvider extends ChangeNotifier{

  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences pref;

  Status _status=Status.uninitialized;

  Status get status=>_status;

  AuthProvider({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.googleSignIn,
    required this.pref
});
  String? getUserFirebaseId(){

    pref.getString(FirestoreConstants.id);

    print("firebaseconstantid ....... . .${ pref.getString(FirestoreConstants.id)}");

  }

  Future<bool>isLoggedIn()async{
    bool isLoggedIn=await googleSignIn.isSignedIn();

    print("islogdin.....${isLoggedIn}");
    if(isLoggedIn && pref.getString(FirestoreConstants.id)?.isNotEmpty ==true){
    return true;
  }
  else{
    return false;
    }
}

Future <bool> handleSigIn()async{
    _status= Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser=await googleSignIn.signIn();
    if(googleUser != null){
      GoogleSignInAuthentication? googleAuth= await googleUser.authentication;
      final AuthCredential credential= GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );
      User? firebaseuser=(await firebaseAuth.signInWithCredential(credential)).user;
      if(firebaseFirestore != null){
        final QuerySnapshot result= await firebaseFirestore.collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id,isEqualTo: firebaseuser!.uid)
        .get();
        
        final List<DocumentSnapshot> document=result.docs;
        
        if(document.length ==0){
          firebaseFirestore.collection(FirestoreConstants.pathUserCollection).doc(firebaseuser.uid).set(
              {
                FirestoreConstants.nickname:firebaseuser.displayName,
                FirestoreConstants.id:firebaseuser.uid,
                FirestoreConstants.photoUrl:firebaseuser.photoURL,
                'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
                FirestoreConstants.chattingWith:null,

              });

          User? currentUser=firebaseuser;
          await pref.setString(FirestoreConstants.id, currentUser.uid);
          await pref.setString(FirestoreConstants.nickname, currentUser.displayName ?? "");
          await pref.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await pref.setString(FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        }else{
          DocumentSnapshot? documentSnapshot=document[0];
          UserChat? userChat=UserChat.fromDocument(documentSnapshot);

          await pref.setString(FirestoreConstants.id, userChat.id);
          await pref.setString(FirestoreConstants.nickname, userChat.nickname);
          await pref.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await pref.setString(FirestoreConstants.phoneNumber, userChat.phoneNumber);
          await pref.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        }
        _status=Status.authenticated;
        notifyListeners();
        return true;
      }else{
        _status=Status.authenticateError;
        notifyListeners();
        return false;
      }
    }else{
      _status=Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
}
  Future<void>handleSignOut()async{
    _status=Status.uninitialized;

    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

}