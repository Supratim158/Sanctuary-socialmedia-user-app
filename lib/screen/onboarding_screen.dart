import 'package:flutter/material.dart';
import 'package:sanctuary/entry_page.dart';
import 'package:sanctuary/screen/authenticaton/login_screen.dart';
import 'package:sanctuary/screen/chat_details_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.35,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueAccent,
                  image: const DecorationImage(
                      image: NetworkImage("https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg"),
                    fit: BoxFit.cover,
                  )
                ),
              ), 
              SizedBox(height: 20,),
              Text("Welcome to Sanctuary.",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
              SizedBox(height: 10,),
              Text("A space for meaningful connections.",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black45),),
              SizedBox(height: 25,),
              Center(
                child: ElevatedButton(
                  onPressed: (){
                    // Navigator.pushReplacement(
                    //   context,
                    //   PageRouteBuilder(
                    //     pageBuilder: (context, animation, secondaryAnimation) => const EntryPage(),
                    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    //       return FadeTransition(opacity: animation, child: child);
                    //     },
                    //     transitionDuration: const Duration(milliseconds: 500),
                    //   ),
                    // );
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                  },
                    child: Text("Get Started"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
