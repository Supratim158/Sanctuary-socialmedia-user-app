import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sanctuary/core/themes.dart';
import 'package:sanctuary/services/encryption_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverProfile;

  const ChatDetailsScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfile,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatPlugin.chatService;
  final String _listenerId = 'chat_screen_page';

  bool _isLoading = true;
  bool _isTyping = false;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;

  final Map<String, String> _decryptedCache = {};

  void _decryptMessages(List<ChatMessage> messages) {
    for (final message in messages) {
      if (EncryptionService.isEncrypted(message.message)) {
        if (!_decryptedCache.containsKey(message.messageId)) {
          if (_decryptedCache.containsKey(message.message)) {
            _decryptedCache[message.messageId] =
            _decryptedCache[message.message]!;
          } else {
            _decryptedCache[message.messageId] = '🔒 Decrypting...';

            EncryptionService.decryptMessage(
              message.message,
              widget.receiverId,
            ).then((decrypted) {
              if (mounted) {
                setState(() {
                  _decryptedCache[message.messageId] = decrypted;
                });
              }
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _registerEventListeners();
    _initChat();

    _controller.addListener(_onTextChanged);
  }

  void _registerEventListeners() {
    _chatService.addEventListener(
      ChatEventType.messagesChanged,
      '$_listenerId-messages',
          (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );

    _chatService.addEventListener(
      ChatEventType.typingStatusChanged,
      '$_listenerId-typing',
          (isTyping) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    _chatService.addEventListener(
      ChatEventType.onlineStatusChanged,
      '$_listenerId-online',
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    _chatService.addEventListener(
      ChatEventType.messageStatusChanged,
      '$_listenerId-status',
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    _chatService.addEventListener(
      ChatEventType.error,
      '$_listenerId-error',
          (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      },
    );
  }

  void _removeEventListeners() {
    _chatService.removeEventListener(
      ChatEventType.messagesChanged,
      '$_listenerId-messages',
    );

    _chatService.removeEventListener(
      ChatEventType.typingStatusChanged,
      '$_listenerId-typing',
    );

    _chatService.removeEventListener(
      ChatEventType.onlineStatusChanged,
      '$_listenerId-online',
    );

    _chatService.removeEventListener(
      ChatEventType.messageStatusChanged,
      '$_listenerId-status',
    );

    _chatService.removeEventListener(
      ChatEventType.error,
      '$_listenerId-error',
    );
  }

  Future<void> _initChat() async {
    setState(() {
      _isLoading = true;
      _hasMoreMessages = true;
    });

    try {
      await EncryptionService.prefetchKeys(widget.receiverId);

      await _chatService.initChat(widget.receiverId);

      _chatService.updateUserStatus(true);

      _chatService.emitCustomEvent(
        'get_user_status',
        {'userId': widget.receiverId},
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTextChanged() {
    bool isCurrentlyTyping = _controller.text.isNotEmpty;

    if (_isTyping != isCurrentlyTyping) {
      _isTyping = isCurrentlyTyping;
      _chatService.sendTypingIndicator(_isTyping);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chatService.updateUserStatus(true);
    } else if (state == AppLifecycleState.paused) {
      _chatService.updateUserStatus(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _removeEventListeners();

    _controller.removeListener(_onTextChanged);

    _controller.dispose();
    _scrollController.dispose();

    _chatService.leaveChat(widget.receiverId);

    super.dispose();
  }

  List<ChatMessage> _getSortedMessages() {
    final messages = List<ChatMessage>.from(_chatService.messages);

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return messages;
  }

  @override
  Widget build(BuildContext context) {
    final sortedMessages = _getSortedMessages();

    final reversedMessages = sortedMessages.reversed.toList();

    _decryptMessages(reversedMessages);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          ),

          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.receiverProfile != null &&
                    widget.receiverProfile!.isNotEmpty
                    ? Image.network(
                  widget.receiverProfile!,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultAvatar(),
                )
                    : _buildDefaultAvatar(),
              ),

              const SizedBox(width: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  _buildUserStatus(),
                ],
              ),
            ],
          ),

          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.white,
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            if (_chatService.isReceiverTyping)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${widget.receiverName} is typing...",
                  style: TextStyle(
                    color: DefaultColors.greyText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                  color: Colors.white,
                ),
              )
                  : reversedMessages.isEmpty
                  ? ListView(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 5.0,
                        ),
                        child: Text(
                          "Messages are end-to-end encrypted. Only people in this chat can read the message.",
                          style: TextStyle(
                            color: CupertinoColors.systemOrange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      "No messages yet.\nSend a message to start the conversation",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
                  : NotificationListener<ScrollNotification>(
                onNotification:
                    (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent -
                          50 &&
                      !_isLoadingMore &&
                      _hasMoreMessages) {
                    _loadMoreMessages();
                  }

                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  itemCount: reversedMessages.length +
                      1 +
                      (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {

                    // Encryption banner
                    if (index == reversedMessages.length) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 5.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Padding(
                            padding:
                            EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 5.0,
                            ),
                            child: Text(
                              "Messages are end-to-end encrypted. Only people in this chat can read the message.",
                              style: TextStyle(
                                color:
                                CupertinoColors.systemOrange,
                              ),
                              textAlign:
                              TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }

                    // Loading indicator
                    if (_isLoadingMore &&
                        index ==
                            reversedMessages.length + 1) {
                      return Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CupertinoActivityIndicator(
                            radius: 10,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }

                    final message =
                    reversedMessages[index];

                    final isMe = message.isMine;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding:
                        const EdgeInsets.all(10.0),
                        margin:
                        const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueGrey
                              : Colors.grey[600],
                          borderRadius: isMe
                              ? const BorderRadius.only(
                            bottomLeft:
                            Radius.circular(10),
                            topLeft:
                            Radius.circular(10),
                            topRight:
                            Radius.circular(10),
                            bottomRight:
                            Radius.circular(2),
                          )
                              : const BorderRadius.only(
                            bottomLeft:
                            Radius.circular(2),
                            topLeft:
                            Radius.circular(10),
                            topRight:
                            Radius.circular(10),
                            bottomRight:
                            Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _decryptedCache[
                              message.messageId] ??
                                  message.message,
                            ),

                            const SizedBox(height: 2),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.end,
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Text(
                                  MessageFormatter
                                      .formatTimestamp(
                                    message.createdAt
                                        .toLocal(),
                                  ),
                                  style:
                                  const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                if (isMe)
                                  _buildMessageStatus(
                                    message.status,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Message",
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatus(String status) {
    switch (status) {
      case 'sent':
        return const Icon(
          Icons.check,
          color: Colors.grey,
          size: 14,
        );

      case 'delivered':
        return Row(
          children: [
            const Icon(
              Icons.check,
              color: Colors.grey,
              size: 14,
            ),

            Transform.translate(
              offset: const Offset(-9, 0),
              child: const Icon(
                Icons.check,
                color: Colors.grey,
                size: 14,
              ),
            ),
          ],
        );

      case 'read':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check,
              color: Colors.blue,
              size: 14,
            ),

            Transform.translate(
              offset: const Offset(-4, 0),
              child: const Icon(
                Icons.check,
                color: Colors.blue,
                size: 14,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_chatService.messages.isEmpty ||
        _isLoadingMore ||
        !_hasMoreMessages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    int currentMessageCount = _chatService.messages.length;

    int nextPage = (currentMessageCount / 20).ceil() + 1;

    try {
      final newMessages =
      await _chatService.loadMoreMessages(
        page: nextPage,
      );

      if (newMessages.isEmpty) {
        _hasMoreMessages = false;
      }
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    _controller.clear();

    try {
      final encryptedText =
      await EncryptionService.encryptMessage(
        text,
        widget.receiverId,
      );

      _decryptedCache[encryptedText] = text;

      await _chatService.sendMessage(encryptedText);

      if (_scrollController.hasClients &&
          _scrollController.position.pixels > 0) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send message: $e',
          ),
        ),
      );
    }
  }

  Widget _buildUserStatus() {
    if (_chatService.isReceiverOnline) {
      return const Text(
        "Online",
        style: TextStyle(
          fontSize: 12,
          color: Colors.green,
        ),
      );
    } else if (_chatService.lastSeen != null) {
      return Text(
        'Last Seen ${MessageFormatter.timeAgo(_chatService.lastSeen!)}',
        style: TextStyle(
          fontSize: 12,
          color: DefaultColors.greyText,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDefaultAvatar() {
    return Image.network(
      "https://res.cloudinary.com/dwv7t8jvx/image/upload/v1775310076/jjtdhbxyqc6cgw6qkalx.jpg",
      height: 40,
      width: 40,
      fit: BoxFit.cover,
    );
  }
}