import 'dart:async';
import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sanctuary/core/themes.dart';
import 'package:sanctuary/screen/chat_details_screen.dart';
import 'package:sanctuary/services/auth_services.dart';
import 'package:sanctuary/services/encryption_service.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with WidgetsBindingObserver {

  final ChatService _chatService = ChatPlugin.chatService;
  final String _listenerId = 'direct_message_page';

  bool _isLoading = true;
  Timer? _refreshTimer;

  Map<String, int> _newMessageCount = {};
  final Map<String, String> _decryptedPreviews = {};

  String _getDecryptedPreview(String latestMessage, String senderId) {
    if (!EncryptionService.isEncrypted(latestMessage)) {
      return latestMessage;
    }

    if (_decryptedPreviews.containsKey(latestMessage)) {
      return _decryptedPreviews[latestMessage]!;
    }

    // Trigger decryption asynchronously
    _decryptedPreviews[latestMessage] = '🔒 Encrypted message';
    EncryptionService.decryptMessage(latestMessage, senderId).then((decrypted) {
      if (mounted) {
        setState(() {
          _decryptedPreviews[latestMessage] = decrypted;
        });
      }
    });

    return '🔒 Encrypted message';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _registerEventListeners();
    _initChatServices();
    _startPeriodicRefresh();
  }

  void _registerEventListeners() {
    _chatService.addEventListener(
      ChatEventType.chatRoomsChanged, _listenerId, (_){
        if(mounted) {
          setState(() {});
        }
    });

    _chatService.addEventListener(
      ChatEventType.custom, '${_listenerId}_notification', (data){
        if(data['eventName'] == 'new_message_notification') {
          _handleNewMessageNotification(data['data']);
        }
    });

    // Listen for connection status changes to refresh when reconnected
    _chatService.addEventListener(
      ChatEventType.connectionStatusChanged, '${_listenerId}_connection', (isConnected){
        if(mounted && isConnected == true) {
          _refreshChatRooms();
        }
    });
  }

  void _removeEventListeners() {
    _chatService.removeEventListener(ChatEventType.chatRoomsChanged, _listenerId);
    _chatService.removeEventListener(ChatEventType.custom, '${_listenerId}_notification');
    _chatService.removeEventListener(ChatEventType.connectionStatusChanged, '${_listenerId}_connection');
  }

  /// Periodically refresh chat rooms every 15 seconds for WhatsApp-like experience
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if(mounted) {
        _refreshChatRooms();
      }
    });
  }

  /// Lightweight refresh — doesn't show loading indicator
  Future<void> _refreshChatRooms() async {
    try {
      await _chatService.loadChatRooms();
      if(mounted) {
        setState(() {});
      }
    } catch(e) {
      // Silently fail on background refresh
    }
  }

  _handleNewMessageNotification(Map<String, dynamic> messageData){
    if(!mounted) return;

    final senderId = messageData['senderId'];

    if(senderId != null){
      setState(() {
        _newMessageCount[senderId] = (_newMessageCount[senderId] ?? 0) + 1;
      });
    }

    // Also refresh chat rooms to update latest message & order
    _refreshChatRooms();
  }

  Future<void> _initChatServices() async {
    try{
      setState(() {
        _isLoading = true;
      });

      if(!_chatService.isSocketConnected){
        await _chatService.initGlobalConnection();
      } else {
        // Re-register for global mode if socket is already connected
        _chatService.refreshGlobalConnection();
      }

      await _chatService.loadChatRooms();

      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    catch(er){
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      // Refresh chat rooms when app comes back to foreground
      _refreshChatRooms();
      _startPeriodicRefresh();
    } else if(state == AppLifecycleState.paused) {
      // Stop periodic refresh when app is in background
      _refreshTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeEventListeners();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final chatRooms = _chatService.chatRooms;

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(),)
          : Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 90,
              child: FutureBuilder<List<dynamic>>(
                  future: AuthServices.fetchUsers(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else if(snapshot.hasData && snapshot.data!.isNotEmpty){
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          var user = snapshot.data![index];
                          return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            child: _buildRecentContacts(
                              user['userName'],
                              user['profile'],
                                  () {
                                    _navigateToChat(
                                      user['_id'],
                                      user['userName'],
                                      user['profile'],
                                    );
                              },
                              context,
                            )
                          );
                        },
                      );
                    }
                    else{
                      return Center(child: Text("No User Found"),);
                    }
                  }
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text("CHAT ROOM",
              style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),),
          ),

          if(chatRooms.isEmpty && !_isLoading)
            Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey,),
                      const SizedBox(height: 16.0,),
                      const Text("No Conversation Yet", style: TextStyle(fontSize: 14,color: Colors.grey),),
                      const SizedBox(height: 16.0,),
                      const Text("Start a New Conversation", style: TextStyle(fontSize: 14,color: Colors.grey),),
                    ],
                  ),
                )
            ),

          if(chatRooms.isNotEmpty)
            Expanded(
                child: RefreshIndicator(
                    child: ListView.builder(
                      itemCount: chatRooms.length,
                        itemBuilder: (context, index){
                        return _buildChatRoomItem(chatRooms[index]);
                        }
                    ),
                    onRefresh: () async {
                      await _chatService.loadChatRooms();
                      if(mounted) setState(() {});
                    }
                )
            )
        ],
      )
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

  _buildChatRoomItem(ChatRoom chatRoom){
    final localCount = _newMessageCount[chatRoom.userId] ?? 0;
    final unreadCount = localCount > chatRoom.unreadCount ? localCount : chatRoom.unreadCount;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DefaultColors.greyText, width: 1.0)
        )
      ),
      child: ListTile(
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blueAccent,
            image: DecorationImage(
              image: NetworkImage(chatRoom.avatarUrl ?? "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(chatRoom.username, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
        subtitle: Text(
          MessageFormatter.formatMessagePreview(_getDecryptedPreview(chatRoom.latestMessage, chatRoom.userId)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              MessageFormatter.formatTimestamp(chatRoom.latestMessageTime.toLocal()),
              style: TextStyle(fontSize: 12, color: DefaultColors.greyText),
            ),
            if(unreadCount>0)
              Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${unreadCount}',
                  style: TextStyle(
                    color: Colors.white, fontSize: 12
                  ),
                ),
              )
          ],
        ),
        onTap: (){
          _navigateToChat(chatRoom.userId, chatRoom.username, chatRoom.avatarUrl);
        },
      ),
    );
  }

  Widget _buildRecentContacts(String name, String? image, VoidCallback onTap, BuildContext context,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueAccent,

              backgroundImage:
              image != null && image.isNotEmpty
                  ? NetworkImage(image)
                  : null,

              child:
              image == null || image.isEmpty
                  ? Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),

            const SizedBox(height: 8),

            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(String userId, String username, String? receiverProfile){
    setState(() {
      _newMessageCount.remove(userId);
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatDetailsScreen(
                  receiverId: userId,
                  receiverName: username,
                  receiverProfile: receiverProfile,
                ),
        ),
    ).then((_){
      // Refresh chat rooms when returning from chat details
      _refreshChatRooms();
    });
  }
}
