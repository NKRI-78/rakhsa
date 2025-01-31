import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/chatV2/presentation/chatv2.dart';
import 'package:rakhsa/features/chatV2/presentation/provider/messages.dart';
import 'package:rakhsa/features/chatV2/presentation/provider/navigation.dart';

class ChatV2List extends StatefulWidget {
  const ChatV2List({super.key});

  @override
  State<ChatV2List> createState() => _ChatV2ListState();
}

class _ChatV2ListState extends State<ChatV2List> {

  late MessageProvider messageProvider;
  late NavigationService navigationService;

  @override
  void initState() {
    messageProvider = context.read<MessageProvider>();
    super.initState();
    navigationService = NavigationService();

    Future.delayed(Duration.zero, () async {
      if(mounted) {
        await messageProvider.getChatsHistory();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageProvider.getCountMessageUnread();
  }
  
  @override
  Widget build(BuildContext context) {
    print("Get Id : ${messageProvider.chatsData.id}");
    return Consumer<MessageProvider>(
            builder: (BuildContext context, MessageProvider messageProvider, _) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            messageProvider.getCountMessageUnread();
            Navigator.pop(context);
          },
          child: Scaffold(
            body: CustomScrollView(
              physics: ScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: ColorResources.redHealth,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text("Notification",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.bold,
                      color: ColorResources.white
                    ),
                  ),
                  leading: CupertinoNavigationBarBackButton(
                    color: ColorResources.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                messageProvider.messageHistoryStatus == MessageHistoryStatus.loading ? 
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator()
                  )
                ) : messageProvider.chatsData.status == "Resolved" 
                || messageProvider.chatsData.status == "Closed" 
                || messageProvider.chatsData.status == "Open" 
                || messageProvider.chatsData.messages == null
                ?
                SliverFillRemaining(
                  child: Center(
                    child: Text("Belum ada notifikasi",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault
                      ),
                    )
                  ),
                ):
                 SliverList(
                  delegate: SliverChildListDelegate([
                    ListTile(
                        onTap: () {
                          navigationService.pushNav(context, ChatPagev2(ticketId: messageProvider.chatsData.id ?? 0,));
                        },
                        subtitle: (messageProvider.chatsData.messages?.isEmpty ?? false)
                            ? const SizedBox() 
                            : Text(messageProvider.chatsData.messages?.first.message ?? "-",
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontSize: 10.0
                                ),
                              ) ,
                        leading: CachedNetworkImage(
                          imageUrl: messageProvider.chatsData.staff?.profile?.photoUrl ?? "-",
                          imageBuilder: (context, imageProvider) {
                            return CircleAvatar(
                              backgroundImage: imageProvider,
                            );
                          },
                          placeholder: (context, url) {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/default.jpg'),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/default.jpg'),
                            );
                          },
                        ),
                        title: Text(messageProvider.chatsData.staff?.profile?.fullname ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: 
                            messageProvider.chatsData.status == "Resolved" ?
                            ColorResources.green : 
                            messageProvider.chatsData.status == "Closed" ?
                            ColorResources.blue : ColorResources.yellow
                          ),
                          child: Text(
                            messageProvider.chatsData.status ?? "-",
                            style: TextStyle(
                              color: ColorResources.white,
                              fontSize: Dimensions.fontSizeSmall,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      )
                  ]),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}