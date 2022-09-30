
import 'package:flutter/material.dart';
import 'package:flutterchatapp/ui/settings_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:provider/provider.dart';

import '../allConstants/color_constants.dart';
import '../all_modals/popup_choices.dart';
import '../all_providers/auth_providers.dart';
import '../main.dart';
import 'login_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final GoogleSignIn googleSignIn= GoogleSignIn();
  final ScrollController listScrollController=ScrollController();

  int _limit=20;
  int _limitIncrement=20;
  String _textSearch="";
  bool isLoadind=false;


  late String currentUserId;
  late AuthProvider authProvider;

  List<PopupChoices> choices=<PopupChoices>[

    PopupChoices(title: "Settings", icon: Icons.settings),
    PopupChoices(title: "Sign out", icon: Icons.exit_to_app)
  ];

  Future<void>handleSignOut()async{
    authProvider.handleSignOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoggedIn()));

  }

  void scrollLitener(){
    if(listScrollController.offset >=listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange){
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onItemMenuPress( PopupChoices choice){
    if(choice.title == "Sign out"){
      handleSignOut();

    }else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const SettingsPage()));
    }

  }


  Widget buildPopupMenu(){
    return PopupMenuButton<PopupChoices>(
      icon: const Icon(Icons.more_vert,color: Colors.green,),
        onSelected: onItemMenuPress,
        itemBuilder: (BuildContext context){

          return choices.map((PopupChoices choice){

            return PopupMenuItem<PopupChoices>(
              value: choice,
                child: Row(
                  children: [
                    Icon(choice.icon,
                    color: ColorConstants.primaryColor,),

                    Container(
                      width: 10,
                    ),
                    Text(
                      choice.title,style: const TextStyle(color: ColorConstants.primaryColor),
                    )
                  ],
                )

            );
          }).toList();
        }

    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    authProvider=context.read<AuthProvider>();
    if(authProvider.getUserFirebaseId()?.isNotEmpty ==true){
      currentUserId=authProvider.getUserFirebaseId()!;

      print("Current user id .....fgfg......  ${authProvider.getUserFirebaseId}");
      print("Current user id ...........  ${currentUserId}");

    }else{
// WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
//       });
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>LoggedIn()) , (Route<dynamic>route) => false);
    }
    listScrollController.addListener(scrollLitener);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        leading:  IconButton(
          icon: Switch(
            value: isWhite,
            onChanged: (value){
              setState(() {
                isWhite=value;


              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.grey,
inactiveThumbColor: Colors.black45,
          inactiveTrackColor: Colors.grey,),
          onPressed: ()=>"",
        ),
        actions: [
          buildPopupMenu()
        ],
      ),
    );
  }
}
