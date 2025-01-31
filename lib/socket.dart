import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/chatV2/presentation/chatv2.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/global.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ConnectionIndicator { red, yellow, green }

class SocketServices with ChangeNotifier, DiagnosticableTreeMixin {
  static final shared = SocketServices();
  IO.Socket? socket;
  bool isConnected = false;

  ConnectionIndicator _connectionIndicator = ConnectionIndicator.yellow;
  ConnectionIndicator get connectionIndicator => _connectionIndicator;

  void setStateConnectionIndicator(ConnectionIndicator connectionIndicators) {
    _connectionIndicator = connectionIndicators;
    
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void toggleConnection(bool connection) {
    isConnected = connection;

    Future.delayed(Duration.zero, () => notifyListeners());
  }
  

  init({String? myTokenLogin}) async {
    String? token = myTokenLogin ?? await StorageHelper.getToken();
    debugPrint("Token : $token");
  
    socket = IO.io(RemoteDataSourceConsts.socketIoUrl,
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            // .disableAutoConnect() // disable auto-connection
          .setExtraHeaders({
          'Authorization': token}) // optional
          .disableAutoConnect()
          .enableForceNew()
          .enableForceNewConnection()
          .build());

           socket?.connect();

    socket?.onConnect((_) {
      setStateConnectionIndicator(ConnectionIndicator.yellow);
      Future.delayed(const Duration(seconds: 1), () {
        setStateConnectionIndicator(ConnectionIndicator.green);
        toggleConnection(true);
      });
      isConnected = true;
      print('On Connect');
    });

    socket?.onReconnect((_) {
      isConnected = true;
      setStateConnectionIndicator(ConnectionIndicator.red);
      print('On Reconnect');

      /// rejoin global init if have
    });

    socket?.on('listen:confirmcase', (data) async {
      print(data);
      debugPrint("=== CONFIRM SOS ===");

      Future.delayed(const Duration(milliseconds: 1500), () {
        navigatorKey.currentContext!.read<SosNotifier>().stopTimer();
      });

      // StorageHelper.saveSosId(sosId: sosId);
      
      String? token = await StorageHelper.getToken();

      debugPrint("Token : $token");


      if (token == null || token == "") {
        // Navigator.of(navigatorKey.currentContext!).pushReplacement(MaterialPageRoute(
        // builder: (BuildContext context) => SignInScreen()));
      } else {
        // / if router in home push
        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) {
          return ChatPagev2(
            ticketId: data["id"],
          );
        }));
      }

      // StorageHelper.saveDisableButton(disable: false);
    });

    socket?.onDisconnect((_)  {
      setStateConnectionIndicator(ConnectionIndicator.red);
      isConnected = false;
      print('disconnect');
    });

    socket?.onError((_)  
    {
      setStateConnectionIndicator(ConnectionIndicator.red);
      isConnected = false;
      print('error sockect : $_',);
    });
  }

  void connect() {
    print("On Connect Socket");
    init();
    isConnected = true;
  }

  void allClose() {
    socket?.off('listen:confirmcase');
    socket?.disconnect();
    print("On Disconnect Socket");
    socket?.close();
    socket = null;
    setStateConnectionIndicator(ConnectionIndicator.red);
    isConnected = false;
  }
  


  
  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // properties.add(IntProperty('count', count));
  }
}