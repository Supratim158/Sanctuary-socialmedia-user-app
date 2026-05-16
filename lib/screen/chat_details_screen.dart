import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sanctuary/core/themes.dart';

class ChatDetailsScreen extends StatelessWidget {
  const ChatDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Text("Supratim", style: Theme.of(context).textTheme.titleMedium,)
            ],
          ),
          leading: IconButton( onPressed: () {
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios_new, color: Colors.white,),),
          actions: [
            IconButton( onPressed: () {  }, icon: Icon(CupertinoIcons.search, color: Colors.white,),)
          ],
          elevation: 0,
          toolbarHeight: 70,
        ),

        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildReceivedMessage(context, "test test"),
                  _buildSendMessage(context, "."),
                  _buildReceivedMessage(context, "test test"),
                  _buildSendMessage(context, "test test gbhjndkghbjnkvghdf hdfdfbhbhhjbfvhjubjbfvbfb hjzdfbhjbvhdbbvhbszvhjbhbdfhbhvfbhjdbhbvdhjdbvhjb"),
                ],
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
  Widget _buildReceivedMessage(BuildContext context, String message){
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 30, top: 5, bottom: 5),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(
          minWidth: 50,
          maxWidth: 300,
        ),
        decoration: BoxDecoration(
          color: DefaultColors.receiverMessage,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium,),
      ),
    );
  }

  Widget _buildSendMessage(BuildContext context, String message){
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 30, top: 5, bottom: 5),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(
          minWidth: 50,
          maxWidth: 300,
        ),
        decoration: BoxDecoration(
            color: DefaultColors.senderMessage,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium,),
      ),
    );
  }

  Widget _buildMessageInput(){
    return Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: DefaultColors.sentMessageInput
      ),
      margin: EdgeInsets.all(25),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: (){},
            child: Icon(CupertinoIcons.camera, color: Colors.grey,),
          ),

          SizedBox(width: 10,),

          Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Message",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              )
          ),

          SizedBox(width: 10,),

          GestureDetector(
            onTap: (){},
            child: Icon(Icons.send, color: Colors.grey,),
          ),
        ],
      ),
    );
  }
}
