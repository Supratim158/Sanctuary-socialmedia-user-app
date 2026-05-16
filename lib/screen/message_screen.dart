import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sanctuary/core/themes.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        actions: [
          IconButton( onPressed: () {  }, icon: Icon(CupertinoIcons.search, color: Colors.white,),)
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text("Recents",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
                _buildRecentContacts("Supratim","https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",context),
              ],
            ),
          ),

          SizedBox(height: 10,),

          Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: DefaultColors.messageListPage,
                  ),
                  child: ListView(
                    children: [
                      SizedBox(height: 10,),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),
                      _buildMessageTile(
                          "Supratim",
                          "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
                          "12.45",
                          "hi hnfinignubn  hfb hfnvn hjb dfhdfhdf hjbhudbgyubbubbyubhbvhb"
                      ),

                    ],
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
  Widget _buildMessageTile(String name, String image, String time, String message){
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blueAccent,
          image: DecorationImage(
            image: NetworkImage(image,),
          fit: BoxFit.cover,
        ),
      ),
      ),
      title: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      subtitle: Text(message, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),),
      trailing: Text(time, style: TextStyle(color: Colors.grey)),
    );
  }
  Widget _buildRecentContacts(String name, String image, BuildContext context){
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(image),
          ),
          SizedBox(height: 5,),
          Text(
              name,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
}
}
