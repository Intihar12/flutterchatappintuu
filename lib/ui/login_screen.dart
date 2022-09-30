import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

import '../allConstants/color_constants.dart';
import '../allWidgets/loading_view.dart';
import '../all_providers/auth_providers.dart';
import 'home_screen.dart';


class LoggedIn extends StatefulWidget {

  const LoggedIn({Key? key}) : super(key: key);

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {

  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider= context.read<AuthProvider>();
    switch(authProvider.status){
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sing in failed");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in Cancled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:break;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset("images/back.png"),

        ),
          SizedBox(height: 20,),

           Padding(
            padding: EdgeInsets.only(left: 20.0,right: 20),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration:  const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:ColorConstants.greyColor2)
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorConstants.primaryColor)
                ),
                hintText: "Email",
                contentPadding: EdgeInsets.all(5),
                hintStyle: TextStyle(color: ColorConstants.greyColor),

              ),
            ),
          ),
          SizedBox(height: 10,),

          TextField(
            controller: passwordController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color:ColorConstants.greyColor2)
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.primaryColor)
              ),
              hintText: "password",
              contentPadding: EdgeInsets.all(5),
              hintStyle: TextStyle(color: ColorConstants.greyColor),

            ),
          ),
          SizedBox(height: 10,),

          ElevatedButton(onPressed: (){}, child: const Text("Login")),
          const SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(onTap: ()async{


              bool isSuccess= await authProvider.handleSigIn();

              if(isSuccess){

                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
                // });

             //   Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context)=>Home()) , (Route<dynamic>route) => false);

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));

              }

            },
            child: Image.asset("images/google_login.jpg"),
            ),
          ),
          Center(child: authProvider.status==Status.authenticating ? LoadingView() :SizedBox.shrink())
      ],),
    );
  }
}
