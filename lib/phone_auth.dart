import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'homepage.dart';
class LoginPage extends StatefulWidget {


  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String phoneNo, smssent, verificationId;

  Future<void> verifyPhone() async{
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId){
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]){
      this.verificationId = verId;
      smsCodeDialoge(context).then((value){
        print('Code Sent');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth){};
    final PhoneVerificationFailed verifyFailed = (AuthException e) {
      print('${e.message}');
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }
  Future<bool> smsCodeDialoge(BuildContext context){
    return showDialog(context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('Provide OTP'),
          content: TextField(
            onChanged: (value)  {
              this.smssent  = value;
            },
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
           // debugShowCheckedModeBanner: false,
            new FlatButton(
                onPressed: (){
                  FirebaseAuth.instance.currentUser().then((user){
                    if(user != null){
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dash()),
                      );

                    }
                    else{
                      Navigator.of(context).pop();
                      signIn(smssent);
                    }

                  }
                  );
                },
                child: Text('Done', style: TextStyle( color: Colors.blue),))
          ],
        );
      },
    );
  }

  Future<void> signIn(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await FirebaseAuth.instance.signInWithCredential(credential)
        .then((user){
      Navigator.of(context).pushReplacementNamed('/loginpage');
    }).catchError((e){
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
          title: Center(child: Text('Phone Login'))
      ),
      body:ListView(
       // mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[

          Text(
            "enter phone number",
            style: TextStyle(
                color: Colors.pink,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(

                hintText: '+91(10 digit phone no)',

              ),

              onChanged: (value){
                this.phoneNo = value;
              },
            ),
          ),

          SizedBox(height: 10.0),
          getImageAsset(),
          Text(
            "your number should be +91 ie country code and ********** which will be your 10 digit phone number",
            style: TextStyle(
                color: Colors.purple,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
         // SizedBox(height: 10.0),


          SizedBox(height: 10.0),
          FlatButton(
            onPressed: verifyPhone,
            child: Text('Verify', style: TextStyle(color: Colors.white),),
            //elevation: 7.0,
            color: Colors.blue,

          )
        ],
      ),
    );
  }
}

Widget getImageAsset() {
  AssetImage assetImage = AssetImage('images/phone calling.jfif');
  Image image = Image(
    image: assetImage,
    width: 125.0,
    height: 125.0,
  );
  return Container(
    child: image,
    margin: EdgeInsets.all( 50.0),
  );
}

