import 'package:flutter/material.dart';
import 'package:myhealthapp/patient/ble-setupscreen.dart';

class Login extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    double width= MediaQuery.of(context).size.width*1;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(height: height*0.1,),
            SizedBox(
              width: width*0.2,
              height: height*0.1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/logo.png"),fit: BoxFit.cover)
                ),
              ),
            ),
            SizedBox(height: height*0.02,),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Email",
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                enabledBorder: OutlineInputBorder()
              ),
            ),
            SizedBox(height: height*0.01,),
            TextFormField(
              obscureText: true,
              obscuringCharacter: "*",
              decoration: InputDecoration(
                labelText: "Password",
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                enabledBorder: OutlineInputBorder()
              ),
            ),
            SizedBox(height: height*0.01,),
            SizedBox(
              width: width,
              child: Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                  onPressed: (){
                    //developmenet purpose
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BLESetupScreen(),));
                  }, child: Text("Login")),
              ),
            )
          ],
        ),
      ),
    );
  }
}