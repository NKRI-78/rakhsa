import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/chatV2/presentation/provider/messages.dart';
import 'package:rakhsa/socket.dart';
import 'package:slide_countdown/slide_countdown.dart';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChatPagev2 extends StatefulWidget {
  const ChatPagev2({super.key, required this.ticketId});

  final int ticketId;

  @override
  State<ChatPagev2> createState() => _ChatPagev2State();
}

class _ChatPagev2State extends State<ChatPagev2> {
  late Socket? socketIo;
  late MessageProvider messageProvider;
  late bool showResolved;
  late SocketServices socketServices;

  ScrollController sC = ScrollController();

  // Controller for text input
  final TextEditingController _controller = TextEditingController();

  void getInitialMessage() async {
    try {
      String? token = await StorageHelper.getToken();
      String? idUser = await StorageHelper.getUserId();
      var response = await http.get(
      Uri.parse(
          '${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket/messages/${widget.ticketId}'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token"
      });
      print(response.body);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body)['data'];
        var messagesJson = json['messages'] as List;

        setState(() {
          sender = json['User'];
          messages = messagesJson
              .map((e) => {
                    'sender': e['sender_id'] == idUser? 'user': 'bot',
                    'message': e['message'].toString(),
                    'createdAt': "${DateTime.parse(e['created_at'].toString()).add(
                      const Duration(
                        hours: 7,
                      ),
                    )}",
                  })
              .toList();
        });
      }
      Future.delayed(const Duration(milliseconds: 300), () {
      if (sC.hasClients) {
          sC.animateTo(
            sC.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeOut, 
          );
        }
      });
    } catch (e) {
      ///
    }
  }

  // List to store the chat messages
  List<Map<String, String>> messages = [];

  // Function to send a message
  void sendMessage(String message) {
    if (message.isEmpty) return;

    socketIo?.emit('send:ticketMessage',{
      "ticket_id": widget.ticketId, 
      "message": message, 
      "sender": sender,
      "createdAt":  '${DateTime.now()}',
    });

    setState(() {
      messages.add({
        'sender': 'user', 
        'message': message,
        'createdAt': '${DateTime.now()}',
      });
    });
    _controller.clear(); // Clear the text field after sending
    Future.delayed(const Duration(milliseconds: 300), () {
      sC.animateTo(
        sC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOut, 
      );
    });
  }
  Map? sender;

  @override
  void initState() {
    super.initState();

    messageProvider = context.read<MessageProvider>();
    socketServices = context.read<SocketServices>();

    showResolved = false;

    Future.delayed(Duration.zero, () async {
      if(mounted) {
        await messageProvider.getMessage(widget.ticketId.toString());
      }
    });

    messageProvider.setStatus("");
    messageProvider.setMessage("");
    messageProvider.onChangeRating(selectedRating: 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      messageProvider.getUnread(widget.ticketId.toString());
      socketRoomInit();
      getInitialMessage();
    });
  }

  @override
  void dispose() {
    leaveRoom();
    socketIo = null;
    super.dispose();
    messageProvider.getChatsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        messageProvider.setStatus("");
        Navigator.pop(context);
      },
      child: Consumer<MessageProvider>( 
          builder: (BuildContext context, MessageProvider messageProvider, _) {
            final targetDateTime = DateTime.parse(messageProvider.chatData.updatedAt ?? DateTime.now().toString()).add(
              const Duration(
                hours: 1,
              ),
            ); 
            final duration = targetDateTime.difference(DateTime.now());
          return Scaffold(
            bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showResolved)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: ColorResources.white,
                    border: Border.all(color: ColorResources.greyLightPrimary, width: 2)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.info_outline, 
                                size: 14
                              ),
                            ),
                            TextSpan(
                              text: "Apakah sudah ditangani ?",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: fontSizeDefault
                              )
                            ),
                          ]),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // GeneralModal.ratingSos(
                                  //   context: context,
                                  //   doublePop: true,
                                  //   ticketId: widget.ticketId.toString()
                                  // );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC82927),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  "Ya",
                                  style: TextStyle(
                                    color: ColorResources.white
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                messageProvider.chatData.status == "Closed" 
                || messageProvider.status == "Closed" ? Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColorResources.greyLightPrimary,
                    border: Border.all(color: ColorResources.greyLightPrimary, width: 2)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                        TextSpan(
                          text: "${
                            messageProvider.chatData.messageClose == null ? 
                            messageProvider.message : messageProvider.chatData.messageClose
                          }",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: fontSizeDefault
                          )
                        ),
                      ]),
                    ),
                  ),
                )  : messageProvider.chatData.status == "Resolved" 
                || messageProvider.status == "Resolved" ? Container() : Container(
                  color: ColorResources.greyLightPrimary,
                  child:  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            minLines: 1,
                            maxLines: 3,
                            controller: _controller,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: ColorResources.white,
                              hintText: "ketik pesan singkat dan jelas",
                              hintStyle: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide.none
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide.none
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide.none
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xFFC82927),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: ColorResources.white,
                              size: 30,
                            ),
                            onPressed: () {
                              sendMessage(_controller.text);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            appBar: AppBar(
              backgroundColor: const Color(0xFFC82927),
              automaticallyImplyLeading: false,
              elevation: 1.0,
              title: Container(
                margin: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 20.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [  
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CupertinoButton(
                          color: Colors.transparent,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            messageProvider.setStatus("");
                            // messageProvider.setMessage("");
                            print(messageProvider.status);
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.chevron_left,
                            color: Colors.white,
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: messageProvider.chatData.staff?.profile?.photoUrl ?? '-',
                          imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                            return CircleAvatar(
                              backgroundImage: imageProvider,
                              radius: 16.0,
                            );
                          },
                          placeholder: (BuildContext context, String url) {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/default.jpg'),
                              radius: 16.0,
                            );
                          },
                          errorWidget: (BuildContext context, String url, Object error) {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/amulet-logo.png'),
                              radius: 20.0,
                              backgroundColor: const Color(0xFFC82927),
                            );
                          },
                        ),
                        
                        const SizedBox(width: 12.0),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                            Text(
                              messageProvider.chatData.staff?.profile?.fullname ?? 'User',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              messageProvider.status == "" ? messageProvider.chatData.status ?? "-" : messageProvider.status,
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    
                          ],
                        ),
            
                      ],
                    ),
            
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 5),
                  child: SlideCountdownSeparated(
                    duration:  duration,
                    onChanged: (value) {
                      print("Duration : $value");
                    },
                    onDone: () {
                      setState(() {
                        if(
                          messageProvider.chatData.status == "Resolved" 
                          || messageProvider.status == "Resolved"
                          || messageProvider.chatData.status == "Closed" 
                          || messageProvider.status == "Closed"
                        ) 
                        {
                          showResolved = false;
                        } else {
                          showResolved = true;
                        }
                      });
                    },
                  ),
                ),
                Consumer<SocketServices>(
                  builder: (BuildContext context, SocketServices socketServices, _) {
                    return Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.only(right: Dimensions.marginSizeDefault),
                      decoration: BoxDecoration(
                        color: context.watch<SocketServices>().connectionIndicator == ConnectionIndicator.green 
                            ?ColorResources.green 
                            : context.watch<SocketServices>().connectionIndicator == ConnectionIndicator.yellow 
                            ?ColorResources.yellow 
                            : context.watch<SocketServices>().connectionIndicator == ConnectionIndicator.red 
                            ?ColorResources.white 
                            : ColorResources.transparent,
                        shape: BoxShape.circle,
                      ),                      
                    );
                  }
                ),
              ],
            ),
            body: messageProvider.messageStatus == MessageStatus.loading
              ? Center(child: const SpinKitThreeBounce(
                  size: 20.0,
                  color: Colors.black87,
                ))
              :
              Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chat List
                    Container(
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFFC82927),
                        border: Border.all(color: ColorResources.greyLightPrimary, width: 2)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: ColorResources.white,
                            ),
                            children: [
                              TextSpan(
                                text: "Terima kasih telah menghubungi kami di ",
                              ),
                              TextSpan(
                                text: "Amulet",
                                style: robotoRegular.copyWith(
                                  fontWeight: FontWeight.bold, // Make "Raksha" bold
                                  color: ColorResources.white,
                                ),
                              ),
                              TextSpan(
                                text: ". Apakah yang bisa kami bantu atas keluhan anda?",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: ListView.builder(
                        controller: sC,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          print("Data : ${messages[index]['createdAt']}");
                          return ChatMessage(
                            sender: messages[index]['sender']!,
                            message: messages[index]['message']!, 
                            createdAt: messages[index]['createdAt'] ?? "${DateTime.now()}",
                          );
                        },
                      ),
                    ),
                    
                    // Message input field and send button
                  ],
                ),
          );
        }
      ),
    );
  }

  void socketRoomInit() async {
    var provider = context.read<SocketServices>();
    String? idUser = await StorageHelper.getUserId();
    socketIo = provider.socket;

    socketIo?.emit('join:ticketRoom', widget.ticketId);

    socketIo?.on('listen:ticketMessage', (message) {
      print('_____');
      print(message);

      if (message['sender']['id'] != idUser) {
        messageProvider.getUnread(widget.ticketId.toString());
        setState(() {
          messages.add({'sender': 'bot', 'message': message['message']});

          Future.delayed(const Duration(milliseconds: 300), () {
            if (sC.hasClients) {
              sC.animateTo(
                sC.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300), 
                curve: Curves.easeOut, 
              );
            }
          });
        });
      }
    });

    socketIo?.on('listen:ticketClosed', (message)  {
      print("Closed");
      print(message);
      print(message['status']);
      print(message['message_close']);
      setState(() {
        messageProvider.setStatus(message['status']);
        messageProvider.setMessage(message['message_close'] == null ? "" : message['message_close']);
        if(message['status'] == 'Closed'){
          // ShowSnackbar.snackbar(context, "Kasus sudah ditutup oleh admin, halaman ini akan otomatis kembali ke menu utama dalam 30 detik", "", ColorResources.purpleDark);
          setState(() {
            showResolved = false;
          });
          // Future.delayed(new Duration(seconds: 30), () {
          //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen( )));
          // });
        }
        if(message['status'] == 'Resolved'){
          setState(() {
            showResolved = false;
          });
        }
        FocusScope.of(context).unfocus();
      });
    });


    socketIo?.onReconnect((_) {
      // reconnect after disconnect and rejoin
      socketIo?.emit('join:ticketRoom', widget.ticketId);
      print("ON reconnect again");
      // calls api chats again, to get other chat pending...
      getInitialMessage();
    });
  }

  void leaveRoom() {
    print('leave');
    socketIo?.off('listen:ticketMessage');
    socketIo?.off('listen:ticketClosed');
    socketIo?.emit('leave:ticketRoom', widget.ticketId);
  }
}

// Widget for individual chat messages
class ChatMessage extends StatelessWidget {
  final String sender;
  final String message;
  final String createdAt;

  const ChatMessage({super.key, required this.sender, required this.message, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    bool isUser = sender == 'user';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: isUser ? Color(0xFFC82927) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? ColorResources.white : ColorResources.black
                  ),
                ),
              ),
              Text("${DateFormat('HH:mm').format(DateTime.parse(createdAt))}",
                style: TextStyle(
                  fontSize: 16,
                  color: ColorResources.black
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
