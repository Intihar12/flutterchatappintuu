import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../allConstants/color_constants.dart';
import '../all_providers/auth_providers.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds:  5),(){
      checkSignedIn();
    });

  }

  void checkSignedIn()async{
    AuthProvider authProvider= context.read<AuthProvider>();

  bool isLoggedIn=await authProvider.isLoggedIn();
  if(isLoggedIn ){
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
    // });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));

  }else{
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoggedIn()));
  }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          Image.asset("images/splash.png", width: 300,height: 300,),
          SizedBox(height: 20,),

          Text("World largest private chat app",style: TextStyle(color: ColorConstants.themeColor),),
          SizedBox(height: 20,),

          Container(
            width: 20,
            height: 20,

            child: CircularProgressIndicator(color: ColorConstants.themeColor,),
          )

        ],),
      ),
    );
  }
}
