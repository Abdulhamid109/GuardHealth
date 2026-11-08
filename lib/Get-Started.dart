import 'package:flutter/material.dart';
import 'package:myhealthapp/patient/auth/login.dart';

class GetStartedPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    double width= MediaQuery.of(context).size.width*1;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: height*0.1,),
              SizedBox(
                width: width*0.2,
                height: height*0.1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/logo.png"))
                  ),
                ),
              ),
          
              SizedBox(height: height*0.1,),
              Text("Guard Health",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: height*0.01,),
              Text("Health precaustionary application for everyone"),
              SizedBox(height: height*0.01,),
              ElevatedButton(onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),),);
              }, child: Text("Get Started"))

          
            ],
          ),
        ),
      ),
    );
  }
}