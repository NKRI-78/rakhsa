import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:rakhsa/features/auth/presentation/provider/login_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_chats_notifier.dart';
import 'package:rakhsa/features/chat/presentation/provider/get_messages_notifier.dart';
import 'package:rakhsa/features/media/presentation/providers/upload_media_notifier.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/websockets.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => di.locator<LoginNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<UploadMediaNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetChatsNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<GetMessagesNotifier>()),
  ChangeNotifierProvider(create: (_) => di.locator<WebSocketsService>()),
];